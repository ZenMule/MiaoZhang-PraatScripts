# Extraction of durations from all textgrid files in a directory.
# Extracts the duration of every labelled interval on a particular tier.
# Saves the duration data as a text file with the name of both the sound file and the intervals.
# Copyright Miao Zhang, UB, 6/14/2021.

##########################################################

form Extract durations from labeled tier
   sentence Directory_name: /Users/zenmule/Programming/Praat/test/annotated
   sentence Log_file: vot
   positive Vot_tier: 1
   positive Segment_tier: 2
   positive Syllable_tier: 3
endform

##########################################################

# Create the log file and the header
output_file$ = directory_name$ + "/" + log_file$ + ".txt"
sep$ = tab$
header$ = "file_name" + sep$
  ...+ "cons" + sep$
  ...+ "vowel" + sep$
  ...+ "syllable" + sep$
  ...+ "syll_intv" + sep$
  ...+ "cl_dur" + sep$
  ...+ "vot" + sep$
  ...+ "cons_dur" + sep$
  ...+ "vowel_dur" + sep$
  ...+ "syll_dur" + newline$
appendFile: output_file$, header$

##########################################################

# Create a list of all wav files in the directory
Create Strings as file list: "fileList", directory_name$ + "/*.wav"

# Get the number of files in the directory
selectObject: "Strings fileList"
num_file = Get number of strings

# Loop through the directory
for ifile from 1 to num_file
	# Read sound file
	selectObject: "Strings fileList"
	fileName$ = Get string: ifile
	sound_file = Read from file: directory_name$ + "/" + fileName$
	sound_name$ = selected$("Sound")
	textGridID = Read from file: directory_name$ + "/" + sound_name$ + ".TextGrid"

	# Get labelled intervals from the specified tier
	num_syll = Get number of intervals: syllable_tier

	# loop through the intervals of the labeled tier
	for i_syll from 1 to num_syll
		selectObject: textGridID
		syll$ = Get label of interval: syllable_tier, i_syll

		# skip unlabeled intervals
		if syll$ <> ""
      # get syllable info
      syll_start = Get starting point: syllable_tier, i_syll
      syll_end = Get end point: syllable_tier, i_syll
      syll_dur = syll_end - syll_start
      syll_label$ = Get label of interval: syllable_tier, i_syll

      i_vowel = Get interval at time: segment_tier, syll_end
      i_cons = Get interval at time: segment_tier, syll_start

      # Get vowel info
      v_start = Get starting point: segment_tier, i_vowel-1
      v_end = Get end point: segment_tier, i_vowel-1
      v_dur = v_end - v_start
      v_label$ = Get label of interval: segment_tier, i_vowel-1

      # Get consonant info
      c_start = Get starting point: segment_tier, i_cons
      c_end = Get end point: segment_tier, i_cons
      c_dur = c_end - c_start
      c_label$ = Get label of interval: segment_tier, i_cons

      i_vot = Get interval at time: vot_tier, c_end
      i_cl = Get interval at time: vot_tier, c_start

      # Get vot info
      vot_start = Get starting point: vot_tier, i_vot-1
      vot_end = Get end point: vot_tier, i_vot-1
      vot_dur = vot_end - vot_start

      # Get closure info
      cl_start = Get starting point: vot_tier, i_cl
      cl_end = Get end point: vot_tier, i_cl
      cl_dur = cl_end - cl_start

      results$ = fileName$ + sep$
        ...+ c_label$ + sep$
        ...+ v_label$ + sep$
        ...+ syll_label$ + sep$
        ...+ "'i_syll'" + sep$
        ...+ "'cl_dur:3'" + sep$
        ...+ "'vot_dur:3'" + sep$
        ...+ "'c_dur:3'" + sep$
        ...+ "'v_dur:3'" + sep$
        ...+ "'syll_dur:3'" + newline$

      appendFile: output_file$, results$
		else
			# do nothing
		endif
	endfor
endfor

select all
Remove
