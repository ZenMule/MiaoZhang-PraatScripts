# This is a script to extract vot information based on information from three tiers.
# One tier should contain vot information, the second tier segment information,
# and the third tier syllable informaiton.

# The script will first find the syllalbe tier and get where the syllable is
# located in the recording, and then find segments and vot and closure duration.

# Copyright Miao Zhang, UB, 2/24/2022.

# Updated 8/19/2022.

##########################################################

form Extract durations from labeled tier
   sentence Log_file: vot
   positive Vot_tier: 1
   integer Closure_tier: 0 
   positive Segment_tier: 2
   positive Syllable_tier: 3
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

# Get the number of files in the directory
selectObject: "Strings fileList"
num_file = Get number of strings

# Loop through the directory
for i_file from 1 to num_file
	# Read sound file
	selectObject: "Strings fileList"
	file_name$ = Get string: i_file
	sound_file = Read from file: directory_name$ + "/" + file_name$
	sound_name$ = selected$("Sound")
	textgrid_file = Read from file: directory_name$ + "/" + sound_name$ + ".TextGrid"

	# Get labelled intervals from the specified tier
  selectObject: textgrid_file
	num_vot = Get number of intervals: vot_tier

	# loop through the intervals of the labeled tier
	for i_vot from 1 to num_vot
		selectObject: textgrid_file
		vot_label$ = Get label of interval: vot_tier, i_vot

		# skip unlabeled intervals
		if vot_label$ <> ""
      # get vot
      vot_start = Get starting point: vot_tier, i_vot
      vot_end = Get end point: vot_tier, i_vot
      vot = vot_end - vot_start

      # Get syllable
      i_syll = Get interval at time: syllable_tier, vot_end
      syll_start = Get starting point: syllable_tier, i_syll
      syll_end = Get end point: syllable_tier, i_syll
      syll_dur = syll_end - syll_start

      # Get consonant
      i_cons = Get interval at time: segment_tier, syll_start
      c_start = Get starting point: segment_tier, i_cons
      c_end = Get end point: segment_tier, i_cons
      c_dur = c_end - c_start
      
      # Get vowel
      i_vowel = Get interval at time: segment_tier, syll_end 
      v_start = Get starting point: segment_tier, i_vowel-1
      v_end = Get end point: segment_tier, i_vowel-1
      v_dur = v_end - v_start
      
      if closure_tier <> 0
        i_cl = Get interval at time: closure_tier, syll_start
        cl_start = Get starting point: closure_tier, i_cl
        cl_end = Get end point: closure_tier, i_cl
        cl_dur = cl_end - cl_start
      else
        cl_dur = 0
      endif

      results$ = file_name$ + sep$
        ...+ "'cl_dur:3'" + sep$
        ...+ "'vot_dur:3'" + sep$
        ...+ "'c_dur:3'" + sep$
        ...+ "'v_dur:3'" + newline$
      appendFile: output_file$, results$
		else
			# do nothing
		endif

    selectObject: sound_file, textgrid_file
    Remove

	endfor
endfor

select all
Remove
