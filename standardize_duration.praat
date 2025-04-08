
folder$ = chooseDirectory$: "Choose the root folder that contains all the subfolders."

fileNames$# = fileNames$# (folder$ + "/*.wav")
vec# = zero#(size(fileNames$#))
writeInfoLine: vec#


for i from 1 to size(fileNames$#)
	sndName$ = fileNames$# [i]
	
    tgName$ = replace$ (sndName$, ".wav", ".TextGrid", 0)

	snd = Read from file: folder$ + "/" + sndName$
    tg = Read from file: folder$ + "/" + tgName$

	selectObject: tg
    num_intv = Get number of intervals: 1

	for i_intv from 1 to num_intv
        selectObject: tg
        i_label$ = Get label of interval: 1, i_intv 
        if i_label$ <> ""
            i_intv_start = Get starting point: 1, i_intv
  			i_intv_end = Get end point: 1, i_intv
  			i_dur = i_intv_end - i_intv_start
			appendInfoLine: i_dur
        endif
    endfor

	vec# [i] = i_dur

	removeObject: snd, tg
endfor

mean = mean(vec#)
writeInfoLine: "The average vowel duration is ", round(mean, 3)

for i from 1 to size(fileNames$#)
	sndName$ = fileNames$# [i]
    tgName$ = replace$ (sndName$, ".wav", ".TextGrid", 0)

	snd = Read from file: folder$ + "/" + sndName$
    tg = Read from file: folder$ + "/" + tgName$

	selectObject: tg
	for i_intv from 1 to num_intv
        selectObject: tg
        i_label$ = Get label of interval: 1, i_intv 
        if i_label$ <> ""
            i_intv_start = Get starting point: 1, i_intv
  			i_intv_end = Get end point: 1, i_intv
  			i_dur = i_intv_end - i_intv_start
			appendInfoLine: i_dur
        endif
    endfor

	selectObject: snd
	mnp = To Manipulation: 0.01, 50, 600
	dur_tier
endfor



selectObject: "Sound khui_34"
To Manipulation: 0.01, 50, 600
Extract duration tier
View & Edit
selectObject: "Manipulation khui_34"

Create DurationTier: "shorten", 0, 0.085 + 0.270
    Add point: 0.000, 70/85
    Add point: 0.084999, 70/85
    Add point: 0.085001, 200/270
    Add point: 0.355, 200/270


Replace duration tier
Replace duration tier
selectObject: "Manipulation khui_34"
View & Edit
Close
selectObject: "DurationTier khui_34"
View & Edit
Close

