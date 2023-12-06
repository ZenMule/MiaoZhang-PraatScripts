# Extraction of durations from all labeled intervals on a tier in a textgrid file.
# Copyright Miao Zhang, UB, 6/14/2021.
# Modified at 6/13/2023.

##########################################################

form Extract durations from labeled tier
	optionmenu Format: 1
       option .wav
	   option .WAV
   	sentence Log_file: _vot
   	positive Labeled_tier: 1
endform

directory_name$ = chooseDirectory$: "Choose the root folder that contains all the subfolders."

clearinfo

##########################################################

# Create the header row
output_file$ = directory_name$ + log_file$ + ".csv"
sep$ = ","
deleteFile: output_file$
header$ = "Folder_name" + sep$
  ...+ "File_name" + sep$
  ...+ "Intv" + sep$
  ...+ "Intv_num" + sep$
  ...+ "Intv_dur" + newline$
appendFile: output_file$, header$

##########################################################

folderNames$# = folderNames$# (directory_name$)
num_folder = size (folderNames$#)

for ifolder from 1 to num_folder
  folderName$ = folderNames$# [ifolder]
  fileNames$# = fileNames$# (directory_name$ + "/" + folderName$ + "/*" + format$)
  num_file = size (fileNames$#)

  # Loop through the directory
  for ifile from 1 to num_file
  	# Read sound file
  	fileName$ = fileNames$# [ifile]
	writeInfoLine: "Processing file: " + fileName$ + " in folder: " + folderName$ + "."
  	Read from file: directory_name$ + "/" + folderName$ + "/" + fileName$

  	# Select the sound file and extract its name
  	sound_file = selected("Sound")
  	sound_name$ = selected$("Sound")

  	# Read the corresponding TextGrid files using the name of the sound file
  	Read from file: directory_name$ + "/" + folderName$ + "/" + sound_name$ + ".TextGrid"
  	textGridID = selected("TextGrid")

  	# Get labelled intervals from the specified tier
  	num_intv = Get number of intervals: labeled_tier

  	# loop through the intervals of the labeled tier
  	for i_intv from 1 to num_intv
  		selectObject: textGridID
  		i_label$ = Get label of interval: labeled_tier, i_intv

  		# skip unlabeled intervals
  		if i_label$ <> ""

  			# get duration and label
  			i_intv_start = Get starting point: labeled_tier, i_intv
  			i_intv_end = Get end point: labeled_tier, i_intv
  			i_dur = round((i_intv_end - i_intv_start) * 1000)

  			# put the label and duration of the interval in the output .txt file
        	results$ = folderName$ + sep$
          	...+ fileName$ + sep$
          	...+ i_label$ + sep$
          	...+ "'i_intv'" + sep$
          	...+ "'i_dur'" + newline$
        	appendFile: output_file$, results$

  		else
  			# do nothing
  		endif
  	endfor

	removeObject: textGridID, sound_file

  endfor
endfor

appendInfoLine: newline$
appendInfoLine: "Finished"