# This is a script to help you automatically open and close files for annotating.

# Input the target folder with your recordings and put down the tiers you want to create

# The script automatically search for sound files without an accompanying TextGrid file.

# When you are done annotating, just press 'continue' and the script will automatically save your TextGrid and open the next unannotated recording.

# Created by Miao Zhang, miao dot zhang at uzh dot ch, 2025/04/08

form
	comment: "Where your recordings are: "
	sentence: "Folder", ""
	comment: "What is the format/extension of your recordings: "
	sentence: "Format", ".wav"
	comment: "What tiers are you going to create (separate by white space): "
	sentence: "Tiers", "vot"
endform

# Get the sound files
filelist = Create Strings as file list: "fileList", folder$ + "/*" + format$

# Get total number of files
n_file = Get number of strings

for i_file from 1 to n_file
	selectObject: filelist
	# Get the file name
	filename$ = Get string: i_file
	filepath$ = folder$ + "/" + filename$

	# Check if there is existing TextGrid files
	tgname$ = replace$ (filename$, format$, ".TextGrid", 1)
	tgpath$ = folder$ + "/" + tgname$

	# If no, create one and start annotating in View Edit window
	if 	fileReadable(tgpath$) == 0

		snd = Read from file: filepath$
		tg = To TextGrid: tiers$, ""

		# Open the sound and textgrid files in the View & Edit window
		selectObject: snd
		plusObject: tg
		View & Edit

		# Let the user annotate the sound
		pauseScript: "Press 'Continue' to save and proceed, or 'Stop' to abort."

		# Save the annotated TextGrid file
		selectObject: tg
		Save as text file: tgpath$

		# Remove the sound and textgrid objects
		removeObject: snd, tg

	endif

endfor

# Remove the file list
removeObject: filelist
