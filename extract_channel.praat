# Extract a specific channel script
# This script extract one of the channels as you specify below and save them.

# PLEASE BACK UP BEFORE RUNNING THIS SCRIPT. 

# Copyright, Miao Zhang, SUNY Buffalo, 7/8/2021.
# Updated 11/22/2022.

############################################################

form Extract channel
	comment Indicate the channel you want to extract:
    positive Channel_number: 1
endform

############################################################

# Clear the info window
clearinfo

pauseScript: "Please choose the folder that your recordings and textgrid files are saved."
directory_name$ = chooseDirectory$: "Choose <SOUND> folder"

# Get all the files from the directory
fileNames$# = fileNames$# (directory_name$ + "/*.wav")

for i_file from 1 to size (fileNames$#)
	fileName$ = Get string: i_file

	Read from file: directory_name$ + "/" + fileName$
	
	# Get the file name
	sound_name$ = selected$("Sound") 

	# Extract the specified channel
	Extract one channel: channel_number
	Write to WAV file: directory_name$ + "/" + sound_name$ + "chn_" + "'channel_number'" + ".wav"
	
	printline 'i_file'/'num_file' file(s) done.
endfor

select all
Remove

printline All Done!