# Save selected textgrid files as TEXT in a directory specified in the script.
# This will automatically overwrite previously saved files with the same name in the same directory.
# Make sure you have backups of your old files before running this script. 
# Miao Zhang (2019). miaozhan@buffalo.edu

# Put the directory you want to save files to below.
# There will be no pop-out window to let you choose the directory. 
# Make sure you have put in the right directory below before running the script.

dir$ = "/Users/zenmule/Research/Changsha_Xiang/Exp_2/recordings/m3_LG"

n = numberOfSelected("TextGrid")
for i from 1 to n
s'i' = selected("TextGrid",'i')
s'i'$ = selected$("TextGrid",'i')
endfor

for i from 1 to n
n$ = s'i'$
select s'i'
Save as text file... 'dir$'/'n$'.TextGrid
endfor