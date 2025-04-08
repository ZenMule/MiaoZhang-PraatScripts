# Extract a specific channel script
# This script extract one of the channels as you specify below and save them.

# PLEASE BACK UP BEFORE RUNNING THIS SCRIPT. 

# Copyright, Miao Zhang, SUNY Buffalo, 7/8/2021.
# Updated 11/22/2022. 
# Updated 09/26/2024

############################################################

form Extract channel
	comment Indicate the channel you want to extract:
	sentence: "Folder", ""
    	positive: "Channel_number", "1"
	boolean: "Delete_original", 1
endform

############################################################

# Clear the info window
clearinfo

# Get all the files from the directory
fileNames$# = fileNames$# (folder$ + "/*.wav")
num_file = size(fileNames$#)

for i_file from 1 to num_file
	fileName$ = fileNames$# [i_file]

	Read from file: folder$ + "/" + fileName$
	
	# Get the file name
	sound_name$ = selected$("Sound") 

	# Extract the specified channel
	Extract one channel: channel_number
	Write to WAV file: folder$ + "/" + sound_name$ + "_chn_" + "'channel_number'" + ".wav"

	if delete_original == 1
		deleteFile(folder$ + "/" + fileName$)
	endif	

	writeInfoLine: "'i_file'/'num_file' file(s) done."
endfor

select all
Remove

writeInfoLine: "All Done!"