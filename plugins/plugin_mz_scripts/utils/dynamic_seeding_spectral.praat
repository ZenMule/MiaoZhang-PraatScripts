#######################################################################
#######################################################################

# This program extracts duration, f0, formants (F1-F4) and spectral tilt
# from labeled intervals on a tier. The number of labeled tier and the
# amount of equidistant intervals can be specified using the form below.
# The output will be saved to two different log files. One contains
# durational and contextual information and the other by-interval information.

# This program will extract formant values depending on if the labeled
# interval contains a vowel sequence or monophthong. It the labeled
# interval is a vowel sequence, the script will use three sets of
# reference formant values to track formants in the three tertiles from
# the interval (First, second, and last 33%). Otherwise the script only uses 
# one set of reference formant values.

# The user must have three reference files ready before running the script.
# The first file is speaker log file, which must have the speaker id as the
# 1st column, and the speaker's gender as the 2nd column.

# The second file is the vowel reference values. The 1st column should
# be different labels of vowels, which must match with the labels you used
# in the TextGrid files to annotate your recordings. The 2nd column is the
# gender information since the vowel formants change depending on the
# gender of the speaker. The rest 9 columns are formant reference values of
# F1-F3 from the initial, medial, and final tertiles of a vowel segment.

# The third file is the formant ceiling and number of tracking formant file.
# The 1st column is gender, the 2nd column formant ceiling value, and the
# 3rd column number of formants to track.

# The part that measures spectral tilt related measures is based on the 
# spectralMeasures.praat script in James Kirby's PraatSauce bundle:
# https://github.com/kirbyj/praatsauce

# The framework of this script is based on another script of mine that
# only measures formant values: https://github.com/ZenMule/FormantTrackingDynamicSeeding

#######################################################################

# Copyright (c) 2021-2022 Miao Zhang

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

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
	positive Number_of_chunks 12
	comment Formant analysis setttings:
  	positive Analysis_points_time_step 0.005
  	positive Record_with_precision 1
  	positive Window_length 0.025
  	positive Preemphasis_from 50
  	positive Buffer_window_length 0.04
	positive F4_ref 3800
	positive F5_ref 4600
	comment Pitch Settings:
    positive Octave_cost 0.01
    positive Pitch_floor 80
    positive Pitch_ceiling 350
endform

#######################################################################
#######################################################################

# Read in the speaker log and vowel reference file
pauseScript: "Choose < SPEAKER LOG > file"
table_sp_name$ = chooseReadFile$: "Load the SPEAKER LOG file"
if table_sp_name$ <> ""
    table_sp = Read Table from comma-separated file: table_sp_name$
else
		exitScript: "No < SPEAKER LOG > file was selected."
endif

# Formant reference
pauseScript: "Choose <FORMANT REFERENCE> file"
table_ref_name$ = chooseReadFile$: "Load the FORMANT REFERENCE file"
if table_ref_name$ <> ""
    table_ref = Read Table from comma-separated file: table_ref_name$
else
		exitScript: "No < FORMANT REFERENCE > file was selected."
endif

# Formant ceiling and number of formants to track
pauseScript: "Choose <FORMANT SETTING> file"
table_ceiling_name$ = chooseReadFile$: "Load the FORMANT CEILING file"
if table_ceiling_name$ <> ""
    table_ceiling = Read Table from comma-separated file: table_ceiling_name$
else
		exitScript: "No < FORMANT SETTING > file was selected."
endif

#######################################################################

# Get all the folders in the directory
# Choose the root folder of the recordings of all speakers
pauseScript: "Choose < SOUND FILE > subordinate folder"
dir_rec$ = chooseDirectory$: "Choose <SOUND FILE> subordinate folder"

output_t$ = dir_rec$ + log_file_t$ + ".tsv"
header_t$ = "File_name" + tab$
	...+ "Speaker" + tab$
	...+ "Gender" + tab$
	...+ "Seg_num" + tab$
	...+ "Seg" + tab$
	...+ "Syll" + tab$
	...+ "t" + tab$
	...+ "t_m" + tab$
	...+ "F0" + tab$
	...+ "F1" + tab$
	...+ "F2" + tab$
	...+ "F3" + tab$
	...+ "F4" + tab$
	...+ "H1db" + tab$
	...+ "H2db" + tab$
	...+ "H4db" + tab$
	...+ "A1db" + tab$
	...+ "A2db" + tab$
	...+ "A3db" + tab$
	...+ "H2kdb" + tab$
	...+ "H5kdb" + tab$
	...+ "HNR" + tab$
	...+ "H1_H2" + tab$
	...+ "H2_H4" + tab$
	...+ "H4_H2khz" + tab$
	...+ "H2k_H5k" + tab$
	...+ "H1_A1" +tab$
	...+ "H1_A2" +tab$
	...+ "H1_A3" +tab$
	...+ "CPP"
	...+ newline$
appendFile: output_t$, header_t$

output_c$ = dir_rec$ + log_file_c$ + ".tsv"
header_c$ = "File_name" + tab$
	...+ "Speaker" + tab$
	...+ "Gender" + tab$
	...+ "Seg_num" + tab$
	...+ "Seg" + tab$
	...+ "Dur" + tab$
	...+ "Seg_prev" + tab$
	...+ "Seg_subs" + tab$
	...+ "Syll" + tab$
	...+ "Syll_dur" + newline$
appendFile: output_c$, header_c$

if dir_rec$ <> ""
  	folderNames$# = folderNames$# (dir_rec$)
else
	exitScript: "No folder was selected."
endif

# Loop through the folders
for i_folder from 1 to size (folderNames$#)
	speaker_id$ = folderNames$# [i_folder]

	sp_prog = i_folder/size (folderNames$#)
	writeInfoLine: "Extracting formants from..."
	writeInfo: "Current speaker: < 'speaker_id$' > ('sp_prog:2'), "

	# Get the gender of each speaker from speaker log file
	selectObject: table_sp
	sp_col$ = Get column label: 1
	gender_sp_col$ = Get column label: 2
	gender_row = Search column: sp_col$, speaker_id$
	gender$ = Get value: gender_row, gender_sp_col$

	appendInfoLine: "gender: < 'gender$' >."

	# Get the formant ceiling and number of formants to track
	selectObject: table_ceiling
	gender_ceiling_col$ = Get column label: 1
	ceiling_col$ = Get column label: 2
	num_form_col$ = Get column label: 3
	gender_ceiling_row = Search column: gender_ceiling_col$, gender$
	formant_ceiling = Get value: gender_ceiling_row, ceiling_col$
	number_of_formants = Get value: gender_ceiling_row, num_form_col$

  	# Get all the sound files in the current folder
	wavNames$# = fileNames$# (dir_rec$ + "/" + speaker_id$ + "/*.wav")
	tgNames$# = fileNames$# (dir_rec$ + "/" + speaker_id$ + "/*.TextGrid")

	#appendInfoLine: "Number of files: < 'num_file' >."

  #######################################################################

 	# Loop through all the files
	for i_file from 1 to size (wavNames$#)
		# Read in wav file
		wav_name$ = wavNames$# [i_file]
		Read from file: dir_rec$ + "/" + speaker_id$ + "/" + wav_name$
		sound_file = selected("Sound")
		sound_name$ = selected$("Sound")

		wav_prog = i_file/size (wavNames$#)
		appendInfoLine: "Current file: 'wav_name$' ('wav_prog:2')."

		# Read in textgrid file
		tg_name$ = tgNames$# [i_file]
		Read from file: dir_rec$ + "/" + speaker_id$ + "/" + tg_name$
		textgrid_file = selected("TextGrid")

		num_label = Get number of intervals: labeled_tier_number

    #######################################################################

    # Loop through all the labeled intervals
		for i_label from 1 to num_label
			selectObject: textgrid_file
			label$ = Get label of interval: labeled_tier_number, i_label

      #######################################################################

			if label$ <> ""
				# Print progress information in the info window
				appendInfoLine: "		Interval ['i_label']: <'label$'>."

				# Get the duration of the labeled interval
				label_start = Get starting point: labeled_tier_number, i_label
				label_end = Get end point: labeled_tier_number, i_label
				dur = label_end - label_start

				# Get the label of the previous segment if it is labeled
				seg_prev$ = Get label of interval: labeled_tier_number, (i_label-1)
				if seg_prev$ = ""
					seg_prev$ = "NA"
				endif

				# Get the label of the subsequent segment if it is labeled
				seg_subs$ = Get label of interval: labeled_tier_number, (i_label+1)
				if seg_subs$ = ""
					seg_subs$ = "NA"
				endif

				# Get the lable of the syllable from the syllable tier if there is one
				if syllable_tier_number <> 0
					# Get the index of the current syllable that the labeled segment occurred in
					syll_num = Get interval at time: syllable_tier_number, (label_start + (label_end - label_start)/2)

					# Get the duration of the syllable
					syll_start = Get starting point: syllable_tier_number, syll_num
					syll_end = Get end point: syllable_tier_number, syll_num
					syll_dur = syll_end - syll_start
					syll$ = Get label of interval: syllable_tier_number, syll_num
				else
					# If there is no syllable tier, the label of syllable is NA, and the duration is 0
					syll_dur = 0
					syll$ = "NA"
				endif

				# Paste the values above log file c
				value_c$ = "'wav_name$'" + tab$
					...+ "'speaker_id$'" + tab$
					...+ "'gender$'" + tab$
					...+ "'i_label'" + tab$
					...+ "'label$'" + tab$
					...+ "'dur:3'" + tab$
					...+ "'seg_prev$'" + tab$
					...+ "'seg_subs$'" + tab$
					...+ "'syll$'" + tab$
					...+ "'syll_dur:3'" + newline$
				appendFile: output_c$, value_c$

				#######################################################################

				# Get the columns and the medium reference value of the labeled vowel
				selectObject: table_ref

				vowel_col$ = Get column label: 1
				gender_in_ref_col$ = Get column label: 2

				table_vowel = Extract rows where: "self$[""'gender_in_ref_col$'""]=""'gender$'"" and self$[""'vowel_col$'""]=""'label$'"""
				selectObject: table_vowel
				f1_init$ = Get column label: 3
				f2_init$ = Get column label: 4
				f3_init$ = Get column label: 5

				f1_med$ = Get column label: 6
				f2_med$ = Get column label: 7
				f3_med$ = Get column label: 8

				f1_fin$ = Get column label: 9
				f2_fin$ = Get column label: 10
				f3_fin$ = Get column label: 11

				f1_ref_med = Get value: 1, "'f1_med$'"
				f2_ref_med = Get value: 1, "'f2_med$'"
				f3_ref_med = Get value: 1, "'f3_med$'"

				#######################################################################

				## Formant analysis and spectral analysis
	      		# Extract the formant object first
				fstart = label_start - buffer_window_length
				fend = label_end + buffer_window_length
				selectObject: sound_file
				Extract part: fstart, fend, "rectangular", 1, "no"
				extracted = selected("Sound")

				# Extract pitch object
				selectObject: extracted
				To Pitch (ac): analysis_points_time_step, pitch_floor, 15, "no", 0.03, 0.45, octave_cost, 0.35, 0.14, pitch_ceiling
				pitch_obj = selected("Pitch")

				# Extract harmonicity object
				selectObject: extracted
				To Harmonicity (cc): analysis_points_time_step, pitch_floor, 0.1, 4.5
				hnr_obj = selected("Harmonicity")

				# Extract spectrum object
				selectObject: extracted
				To Spectrum: "yes"
				spectrum_obj = selected("Spectrum")

				# Extract Ltas object
				To Ltas (1-to-1)
				ltas_obj = selected("Ltas")
				
				# Extract power cepstrum
				selectObject: spectrum_obj
				To PowerCepstrum
				cepstrum_obj = selected("PowerCepstrum")

				# Extract formant (using burg method)
	      		selectObject: extracted
	      		To Formant (burg): analysis_points_time_step, number_of_formants, formant_ceiling, window_length, preemphasis_from
				formant_burg = selected("Formant")
				num_form = Get minimum number of formants

	      		# Set how many formants the script should track
	      		if num_form = 2
	        		number_tracks = 2
	      		elsif num_form = 3
	        		number_tracks = 3
	      		else
					number_tracks = 4
				endif

				# Get the duration of each equidistant interval of a labeled segment
				chunk_length  = dur/number_of_chunks

				for i_chunk from 1 to number_of_chunks
					# Extract f0
					selectObject: pitch_obj
					f0 = Get mean: buffer_window_length + (i_chunk - 1) * chunk_length, buffer_window_length + i_chunk * chunk_length, "Hertz"
					if f0 = undefined
						f0 = 0
					endif

					# Get the reference values of formants for different vowels and gender of speakers
					selectObject: table_vowel
					if i_chunk <= number_of_chunks/3
						f1_ref = Get value: 1, "'f1_init$'"
						if f1_ref = 0
							f1_ref = f1_ref_med
						endif
						f2_ref = Get value: 1, "'f2_init$'"
						if f2_ref = 0
							f2_ref = f1_ref_med
						endif
						f3_ref = Get value: 1, "'f3_init$'"
						if f3_ref = 0
							f3_ref = f1_ref_med
						endif
						#appendInfoLine: "			< Initial > Current ref fmts: 'f1_ref', F2: 'f2_ref', F3: 'f3_ref'."
					elsif i_chunk <= 2*number_of_chunks/3
						f1_ref = f1_ref_med
						f2_ref = f2_ref_med
						f3_ref = f3_ref_med
						#appendInfoLine: "			< Medial > Current ref fmts: 'f1_ref', F2: 'f2_ref', F3: 'f3_ref'."
					else 
						f1_ref = Get value: 1, "'f1_fin$'"
						if f1_ref = 0
							f1_ref = f1_ref_med
						endif
						f2_ref = Get value: 1, "'f2_fin$'"
						if f2_ref = 0
							f2_ref = f1_ref_med
						endif
						f3_ref = Get value: 1, "'f3_fin$'"
						if f3_ref = 0
							f3_ref = f1_ref_med
						endif
						#appendInfoLine: "			< Final > Current ref fmts: 'f1_ref', F2: 'f2_ref', F3: 'f3_ref'."
					endif


            		# Track the formants
            		selectObject: formant_burg
            		Track: number_tracks, 'f1_ref', 'f2_ref', 'f3_ref', 'f4_ref', 'f5_ref', 1, 1, 1
      				formant_tracked = selected("Formant")

					# Get the start, end, and middle point of the interval
					chunk_start = buffer_window_length + (i_chunk - 1) * chunk_length
					chunk_end = buffer_window_length + i_chunk * chunk_length
					chunk_mid = buffer_window_length + chunk_length/2 + (i_chunk - 1) * chunk_length

					# Paste to the log file t
					info$ = "'wav_name$'" + tab$
						...+ "'speaker_id$'" + tab$
						...+ "'gender$'" + tab$
						...+ "'i_label'" + tab$
						...+ "'label$'" + tab$
						...+ "'syll$'" + tab$
						...+ "'i_chunk'" + tab$
						...+ "'chunk_mid:3'" + tab$
					appendFile: output_t$, info$

					selectObject: formant_tracked
					# F1
					f1 = Get mean: 1, chunk_start, chunk_end, "hertz"
					if f1 = undefined
						f1 = 0
					endif
					f1_lwr = f1 - (f1/10)
					f1_upr = f1 + (f1/10)

					# F2
					f2 = Get mean: 2, chunk_start, chunk_end, "hertz"
					if f2 = undefined
						f2 = 0
					endif
					f2_lwr = f2 - (f2/10)
					f2_upr = f2 + (f2/10)

					# F3
					f3 = Get mean: 3, chunk_start, chunk_end, "hertz"
					if f3 = undefined
						f3 = 0
					endif
					f3_lwr = f3 - (f3/10)
					f3_upr = f3 + (f3/10)

					# F4
					f4 = Get mean: 4, chunk_start, chunk_end, "hertz"
					if f4 = undefined
						f4 = 0
					endif

					# Paste the formant values to the log file t
					value_f$ = "'f0:0'" + tab$
						...+ "'f1:0'" + tab$
						...+ "'f2:0'" + tab$
						...+ "'f3:0'" + tab$
						...+ "'f4:0'" + tab$
					appendFile: output_t$, value_f$

						# Cepstral peak prominence
					selectObject: cepstrum_obj
					cpp = Get peak prominence: pitch_floor, pitch_ceiling, "parabolic", 0.001, 0, "Straight", "Robust"

					# Extract HNR
					selectObject: hnr_obj			
					hnr = Get mean: (i_chunk-1) * chunk_length, i_chunk * chunk_length
					if hnr = undefined
						hnr = 0
					else
						hnr = hnr
					endif

					# Extract H2k and H5k
					# This method of getting H2k and H5k is taken from James Kirby's script: spectralMeasures.praat in his praatSauce script bundle.
					selectObject: cepstrum_obj
					peak_quef = Get quefrency of peak: 50, 550, "Parabolic"
					peak_freq = 1/peak_quef
					h2k_lwb = 2000 - peak_freq
					h2k_upb = 2000 + peak_freq
					h5k_lwb = 5000 - peak_freq
					h5k_upb = 5000 + peak_freq
					selectObject: ltas_obj
					h2kdb = Get maximum: h2k_lwb, h2k_upb, "Cubic"
					h5kdb = Get maximum: h5k_lwb, h5k_upb, "Cubic"

					# Extract H1, H2, H4
					if (f0 <> undefined and f1 <> 0 and f2 <> 0 and f3 <> 0)
						f0_p10 = f0/10

						# Get the lower and upper boundary of h1, h2, h4 extraction
						selectObject: ltas_obj
						h1_lwb = f0 - f0_p10
						h1_upb = f0 + f0_p10
						h2_lwb = (f0 * 2) - f0_p10
						h2_upb = (f0 * 2) + f0_p10
						h4_lwb = (f0 * 4) - f0_p10
						h4_upb = (f0 * 4) + f0_p10

						# Get H1, H2, H4
						h1db = Get maximum: h1_lwb, h1_upb, "none"
						h1hz = Get frequency of maximum: h1_lwb, h1_upb, "none"
						h2db = Get maximum: h2_lwb, h2_upb, "none"
						h2hz = Get frequency of maximum: h2_lwb, h2_upb, "none"
						h4db = Get maximum: h4_lwb, h4_upb, "none"
						h4hz = Get frequency of maximum: h4_lwb, h4_upb, "none"

						# Get A1, A2, A3
						a1db = Get maximum: f1_lwr, f1_upr, "none"
						a1hz = Get frequency of maximum: f1_lwr, f1_upr, "none"
						a2db = Get maximum: f2_lwr, f2_upr, "none"
						a2hz = Get frequency of maximum: f2_lwr, f2_upr, "none"
						a3db = Get maximum: f3_lwr, f3_upr, "none"
						a3hz = Get frequency of maximum: f3_lwr, f3_upr, "none"
					else
						h1db = 0
						h1hz = 0
						h2db = 0
						h2hz = 0
						h4db = 0
						h2hz = 0
						h2kdb = 0
						h5kdb = 0
						a1db = 0
						a2db = 0
						a3db = 0
					endif

					h1h2 = h1db - h2db
					h2h4 = h2db - h4db
					h4h2k = h4db - h2kdb
					h2kh5k = h2kdb - h5kdb
					h1a1 = h1db - a1db
					h1a2 = h1db - a2db
					h1a3 = h1db - a3db

					value_h$ = "'h1db:2'" + tab$
						...+ "'h2db:2'" + tab$
						...+ "'h4db:2'" + tab$
						...+ "'a1db:2'" + tab$
						...+ "'a2db:2'" + tab$
						...+ "'a3db:2'" + tab$
						...+ "'h2kdb:2'" + tab$
						...+ "'h5kdb:2'" + tab$
						...+ "'hnr:2'" + tab$
						...+ "'h1h2:2'" + tab$
						...+ "'h2h4:2'" + tab$
						...+ "'h4h2k:2'" + tab$
						...+ "'h2kh5k:2'" + tab$
						...+ "'h1a1:2'" + tab$
						...+ "'h1a2:2'" + tab$
						...+ "'h1a3:2'" + tab$
						...+ "'cpp:2'" + newline$
					appendFile: output_t$, value_h$
				
  				endfor

				# Remove
				removeObject: formant_burg, extracted, table_vowel, pitch_obj, hnr_obj, cepstrum_obj, spectrum_obj, ltas_obj

			endif
		endfor

		# Remove
		removeObject: sound_file, textgrid_file

	endfor
endfor

select all
Remove

writeInfoLine: "All done!"