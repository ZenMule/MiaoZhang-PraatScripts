# This script converts the recording to monochannel and filter it 
# with stop hann band from 0 to 100Hz with a step of 50Hz.
# This script runs through all subdirectories of the root directory specified below.
# The original sound files will be overwritten. 
# Please make a back-up before you run this script when necessary.
# copyright @ Miao Zhang, UB, 2021.

############################################################
############################################################

form Make selection
	comment Enter the root directory of files
	sentence Directory /Users/zenmule/Research/Vowel_sequence/Recordings/jpn/labeled
endform

############################################################
############################################################

# Clear the info window
clearinfo


# Create a list of all subdirectories in the directory, 
# and save the number to a variable   
Create Strings as directory list: "dir_list", directory$
num_dir = Get number of strings

# Show how many subdirectories there are
printline There are "'num_dir'" subdirectories in the target directory.
printline Currently working on:

for n_dir from 1 to num_dir
	# Make sure the dir_list is selected
	selectObject: "Strings dir_list"

	# Get the name of the subdirectory
	dir_id$ = Get string: n_dir
	
	# Show progress
	printline 'tab$'"'dir_id$'"...('n_dir'/'num_dir')

	# Create a list of all the files from the subdirectory
	# and save the number to a variable
	Create Strings as file list: "file_list", directory$ + "/" + dir_id$ + "/*.wav"
	num_files = Get number of strings

	for n_file from 1 to num_files

		# Make sure the list of files is selected
		selectObject: "Strings file_list"

		
		# Get the file name and read in the file from the subdirectory
		current_file$ = Get string: n_file
		Read from file: directory$ + "/" + dir_id$ + "/" + current_file$

		
		# Get name of the sound file
		lengthFN = length (current_file$)
		sound_name$ = left$ (current_file$, lengthFN-4)


		# Show progress:
		printline 'tab$''tab$'"'sound_name$'"...('n_file'/'num_files')
	

		# Extract the specified channel and filter it
		selectObject: "Sound 'sound_name$'"
		Convert to mono
		Filter (stop Hann band): 0, 100, 50

		# Save them
		Save as WAV file: directory$ + "/" + dir_id$ + "/" + sound_name$ + ".wav"

		# Remove the processed sound files
		selectObject: "Sound 'sound_name$'"
		Remove
		selectObject: "Sound 'sound_name$'_mono"
		Remove
		selectObject: "Sound 'sound_name$'_mono_band"
		Remove
		
	endfor
	
	selectObject: "Strings file_list"
	Remove

endfor

select all
Remove

printline Finished processing sound files from all subdirectories.





