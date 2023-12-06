# This is a script that chunk a long recording into small sound files.
# The contextual information will be saved in the title of the chunked sound files.
# The user can specify what labeled intervals they want to chunk.

form Chunking sound and preserve the context
    optionmenu Format: 1
       option .wav
	   option .WAV
    positive Labeled_tier_number 2
    positive Word_tier_number 1
    sentence Target_labels i e a o u
    positive Buffer_window 0.1
endform

dir_rec$ = chooseDirectory$: "Choose <SOUND FILE> subordinate folder"
targets$# = splitByWhitespace$# (target_labels$)

fileNames$# = fileNames$# (dir_rec$ + "/*" + format$)

new_dir$ = dir_rec$ + "/" + "individuals"
createFolder: new_dir$

target_num_total = 0
for i_file from 1 to size (fileNames$#)
    textgrid_name$ = fileNames$# [i_file] - format$
    textgrid_file = Read from file: dir_rec$ + "/" + textgrid_name$ + ".TextGrid"
    num_label = Get number of intervals: labeled_tier_number

    for i_label from 1 to num_label
        selectObject: textgrid_file
        label$ = Get label of interval: labeled_tier_number, i_label
        idx = index(targets$#, label$)

        if label$ <> "" and idx <> 0
            target_num_total = target_num_total + 1
        endif
    endfor
    removeObject: textgrid_file
endif

prog = 0

for i_file from 1 to size (fileNames$#)
    file_name$ = fileNames$# [i_file]
    textgrid_name$ = file_name$ - format$
    sound_file = Read from file: dir_rec$ + "/" + file_name$
    textgrid_file = Read from file: dir_rec$ + "/" + textgrid_name$ + ".TextGrid"
    num_label = Get number of intervals: labeled_tier_number

    for i_label from 1 to num_label
        selectObject: textgrid_file
        label$ = Get label of interval: labeled_tier_number, i_label
        
        idx = index(targets$#, label$)

        if label$ <> "" and idx <> 0
            prog = prog+1
            writeInfoLine: "Progress: ", percent$(prog/target_num_total, 0), "(prog/target_num_total)"
	        prev$ = Get label of interval: labeled_tier_number, i_label-1
            if prev$ = ""
                prev$ = "NA"
            endif
            fllw$ = Get label of interval: labeled_tier_number, i_label+1
            if fllw$ = ""
                fllw$ = "NA"
            endif 

            label_start = Get starting point: labeled_tier_number, i_label
            label_end = Get end point: labeled_tier_number, i_label
            label_med = label_start + (label_end - label_start)/2

            word_intv = Get interval at time: word_tier_number, label_med
            word$ = Get label of interval: word_tier_number, word_intv
            if word$ = ""
                word$ = "NA"
            endif

            chunk_start = label_start - buffer_window
            chunk_end = label_end + buffer_window

            # extract the current labeled interval
			selectObject: textgrid_file
			textgrid_chunk = Extract part: chunk_start, chunk_end, "yes"

            selectObject: textgrid_chunk
            intv_tgt = Get interval at time: labeled_tier_number, label_med

            num_chunk_label = Get number of intervals: labeled_tier_number
            for i_chunk_label from 1 to num_chunk_label
                if i_chunk_label <> intv_tgt
                    Set interval text: labeled_tier_number, i_chunk_label, ""
                endif 
            endfor

            selectObject: textgrid_chunk
            Shift times to: "start time", 0

			# extract the current labeled sound
			selectObject: sound_file
			sound_chunk = Extract part: chunk_start, chunk_end, "rectangular", 1, "no"

            selectObject: sound_chunk
			Write to WAV file: new_dir$ + "/" + textgrid_name$ + "_" + "'i_label'" + "_" + word$ + "_" + prev$ + "_" + label$ + "_" + fllw$ + ".wav"

            # Save the textgrid file in the same way
            selectObject: textgrid_chunk
            Save as text file: new_dir$ + "/" + textgrid_name$ + "_" + "'i_label'" + "_" + word$ + "_" + prev$ + "_" + label$ + "_" + fllw$ + ".TextGrid"

            removeObject: textgrid_chunk, sound_chunk
        endif
    endfor

    removeObject: sound_file, textgrid_file
endfor

appendInfoLine: "All target sounds chunked."