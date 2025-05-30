# This is a script to extract sound and egg signals from EGG recordings.
# It puts the sound channel, egg channel, and the original recording in three subfolders:

# snd, EGG, original

# Created by Miao Zhang, miao dot zhang at uzh dot ch, 2025/5/4.

#############################################################################

form "Extract channels from EGG recordings"
	sentence: "Folder", "/Users/miaozhang/switchdrive/Ikema/Ikema_nasal/nas_001"
	sentence: "Format", ".wav"
	boolean: "Save original", 1
endform

#############################################################################

# the folder for sound
createFolder: folder$ + "/snd"

# the folder for EGG signal
createFolder: folder$ + "/EGG"

# the folder for the originals
createFolder: folder$ + "/original"

fileList = Create Strings as file list: "fileList", folder$ + "/*" + format$

n_files = Get number of strings


for i_file from 1 to n_files
	# Make sure you select the file list in the beginning of the for loop
	selectObject: fileList
	filename$ = Get string: i_file

	filepath$ = folder$ + "/" + filename$

	# appendInfoLine: filepath$

	orig = Read from file: filepath$

	soundname$ = filename$ - format$

	# Extract the sound channel
	selectObject: orig
	ch1 = Extract one channel: 1
	ch1_path$ = folder$ + "/snd/" + soundname$ + "_ch1.wav"
	Save as WAV file: ch1_path$

	# Extract the EGG channel
	selectObject: orig
	ch2 = Extract one channel: 2
	ch2_path$ = folder$ + "/EGG/" + soundname$ + "_ch2.wav"
	Save as WAV file: ch2_path$

	if save_original == 1
		# Save the originals in a new subfolder
		selectObject: orig
		new_orig_path$ = folder$ + "/original/" + filename$
		Save as WAV file: new_orig_path$
	endif
	
	# Delete the originals
	deleteFile: filepath$

	# cleaning
	removeObject: orig, ch1, ch2

endfor

removeObject: fileList