# 1. This script cuts up large sound files in a directory into smaller
# chunks using an existing tier on an associated TextGrid file.

# 2. This script runs through all sound files in a directory and put
# the chunked files into a new subdirectory. The Renamed file prefix
# is a string that you can specify in the form.

# 3. The tier number reflects the tier containing the intervals which
# will be extracted. The name of the intervals will be used for the
# main file name when saving the chunked files. The intervals should
# only contain ascii characters.

# 4. If there is already a folder with the same name in the directory, the script won't run.

# 5. Copyright Miao Zhang, SUNY Buffalo, 7/8/2021.

############################################################

form Extract smaller files from large file
   sentence Directory_name: /Users/zenmule/Research/Vowel_sequence/Recordings/jpn/jpn_12
   positive Tier_number: 1
endform

############################################################

# Clear the info window
clearinfo

# Create a file list for all the recordings in the directory
Create Strings as file list: "fileList", directory_name$ + "/*.wav"

# Select the file list and get how many files there are in the directory
selectObject: "Strings fileList"
num_file = Get number of strings

for i_file from 1 to num_file

	# Make sure the file list is selected before reading in sound files
	selectObject: "Strings fileList"
	current_file$ = Get string: i_file

	# Read in the sound file
	Read from file: directory_name$ + "/" + current_file$
	sound_file = selected ("Sound")

	# Get the name of the sound file
	sound_name$ = selected$ ("Sound")

	# Create a subdirectory to save the chunked recordings later
	new_dir$ = directory_name$ + "/" + sound_name$
	runSystem: "mkdir ", new_dir$

	# Read the textgrid file
	Read from file: directory_name$ + "/" + sound_name$ + ".TextGrid"
	textgrid_file = selected("TextGrid")

	# Get the total number of intervals from the target tier
	selectObject: textgrid_file
	num_intvl = Get number of intervals: tier_number
  perc = i_file/num_file

	for i from 1 to num_intvl
		# Make sure the textgrid file is selected before running the codes below
		selectObject: textgrid_file

		# Get the label of the current interval
		lab$ = Get label of interval: tier_number, i

		# If the label is not empty, then
		if lab$ <> ""
			# Report the current progress
      writeInfoLine: "'perc:2'", tab$, "Chunking file < ", sound_name$, " >."
			appendInfoLine: tab$, "Chunking interval < ", lab$, " >."

			# Get the start and end time of the current labeled interval
			start = Get start time of interval: tier_number, i
			end = Get end time of interval: tier_number, i

			# extract the current labeled interval
			selectObject: textgrid_file
			textgrid_chunk = Extract part: start, end, "no"

			# extract the current labeled sound
			selectObject: sound_file
			sound_chunk = Extract part: start, end, "rectangular", 1, "no"

			# Save the sound file with the prefix specified in the form and the current name of the label
      selectObject: sound_chunk
			Write to WAV file: new_dir$ + "/" + sound_name$ + "_" + lab$ + ".wav"

			# Save the textgrid file in the same way
			selectObject: textgrid_chunk
			Save as text file: new_dir$ + "/" + sound_name$ + "_" + lab$ + ".TextGrid"

      removeObject: sound_chunk, textgrid_chunk

		# If the label is empty, then do nothing
		else
			#do nothing
		endif
	endfor

  removeObject: sound_file, textgrid_file

endfor

select all
Remove

writeInfoLine: "All done!"
