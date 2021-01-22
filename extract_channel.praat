# Extract a specific channel script
# This script converts all sound files in a directory to mono files, extracting the channel you
# specify.

# WARNING: THIS SCRIPT WILL REPLACE YOUR FILES IN YOUR DIRECTORY WITH 1 CHANNEL SOUNDFILES. PLEASE SAVE/COPY 
# UNMODIFIED SOUND FILES IN A SEPARATE DIRECTORY.

form Convert to single channel
   sentence Directory_name: /Users/zenmule/Research/cs_obs/rec
   positive Channel: 1
endform

Create Strings as file list... list 'directory_name$'/*.wav
numberOfFiles = Get number of strings
for ifile to numberOfFiles
	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'directory_name$'/'fileName$'
	Extract one channel: channel
	lengthFN = length (fileName$)
	newfilename$ = left$ (fileName$, lengthFN-4)
	Write to WAV file... 'directory_name$'/'newfilename$'.wav
endfor
select all
Remove