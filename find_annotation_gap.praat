# This is a script to find annotation gaps in vot annotations. 

# Each recording should only have one token of trial. There should be three tiers: vot, closure, and 
# segment. The script will use vot as an anchor to find out if there are any labeled intervals on closure 
# and segment tier. 

# If the labeled closure or segment interval was not found, the script will log down the file name, 
# and arbituarily insert a interval. 

# After running the script, you can use the log file to go to the recordings in which intervals were 
# inserted and manually adjust the location of the boundaries.

# Copyright @Miao Zhang, 11/30/2022.

##########################################################

form Extract durations from labeled tier
	comment The suffix of your output file:
  	sentence Gap_file: _gaps
   	comment On which tier vot is labeled?
   	positive Vot_tier 1
   	positive Closure_tier 2
   	positive Segment_tier 3
endform

pauseScript: "Please choose the folder that contains your recordings and textgrid files."
directory_name$ = chooseDirectory$: "Choose <SOUND> folder"

new_dir$ = directory_name$ + "/" + "fill"
createFolder: new_dir$

# Create the log file and the header
output_file$ = directory_name$ + gap_file$ + ".csv"
deleteFile: output_file$
sep$ = ","
header$ = "file_name" + sep$
  ...+ "cl_gap" + sep$
  ...+ "c_gap" + sep$
  ...+ "v_gap"
writeFileLine: output_file$, header$

##########################################################

# Create a list of all wav files in the directory
tgNames$# = fileNames$# (directory_name$ + "/*.TextGrid")
num_file = size (tgNames$#)

writeInfoLine: "Files needed to be modified include: " 

# Open the soundfile in Praat
for i_file from 1 to num_file
	file_name$ = tgNames$# [i_file]
    

    # Read the TextGrid file into Praat
    textgrid_file = Read from file: directory_name$ + "/" + file_name$
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

            # Get closure
            if index (vot_label$, "-") <> 0
                i_cl = Get interval at time: closure_tier, vot_start
            else
                i_cl = Get interval at time: closure_tier, vot_start-0.03
            endif

            if index(file_name$, "chw") = 0
                cl_label$ = Get label of interval: closure_tier, i_cl
                if cl_label$ = ""
                    #if index (vot_label$, "-") <> 0
                    #    cl_start = vot_start
                    #    cl_end = vot_start + 0.12
                    #else
                    #    cl_end = vot_start
                    #    cl_start = vot_end - 0.12
                    #endif
                    #if i_cl = 1
                    #    Insert boundary: closure_tier, cl_start
                    #    Insert boundary: closure_tier, cl_end
                    #endif
                    #i_cl = Get interval at time: closure_tier, cl_start
                    #Set interval text: closure_tier, i_cl, "cl"
                    cl_fill = 1
                else
                    #cl_start = Get starting point: closure_tier, i_cl
                    #cl_end = Get end point: closure_tier, i_cl
                    cl_fill = 0
                endif
            else
                cl_fill = 0
            endif

            # Get consonant
            i_cons = Get interval at time: segment_tier, vot_start
            c_label$ = Get label of interval: segment_tier, i_cons
            c_label$ = replace_regex$ (c_label$, "[\s|\t|,|.]+", "", 0)

            if c_label$ = ""
                #c_start = cl_start
                #if index (vot_label$, "-") <> 0
                #    c_end = cl_end
                #else
                #    c_end = vot_end
                #endif
                #if i_cons = 1
                #    Insert boundary: segment_tier, c_start
                #    Insert boundary: segment_tier, c_end
                #endif
                #i_c = Get interval at time: segment_tier, c_start
                #Set interval text: segment_tier, i_c, "c"
                c_fill = 1
            else
                #c_start = Get starting point: segment_tier, i_cons
                #c_end = Get end point: segment_tier, i_cons
                c_fill = 0
            endif

            # Get vowel
            #if vot_end < cl_end
                #i_vowel = Get interval at time: segment_tier, cl_end+0.015
            #else
                i_vowel = Get interval at time: segment_tier, vot_end+0.015
            #endif
            v_label$ = Get label of interval: segment_tier, i_vowel
            v_label$ = replace_regex$ (v_label$, "[\s|\t|,|.]+", "", 0)

            if v_label$ = ""
                #v_start = c_end
                #v_end= v_start + 0.2
                #if i_vowel = num_intv
                #    Insert boundary: segment_tier, v_start
                #    Insert boundary: segment_tier, v_end
                #endif
                #i_v = Get interval at time: segment_tier, v_start
                #Set interval text: segment_tier, i_v, "v"
                v_fill = 1
            else
                v_fill = 0
            endif

            if cl_fill = 1 or c_fill = 1 or v_fill = 1
                result$ = file_name$ + sep$
                    ...+ "'cl_fill'" + sep$
                    ...+ "'c_fill'" + sep$
                    ...+ "'v_fill'"
                appendFileLine: output_file$, result$

                sound_name$ = file_name$ - ".TextGrid"
                sound = Read from file: directory_name$ + "/" + sound_name$ + ".wav"
                selectObject: textgrid_file
	            Save as text file: new_dir$ + "/" + sound_name$ + "_fill" + ".TextGrid"
                selectObject: sound
                Write to WAV file: new_dir$ + "/" + sound_name$ + "_fill" + ".wav"
                removeObject: sound

                appendInfoLine: tab$ + file_name$ - ".TextGrid"
            endif

        endif
    endfor

    removeObject: textgrid_file
endfor

appendInfoLine: newline$ + "Done."