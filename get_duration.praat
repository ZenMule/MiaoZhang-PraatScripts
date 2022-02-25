# Extraction of durations from all textgrid files in a directory.
# Extracts the duration of every labelled interval from up to 3 tiers.
# Copyright Miao Zhang, UB, 6/14/2021.

##########################################################

form Extract durations from labeled tier
   sentence Directory_name: /yourdirectory
   sentence Log_file: _dur
   positive Tier_1: 1
   integer Tier_2: 2
   integer Tier_3: 3
endform

##########################################################

# Create the header row
output_file$ = directory_name$ + log_file$ + ".txt"
sep$ = tab$
header$ = "folder_name" + sep$
  ...+ "file_name" + sep$
  ...+ "seg_1" + sep$
  ...+ "seg_1_num" + sep$
  ...+ "seg_1_dur" + sep$
  ...+ "seg_2" + sep$
  ...+ "seg_2_num" + sep$
  ...+ "seg_2_dur" + sep$
  ...+ "seg_3" + sep$
  ...+ "seg_3_num" + sep$
  ...+ "seg_3_dur" + newline$
appendFile: output_file$, header$

##########################################################

Create Strings as folder list: "folderList", directory_name$
selectObject: "Strings folderList"
num_folder = Get number of strings

for ifolder from 1 to num_folder
  selectObject: "Strings folderLilst"
  folderName$ = Get string: ifolder

  # Create a list of all wav files in the directory
  Create Strings as file list: "fileList", directory_name$ + "/" + folderName$ + "/*.wav"

  # Get the number of files in the directory
  selectObject: "Strings fileList"
  num_file = Get number of strings

  # Loop through the directory
  for ifile from 1 to num_file
  	# Read sound file
  	selectObject: "Strings fileList"
  	fileName$ = Get string: ifile
  	Read from file: directory_name$ + "/" + fileName$

  	# Select the sound file and extract its name
  	sound_file = selected("Sound")
  	sound_name$ = selected$("Sound")

  	# Read the corresponding TextGrid files using the name of the sound file
  	Read from file: directory_name$ + "/" + sound_name$ + ".TextGrid"
  	textGridID = selected("TextGrid")

  	# Get labelled intervals from the specified tier
  	num_labels = Get number of intervals: labeled_tier_number

  	# loop through the intervals of the labeled tier
  	for i_tier_1 from 1 to num_labels
  		select 'textGridID'
  		label_1$ = Get label of interval: tier_1, i_tier_1

  		# skip unlabeled intervals
  		if label_1$ <> ""
  			# put the file name in the output .txt file
  			fileappend 'directory_name$''log_file$'.txt 'fileName$''tab$'

  			# get duration and label
  			intv_1_start = Get starting point: tier_1, i_tier_1
  			intv_1_end = Get end point: tier_1, i_tier_1
  			dur_1 = intv_1_end - intv_1_start
        mid = intv_start + dur/2

        i_tier_2 = Get interval at time: tier_2, mid
        i_tier_3 = Get interval at time: tier_3, mid

        label_2 = Get label of interval: tier_2, i_tier_2
        if label_2$ <> ""
          intv_2_start = Get starting point: tier_2, i_tier_2
          intv_2_end = Get end point: tier_2, i_tier_2
          dur_2 = intv_2_end - intv_2_start
        else
          label_2 = "NA"
          dur_2 = 0
        endif

        label_3 = Get label of interval: tier_3, i_tier_3
        if label_3$ <> ""
          intv_3_start = Get starting point: tier_3, i_tier_3
          intv_3_end = Get end point: tier_3, i_tier_3
          dur_3 = intv_3_end - intv_3_start
        else
          label_3 = "NA"
          dur_3 = 0
        endif

  			# put the label and duration of the interval in the output .txt file
        results$ = folderName$ + sep$
          ...+ fileName$ + sep$
          ...+ label_1$ + sep$
          ...+ "'i_tier_1'" + sep$
          ...+ "'dur_1'" + sep$
          ...+ label_2$ + sep$
          ...+ "'i_tier_2'" + sep$
          ...+ "'dur_2'" + sep$
          ...+ label_3$ + sep$
          ...+ "'i_tier_3'" + sep$
          ...+ "'dur_3'" + newline$

        appendFile: output_file$, results$
  		else
  			# do nothing
  		endif
  	endfor
  endfor
endfor

select all
Remove
