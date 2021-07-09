# Create a TextGrid file for every recordings in a directory.
# Copyright: Miao Zhang, at University at Buffalo, 2021.

######################################################
######################################################

form Create TextGrid files for the sound files
	sentence Directory: /Users/zenmule/Research/Test_pool/chunked/rep1
	
	# specify the name of the tiers
	sentence Tier_name cons vot vowel pos pitch
	
	# Which is the point tier?
	sentence Point_tier_name pitch
endform

######################################################

# Create a list of all wav files in the directory
strings = Create Strings as file list: "fileList", directory$ + "/*.wav"
number_of_files = Get number of strings

######################################################

for ifile to number_of_files
	selectObject: strings

	# Read in sound file

	file_name$ = Get string: ifile
	Read from file: directory$ + "/" + file_name$

	# Create textgrid file

	To TextGrid: tier_name$, point_tier_name$

	# Save the textgrid file in the same directory

	textGrid_name$ = selected$("TextGrid")
	textGrid = selected("TextGrid")	
	select textGrid
	Save as text file: directory$ + "/" + textGrid_name$ + ".TextGrid"
endfor

######################################################

# Remove all the objects

select all
Remove



