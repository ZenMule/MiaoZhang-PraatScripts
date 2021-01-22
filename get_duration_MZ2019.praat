# Extraction of durations from all textgrid files in a directory. 
# Extracts the duration of every labelled interval on a particular tier. 
# Saves the duration data as a text file with the name of both the file and the intervals .
# Copyright Miao Zhang, UB, 11/30/2019.

form Extract Durations from labelled tier
   sentence Directory_name: /Users/zenmule/Research/KansaiJPN_CF0/Experiment/recordings/M1_HK
   sentence Log_file _vot
   positive Labeled_tier_number 1
   positive Analysis_points_time_step 0.005
   positive Record_with_precision 1
endform

fileappend 'directory_name$''log_file$'.txt label'tab$'seg'tab$'dur'tab$''newline$'

Create Strings as file list... list 'directory_name$'/*.wav

num_file = Get number of strings

for ifile to num_file
	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'directory_name$'/'fileName$'
	sound_name$ = selected$("Sound")
	sound_file = selected("Sound")
	Read from file... 'directory_name$'/'sound_name$'.TextGrid
	textGridID = selected("TextGrid")

	num_labels = Get number of intervals... labeled_tier_number
	for i to num_labels
		select 'textGridID'
		label$ = Get label of interval... labeled_tier_number i
		if label$ <> ""
			fileappend 'directory_name$''log_file$'.txt 'fileName$''tab$'

			intvl_start = Get starting point... labeled_tier_number i
			intvl_end = Get end point... labeled_tier_number i
			seg$ = do$ ("Get label of interval...", labeled_tier_number, i)

			select 'sound_file'
			Extract part... intvl_start intvl_end Rectangular 1 no
			dur = Get total duration
			fileappend 'directory_name$''log_file$'.txt 'seg$''tab$''dur''tab$''newline$'
		endif
	endfor
endfor
select all
Remove