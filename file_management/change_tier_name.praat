# This scripts change the name of tier(s) in all textgrid files in a directory.
# To avoid losing important files, make sure you have copies of your old textgrids.
# Created by Miao Zhang, 2020

form Change Tier Names
	sentence Dir_name: /Users/zenmule/Research/Changsha_Xiang/Exp_2/recordings/f1_ZWJ
	sentence Tier_name_1: Tier1
	sentence Tier_name_2: Tier2
	# sentence Tier_name_*: ... (add more tiers if needed)
endform

Create Strings as file list: "files", "'Dir_name$'/*.TextGrid"

num_file = Get number of strings

for ifile to num_file
	select Strings files
	fileName$ = Get string: ifile
	Read from file: "'Dir_name$'/'fileName$'"
	textgrid_id = selected("TextGrid")
	select 'textgrid_id'
	Set tier name: 1, "'Tier_name_1$'"
	Set tier name: 2, "'Tier_name_2$'"
	# Set tier name: *, "*" (add more tiers if needed)
	Save as text file: "'Dir_name$'/'fileName$'"
endfor
select all
Remove





