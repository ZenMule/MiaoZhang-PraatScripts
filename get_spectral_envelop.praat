# Extracts amplitude values in spectrum. The user specifies the size of each averaged spectrum amplitude bin,
# e.g. bins of 100 Hz. or 50 Hz., etc. Spectra are calculated dynamically across the duration defined by the textgrid. 
# The number of interval values extracted is equal to numintervals below.
# Writes results to a textfile.
# Christian DiCanio, 2010.
# Revised in 2024 to handle aperiodic speech sounds - extracting entire spectral envelopes in long format
# with filtering.

# Adapted from the original script by Miao Zhang, 10.06.2025.

clearinfo

form data from labelled points
   sentence Directory_name /Users/miaozhang/switchdrive/Ikema_local/Ikema_JIPA/words
   sentence Interval_label s s: z: s\ s\: f f: v: C h 
   sentence Log_file fric_spectra
   sentence File_format .wav
   positive Numintervals 3
   positive Labeled_tier_number 1
   positive Analysis_points_time_step 0.005
   positive Record_with_precision 1
   positive Bin_size 100
   positive Resampling_value 32000
   positive Low_cutoff 300
   positive High_cutoff 16000
   positive Filter_smoothing 100
endform

interval_label$# = splitByWhitespace$# (interval_label$)
writeInfoLine: interval_label$#

pauseScript: "Confirm the target intervals. Press CONTINUE to proceed."

subfolders$# = folderNames$# (directory_name$)
n_folder = size (subfolders$#)

# Create a log file to write results to.
log_file$ = directory_name$ + "/" + log_file$ + ".csv"
deleteFile: log_file$
writeFileLine: log_file$, "FolderName,FileName,Seg,Seg_num,Duration,Interval,Bin,Amplitude"

for i_folder from 1 to n_folder
	subfolder$ = subfolders$# [i_folder]
	subfolder_path$ = directory_name$ + "/" + subfolder$
	
	# If your sound files are in a different format, you can insert that format instead of wav below.
	fileList$# = fileNames$# (subfolder_path$ + "/*" + file_format$)
	n_file = size (fileList$#)

	for ifile from 1 to n_file
		fileName$ = fileList$# [ifile]

		soundID2 = Read from file: subfolder_path$ + "/" + fileName$
		soundID1$ = selected$("Sound")
		
		selectObject: soundID2
		Resample: resampling_value, 50
		soundID3 = Filter (pass Hann band): low_cutoff, high_cutoff, filter_smoothing
		
		Read from file: subfolder_path$ + "/" + soundID1$ + ".TextGrid"
		textGridID = selected("TextGrid")
		num_labels = Get number of intervals: labeled_tier_number

		#fileappend 'directory_name$''log_file$'.txt Filename + "," + Start + "," + End + "," + Duration + "," + Interval + "," + Bin + "," + Amplitude'newline$'

		for i from 1 to num_labels
			selectObject: textGridID
			label$ = Get label of interval: labeled_tier_number, i
			idx = index(interval_label$#, label$)
			if label$ <> "" and idx > 0
				writeInfoLine: "Processing folder: " + subfolder$ + "(" + "'i_folder'" + "/" + "'n_folder'" + ")"
				appendInfoLine: "Processing file: " + fileName$ + "(" + "'ifile'" + "/" + "'n_file'" + ")"

				intvl_start = Get starting point: labeled_tier_number, i
				intvl_end = Get end point: labeled_tier_number, i
				dur = intvl_end - intvl_start	
				dur$ = fixed$(dur*1000, 0) 	

				appendInfoLine: "Processing interval: " + label$ + ". Starting from: 'intvl_start's."

				selectObject: soundID3
				intID = Extract part: intvl_start, intvl_end, "Rectangular", 1, "no"
				chunkID  = (intvl_end-intvl_start)/numintervals

				for j to numintervals	
					selectObject: intID
					chunk_part = Extract part: (j-1)*chunkID, j*chunkID, "Rectangular", 1, "no"
					selectObject: chunk_part
					spect = To Spectrum: "yes"
					ltas = To Ltas: bin_size
					mat = To Matrix
					selectObject: mat
					colnum = Get number of columns

					for k to colnum
						val = Get value in cell: 1, k
						val$ = fixed$(val, 2)
						appendFileLine: log_file$, subfolder$ + "," + fileName$ + "," + label$ + "," + "'i'" + "," + dur$ + "," + "'j'" + "," + "'k'" + "," + 
							... val$
					endfor

					removeObject: chunk_part, spect, ltas, mat
				endfor
				
				removeObject: intID
			endif
		endfor

		removeObject: soundID2, soundID3, textGridID
	endfor

endfor

select all
Remove