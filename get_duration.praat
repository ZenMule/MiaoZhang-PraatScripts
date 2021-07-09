# Extraction of durations from all textgrid files in a directory. 
# Extracts the duration of every labelled interval on a particular tier. 
# Saves the duration data as a text file with the name of both the file and the intervals.
# Copyright Miao Zhang, UB, 6/14/2021.

form Extract durations from labelled tier
   sentence Directory_name: /Users/zenmule/Research/Test_pool/syllabic_nasal_recordings
   sentence Log_file _nasdur
   positive Labeled_tier_number 1
   positive Analysis_points_time_step 0.005
   positive Record_with_precision 1
endform

fileappend 'directory_name$''log_file$'.txt label'tab$'seg'tab$'dur'newline$'

# Create a list of all wav files in the directory
Create Strings as file list: list 'directory_name$'/*.wav

# Get the number of files in the directory
num_file = Get number of strings

# Loop through the directory
for ifile to num_file

	# Read sound file

	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'directory_name$'/'fileName$'

	# Select the sound file and extract its name

	sound_file = selected("Sound")
	sound_name$ = selected$("Sound")

	# Read the corresponding TextGrid files using the name of the sound files

	Read from file... 'directory_name$'/'sound_name$'.TextGrid
	textGridID = selected("TextGrid")

	# Get labelled intervals from the tier that was specified in the form above

	num_labels = Get number of intervals... labeled_tier_number


	# loop through the intervals of the labelled tier
	for i to num_labels
		select 'textGridID'
		label$ = Get label of interval... labeled_tier_number i

		# skip unlabeled intervals
		if label$ <> ""
			fileappend 'directory_name$''log_file$'.txt 'fileName$''tab$'

			# get duration and label
			intvl_start = Get starting point... labeled_tier_number i
			intvl_end = Get end point... labeled_tier_number i
			dur = intvl_end - intvl_start

			seg$ = do$ ("Get label of interval...", labeled_tier_number, i)
			
			fileappend 'directory_name$''log_file$'.txt 'seg$''tab$''dur''newline$'

		endif
	endfor
endfor
select all
Remove