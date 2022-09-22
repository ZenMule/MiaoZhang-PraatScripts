# This is a script to extract vot in lab speech. Each recording should only have one token of trial.
# It also logs the closure duration, the consonant and vowel duration as well
# Closure and segment tier can be set to 0 if you don't have those tiers in your textgrid file.
# The script will ask you to choose a folder which contains all your recordings and textgrid files.

# The script does not log the labels of each interval, so it will only work well with lab speech of which you should have kept a log that tells you information about each trial.

# Copyright @Miao Zhang, 08/20/2022.

##########################################################

form Extract durations from labeled tier
   sentence Log_file: vot
   positive Vot_tier: 1
   integer Closure_tier: 0 
   integer Segment_tier: 2
endform

##########################################################

directory_name$ = chooseDirectory$: "Choose <SOUND> folder"

# Create the log file and the header
output_file$ = directory_name$ + log_file$ + ".tsv"
sep$ = tab$
header$ = "file_name" + sep$
  ...+ "cl_dur" + sep$
  ...+ "vot" + sep$
  ...+ "cons_dur" + sep$
  ...+ "vowel_dur" + newline$
appendFile: output_file$, header$

##########################################################

# Create a list of all wav files in the directory
Create Strings as file list: "fileList", directory_name$ + "/*.wav"
selectObject: "Strings fileList"
num_file = Get number of strings

# Open the soundfile in Praat
for i_file from 1 to num_file
  prog = i_file/num_file
  writeInfoLine: "Working progress:"
  appendInfoLine: " in the directory 'directory_name$':"
  appendInfoLine: "   Working on file <'i_file'/'num_file'> ('prog:2')." 

	selectObject: "Strings fileList"
	file_name$ = Get string: i_file

	# Read sound file
	Read from file: directory_name$ + "/" + file_name$

	sound_file = selected("Sound")
	sound_name$ = selected$("Sound")

	# Read the corresponding TextGrid file into Praat
	Read from file: directory_name$ + "/" + sound_name$ + ".TextGrid"
	textgrid_file = selected("TextGrid")

    selectObject: textgrid_file
    num_vot = Get number of intervals: vot_tier

    for i_vot from 1 to num_vot
        selectObject: textgrid_file
		vot_label$ = Get label of interval: vot_tier, i_vot

        # skip unlabeled intervals
		if vot_label$ <> ""
            # get vot
            vot_start = Get starting point: vot_tier, i_vot
            vot_end = Get end point: vot_tier, i_vot
            vot = vot_end - vot_start

            if segment_tier <> 0
              # Get consonant
              i_cons = Get interval at time: segment_tier, vot_start
              c_start = Get starting point: segment_tier, i_cons
              c_end = Get end point: segment_tier, i_cons
              c_dur = c_end - c_start
      
              # Get vowel
              i_vowel = i_cons + 1 
              v_start = Get starting point: segment_tier, i_vowel
              v_end = Get end point: segment_tier, i_vowel
              v_dur = v_end - v_start
            else 
              c_dur = 0
              v_dur = 0
            endif 

            if closure_tier <> 0
                i_cl = Get interval at time: closure_tier, c_start
                cl_start = Get starting point: closure_tier, i_cl
                cl_end = Get end point: closure_tier, i_cl
                cl_dur = cl_end - cl_start
            else
                cl_dur = 0
            endif

            results$ = sound_name$ + sep$
                ...+ "'cl_dur:3'" + sep$
                ...+ "'vot:3'" + sep$
                ...+ "'c_dur:3'" + sep$
                ...+ "'v_dur:3'" + newline$
            appendFile: output_file$, results$
	    else
			# do nothing
		endif
    endfor   
    
    selectObject: sound_file, textgrid_file
    Remove

endfor

appendInfoLine: ""
appendInfoLine: "Congrats! All files processed."
select all
Remove