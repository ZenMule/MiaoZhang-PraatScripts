#######################################################################
#######################################################################

clearinfo

#######################################################################
#######################################################################

form Extract Formant Values
	comment Basic settings:
	sentence Log_file_t _time
	sentence Log_file_c _context
	integer Syllable_tier_number 0
	positive Labeled_tier_number 1
	comment Formant analysis setttings:
  positive Analysis_points_time_step 0.005
  #positive Record_with_precision 1
  positive Window_length 0.025
  positive Preemphasis_from 50
  positive Buffer_window_length 0.04
	positive F4_ref 3800
	positive F5_ref 4600
endform

#######################################################################
#######################################################################

# Get all the folders in the directory
# Choose the root folder of the recordings of all speakers
pauseScript: "Choose < SOUND FILE > folder"
dir_rec$ = chooseDirectory$: "Choose <SOUND> folder"

fileappend 'dir_rec$''log_file_t$'.txt File_name'tab$'Speaker'tab$'Gender'tab$'Seg_num'tab$'Seg'tab$'Syll'tab$'t'tab$'t_m'tab$'F1'tab$'F2'tab$'F3'tab$'F4'tab$'COG'tab$'sdev'tab$'skew'tab$'kurt'tab$''newline$'
fileappend 'dir_rec$''log_file_c$'.txt File_name'tab$'Speaker'tab$'Gender'tab$'Seg_num'tab$'Seg'tab$'Dur'tab$'Seg_prev'tab$'Seg_subs'tab$'Syll'tab$'Syll_dur'newline$'

if dir_rec$ <> ""
  Create Strings as folder list: "folderList", dir_rec$
else
	exitScript: "No folder was selected."
endif

selectObject: "Strings folderList"
num_folder = Get number of strings

# Loop through the folders
for i_folder from 1 to num_folder
  selectObject: "Strings folderList"
	speaker_id$ = Get string: i_folder

	writeInfoLine: "Current speaker: < 'speaker_id$' >."

	# Get the gender of each speaker from speaker log file
	selectObject: table_sp
	sp_col$ = Get column label: 1
	gender_sp_col$ = Get column label: 2
	gender_row = Search column: sp_col$, speaker_id$
	gender$ = Get value: gender_row, gender_sp_col$

	appendInfoLine: "Current gender: < 'gender$' >."

	# Get the formant ceiling and number of formants to track
	selectObject: table_ceiling
	gender_ceiling_col$ = Get column label: 1
	ceiling_col$ = Get column label: 2
	num_form_col$ = Get column label: 3
	gender_ceiling_row = Search column: gender_ceiling_col$, gender$
	formant_ceiling = Get value: gender_ceiling_row, ceiling_col$
	number_of_formants = Get value: gender_ceiling_row, num_form_col$

  # Get all the sound files in the current folder
	Create Strings as file list: "fileList", dir_rec$ + "/" + speaker_id$ + "/*.wav"
	selectObject: "Strings fileList"
	num_file = Get number of strings

	#appendInfoLine: "Number of files: < 'num_file' >."

  #######################################################################

  # Loop through all the files
	for i_file from 1 to num_file
		selectObject: "Strings fileList"
		file_name$ = Get string: i_file
		Read from file: dir_rec$ + "/" + speaker_id$ + "/" + file_name$
		sound_file = selected("Sound")
		sound_name$ = selected$("Sound")
		Read from file: dir_rec$ + "/" + speaker_id$ + "/" + sound_name$ + ".TextGrid"
		textgrid_file = selected("TextGrid")
		num_label = Get number of intervals: labeled_tier_number

    #######################################################################

    # Loop through all the labeled intervals
		for i_label from 1 to num_label
			selectObject: textgrid_file
			label$ = Get label of interval: labeled_tier_number, i_label

      #######################################################################

			if label$ <> ""
				writeInfoLine: "Extracting formants from..."
				appendInfoLine: "  ", fixed$(i_file/num_file, 0), " Sound file < 'i_file' of 'num_file'>: < 'sound_name$' > of 'speaker_id$'."
				appendInfoLine: "    Interval ['i_label']: <'label$'>."

				# Get the duration of the labeled interval
				label_start = Get starting point: labeled_tier_number, i_label
				label_end = Get end point: labeled_tier_number, i_label
				dur = label_end - label_start
