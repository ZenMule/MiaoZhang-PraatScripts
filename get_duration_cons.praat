# Extraction of durations from all textgrid files in a directory. 
# Extracts the duration of every labelled interval on a particular tier. 
# Saves the duration data as a text file with the name of both the file and the intervals .
# Copyright Miao Zhang, UB, 11/30/2019.

form Extract Durations from labelled tier
   sentence Directory_name: /Users/zenmule/Research/cs_obs/rec
   sentence Log_file _vot
   sentence V_label v
   positive Labeled_tier_number 1
   positive Consonant_tier_number 2
   positive Closure_tier_number 3
   positive Analysis_points_time_step 0.005
   positive Record_with_precision 1
endform

fileappend 'directory_name$''log_file$'.txt label'tab$'seg'tab$'dur'tab$'cons'tab$'cons_dur'tab$'cl_dur'tab$'vdur'newline$'

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

		# skip unlabeled intervals
		if label$ <> ""
			fileappend 'directory_name$''log_file$'.txt 'fileName$''tab$'

			# get vot
			intvl_start = Get starting point... labeled_tier_number i
			intvl_end = Get end point... labeled_tier_number i
			seg$ = do$ ("Get label of interval...", labeled_tier_number, i)

			dur = intvl_end - intvl_start

			# get the consonant duration and closure duraiton
			if seg$ <> v_label$
				cons_num = do ("Get interval at time...", consonant_tier_number, intvl_start)
				cons_start = Get starting point... consonant_tier_number, cons_num
				cons_end = Get end point... consonant_tier_number, cons_num
				consdur = cons_end - cons_start
				cons$ = do$ ("Get label of interval...", consonant_tier_number, cons_num)

				cl_num = do("Get interval at time...", consonant_tier_number, cons_start)
				cl_start = Get starting point: closure_tier_number, cl_num
				cl_end = Get end point: closure_tier_number, cl_num
				cldur = cl_end - cl_start

				fileappend 'directory_name$''log_file$'.txt 'seg$''tab$''dur''tab$''cons$''tab$''consdur''tab$''cldur''tab$'
			
			# get vowel duration
			else
				fileappend 'dur''newline$'
			endif
		endif
	endfor
endfor
select all
Remove