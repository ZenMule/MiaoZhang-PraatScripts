# This is a script to change label names in textgrid files in a folder.
# Copyright @ Miao Zhang, 2022/11/19.

form 
    positive Labeled_tier_number 3
    sentence Target_label I AE
    sentence Replace_by i {
endform

dir_rec$ = chooseDirectory$: "Choose <SOUND FILE> folder"

target_label$# = splitByWhitespace$# (target_label$)
replace_by$# = splitByWhitespace$# (replace_by$)

writeInfoLine: "The script will replace < 'target_label$' > with < 'replace_by$' >."

tgNames$# = fileNames$# (dir_rec$ + "/*.TextGrid")

for i_tg from 1 to size (tgNames$#)
    textgrid_name$ = tgNames$# [i_tg]
    textgrid_file = Read from file: dir_rec$ + "/" + textgrid_name$
	num_label = Get number of intervals: labeled_tier_number

    for i_lab from 1 to num_label
        label$ = Get label of interval: labeled_tier_number, i_lab
        idx = index(target_label$#, label$)

        if idx <> 0
            replace_label$ = replace_by$# [idx]
            selectObject: textgrid_file
            Set interval text: labeled_tier_number, i_lab, replace_label$
            appendInfoLine: "Replaced < 'label$' > with < 'replace_label$' >."
        endif
    endfor
    selectObject: textgrid_file
    Save as text file: dir_rec$ + "/" + textgrid_name$
    removeObject: textgrid_file
endfor