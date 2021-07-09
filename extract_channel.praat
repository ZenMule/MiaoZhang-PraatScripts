# Extract a specific channel script
# This script extract one of the channels as you specify below and save them.

# WARNING: THIS SCRIPT WILL REPLACE YOUR FILES IN YOUR DIRECTORY. 
# PLEASE BACK UP BEFORE RUNNING THIS SCRIPT. 

# Copyright, Miao Zhang, SUNY Buffalo, 7/8/2021.

############################################################

form Extract channel
   sentence Directory_name: /Users/zenmule/Research/Test_pool/prosody
   positive Channel_number: 1
endform

############################################################

# Clear the info window
clearinfo

# Get all the files from the directory
Create Strings as file list: "fileList", directory_name$ + "/*.wav"
num_file = Get number of strings

printline 'num_file' file(s) in the directory 'directory_name$'.

for i_file to num_file
	select Strings fileList
	fileName$ = Get string: i_file

	Read from file: directory_name$ + "/" + fileName$
	
	# Get the file name
	sound_name$ = selected$("Sound") 

	# Extract the specified channel
	Extract one channel: channel_number
	Write to WAV file: directory_name$ + "/" + sound_name$ + ".wav"
	
	printline 'i_file'/'num_file' file(s) done.
endfor

select all
Remove

printline All Done!