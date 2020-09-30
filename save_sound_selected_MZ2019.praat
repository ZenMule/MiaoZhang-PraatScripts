# Saves multiple sound files as WAV in a directory specified in the script.
# This will automatically overwrite the previously saved files with the same name.
# Make sure you have backups for the old files. 
# Miao Zhang (2019). email: miaozhan@buffalo.edu

# Put the directory you want to save files to below

dir$ = "/Users/zenmule/OneDrive/Chinese TA/Recordings"

n = numberOfSelected("Sound")
for i from 1 to n
s'i' = selected("Sound",'i')
s'i'$ = selected$("Sound",'i')
endfor

for i from 1 to n
n$ = s'i'$
select s'i'
Save as WAV file... 'dir$'/'n$'.wav
endfor