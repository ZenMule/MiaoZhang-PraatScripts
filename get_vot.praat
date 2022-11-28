# This is a script to extract vot in lab speech. Each recording should only have one token of trial.
# It also logs the closure duration, the consonant and vowel duration as well.
# Closure and segment tier can be set to 0 if you don't have those tiers in your textgrid file.
# The script will ask you to choose a folder which contains all your recordings and textgrid files.

# Copyright @Miao Zhang, 11/6/2022.

##########################################################

form Extract durations from labeled tier
	comment The suffix of your output file:
  	sentence Log_file: _vot
   	comment On which tier vot is labeled?
   	positive Vot_tier: 1
   	comment If you don't have a closure or segment tier, set them to 0
   	integer Closure_tier: 2
   	integer Segment_tier: 3
endform

##########################################################

pauseScript: "Please choose the folder that has your recordings and textgrid files."
directory_name$ = chooseDirectory$: "Choose <SOUND> folder"

stopwatch

# Create the log file and the header
output_file$ = directory_name$ + log_file$ + ".csv"
deleteFile: output_file$
sep$ = ","
header$ = "file_name" + sep$
  ...+ "cl_dur" + sep$
  ...+ "vot" + sep$
  ...+ "c_dur" + sep$
  ...+ "c_label" + sep$
  ...+ "v_dur" + sep$
  ...+ "v_label"
writeFileLine: output_file$, header$

##########################################################

# Create a list of all wav files in the directory
wavNames$# = fileNames$# (directory_name$ + "/*.wav")
num_file = size (wavNames$#)

# Open the soundfile in Praat
for i_file from 1 to num_file
  	prog = i_file/num_file
  	writeInfoLine: "Working progress:" + percent$(prog, 1)
   
	file_name$ = wavNames$# [i_file]

	# Read sound file
	sound_file = Read from file: directory_name$ + "/" + file_name$
	sound_name$ = selected$("Sound")
	textgrid_name$ = directory_name$ + "/" + sound_name$ + ".TextGrid"

	if fileReadable (textgrid_name$)
		# Read the corresponding TextGrid file into Praat
		textgrid_file = Read from file: textgrid_name$
		num_label = Get number of intervals: vot_tier

		for i_vot from 1 to num_label
			selectObject: textgrid_file
			vot_label$ = Get label of interval: vot_tier, i_vot
			vot_label$ = replace_regex$ (vot_label$, "[\s|\t|,|.]+", "", 0)

			# skip unlabeled intervals
			if vot_label$ <> ""
				# get vot
				vot_start = Get starting point: vot_tier, i_vot
				vot_end = Get end point: vot_tier, i_vot
				vot = round((vot_end - vot_start)*1000)
				if index (vot_label$, "-") <> 0
					vot = vot*(-1)
				endif

				if closure_tier <> 0
					if index (vot_label$, "-") <> 0
						i_cl = Get interval at time: closure_tier, vot_start
					else
						i_cl = Get interval at time: closure_tier, vot_start-0.03
					endif
					cl_label$ = Get label of interval: closure_tier, i_cl
					if cl_label$ <> ""
						cl_start = Get starting point: closure_tier, i_cl
						cl_end = Get end point: closure_tier, i_cl
						cl_dur = round((cl_end - cl_start)*1000)
					else
						cl_dur = 0
					endif
				else
					cl_dur = 0
				endif

				if segment_tier <> 0
					# Get consonant
					i_cons = Get interval at time: segment_tier, vot_start
					c_label$ = Get label of interval: segment_tier, i_cons
					c_label$ = replace_regex$ (c_label$, "[\s|\t|,|.]+", "", 0)

					if c_label$ <> ""
						c_start = Get starting point: segment_tier, i_cons
						c_end = Get end point: segment_tier, i_cons
						c_dur = round((c_end - c_start)*1000)
					else
						c_label$ = "NA"
						c_dur = 0
					endif
									
					# Get vowel
					if vot_end < cl_end
						i_vowel = Get interval at time: segment_tier, cl_end+0.015
					else
						i_vowel = Get interval at time: segment_tier, vot_end+0.015
					endif
					v_label$ = Get label of interval: segment_tier, i_vowel
					v_label$ = replace_regex$ (v_label$, "[\s|\t|,|.]+", "", 0)

					if v_label$ <> ""
						v_start = Get starting point: segment_tier, i_vowel
						v_end = Get end point: segment_tier, i_vowel
						v_dur = round((v_end - v_start)*1000)
					else
						v_label$ = "NA"
						v_dur = 0
					endif

				else 
					c_label$ = "NA"
					v_label$ = "NA"
					c_dur = 0
					v_dur = 0
				endif 

				results$ = sound_name$ + sep$
					...+ "'cl_dur'" + sep$
					...+ "'vot'" + sep$
					...+ "'c_dur'" + sep$
					...+ c_label$ + sep$
					...+ "'v_dur'" + sep$
					...+ v_label$
				appendFileLine: output_file$, results$
			endif
		endfor
		removeObject: textgrid_file
	endif
	
	removeObject: sound_file

endfor

runtime = stopwatch
runtime = round(runtime)

writeInfoLine: "Done. It took 'runtime's."