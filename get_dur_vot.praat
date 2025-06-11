form "Get duration"
	sentence: "Folder", "/Users/miaozhang/switchdrive/Ikema_local/Ikema_JIPA/words"
	positive: "Seg_tier", "1"
	positive: "Vot_tier", "2"
	sentence: "Output_file", "output.csv"
	sentence: "Format", ".wav"
endform

output_file$ = folder$ + "/" + output_file$

deleteFile: output_file$
writeFileLine: output_file$, "Foldername,Filename,Seg,Seg_num,Dur,Vot,Pos,Nas_type,V_syll"

folderNames$# = folderNames$# (folder$)
#writeInfoLine: folderNames$#
n_folder = size (folderNames$#)

for i_folder from 1 to n_folder
	subfolder$ = folderNames$# [i_folder]
	fileNames$# = fileNames$# (folder$ + "/" + subfolder$ + "/*" + format$)
	#appendInfoLine:fileNames$#
	n_file = size (fileNames$#)

	for i from 1 to n_file
		fileName$ = fileNames$# [i]
		snd_name$ = replace$ (fileName$, format$, "", 0)
		tgname$ = replace$ (fileName$, format$, ".TextGrid", 0)
		
		#appendInfoLine: snd_name$ + " " + tgname$

		if fileReadable(folder$ + "/" + subfolder$ + "/" + tgname$)
			snd_file = Open long sound file: folder$ + "/" + subfolder$ + "/" + fileName$
			tg_file = Read from file: folder$ + "/" + subfolder$ + "/" + tgname$

			selectObject: tg_file
			n_interval = Get number of intervals: seg_tier

			for i_intv from 1 to n_interval
				selectObject: tg_file
				i_label$ = Get label of interval: seg_tier, i_intv
				

				if i_label$ <> ""
					i_prev$ = Get label of interval: seg_tier, i_intv - 1
					i_fllw$ = Get label of interval: seg_tier, i_intv + 1
					
					if i_intv - 2 > 0				
						i_prev2$ = Get label of interval: seg_tier, i_intv - 2
					else
						i_prev2$ = ""
					endif

					if index (i_prev$, "_0") != 0
						nas_type$ = "pst_vls"
					else
						nas_type$ = "NA"
					endif

					if i_prev$ == ""
						pos$ = "word_initial"
					elsif i_fllw$ == ""
						pos$ = "word_final"
					else
						pos$ = "word_medial"
					endif

					if index (i_prev$, ":") <> 0 and i_fllw$ == "" and i_prev2$ == ""
						v_syll$ = "post-gemin"
					elsif index (i_prev$, ":") == 0 and i_fllw$ == "" and i_prev2$ == ""
						v_syll$ = "post-single"
					else
						v_syll$ = "NA"
					endif
						

					start_time = Get start time of interval: seg_tier, i_intv
					end_time = Get end time of interval: seg_tier, i_intv
				
					duration = end_time - start_time
					percent_10 = duration * 0.1
					
					find_vot_time = start_time + percent_10

					vot_intv = Get interval at time: vot_tier, find_vot_time
					vot_lab$ = Get label of interval: vot_tier, vot_intv

					if vot_lab$ <> ""
						start_vot = Get start time of interval: vot_tier, vot_intv
						end_vot = Get end time of interval: vot_tier, vot_intv
						vot = end_vot - start_vot
						vot = round(vot*1000)
						if index (vot_lab$, "-") != 0
							vot = vot * (-1)
						endif
					else
						vot = 0
					endif


					duration = round(duration*1000)
					
					appendFileLine: output_file$, subfolder$ + "," + fileName$ + "," + i_label$ + "," + "'i_intv'" + "," + "'duration'" + "," + "'vot'" + "," + pos$ + "," + nas_type$ + "," + v_syll$
				endif	
			endfor

			removeObject: snd_file, tg_file

		endif
		
		
	endfor


endfor

fileNames$# = fileNames$# (folder$ + "/*" + format$)
n_file = size (fileNames$#)


