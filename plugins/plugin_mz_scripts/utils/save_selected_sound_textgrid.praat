# Saves multiple sounds or textgrids as .wav/.TextGrid files in a directory.
# This will automatically overwrite the current files with the same name in the directory.
# Make sure you have backups for your old files. 
# Miao Zhang (2021). email: miaozhan@buffalo.edu

################################################
################################################

dir$ = chooseDirectory$: "Choose the directory to save files..."

################################################

# Select the sound files and get the file names

n_snd = numberOfSelected("Sound")

for i from 1 to n_snd
	s'i' = selected("Sound",'i')
	s'i'$ = selected$("Sound",'i')
endfor

# Save the sound files

for i from 1 to n_snd
	s_name$ = s'i'$
	select s'i'
	Save as WAV file... 'dir$'/'s_name$'.wav
endfor

#################################################

# Select the textgrid files and get the file names

n_txtg = numberOfSelected("TextGrid")

for i from 1 to n_txtg
	t'i' = selected("TextGrid",'i')
	t'i'$ = selected$("TextGrid",'i')
endfor

# Save the textGrid files

for i from 1 to n_txtg
	t_name$ = t'i'$
	select t'i'
	Save as text file... 'dir$'/'t_name$'.TextGrid
endfor

################################################