# Pitch Dynamics script.
# This script provides duration and F0 values for all files in a directory with an interval label. In addition to providing these, the
# F0 maxima and minima, the amplitude and the average speed of F0 movement, and the maxima and minima locations are also calculated.
# The location of the F0 maxima and minima are normalized. The
# value reflects the relative location (as a percentage) of these values across the interval, starting from the beginning. For instance,
# a value of .3 for an F0 maximum means that the F0 maximum occurred 30% into the interval duration. All results are written to a
# textfile.

# The pitch window threshold is the buffer size for tracking F0. For example, with a value of 0.03 means for a 100 ms window, F0 tracking
# starts at 30 ms before the window and ends 30 ms after (160 ms total). Only those values within the specified window are reported, however.
# Copyright Christian DiCanio, SUNY Buffalo, October 2019

# Updated in November 2015 to include contextual information for working with corpora. This version of the script requires that all
# segments to be analyzed by on a separate tier.

# Updated in July 2016 to fix an issue pertaining to ensuring that the right window size is specified for F0 extraction and for fixing
# some redundant code. Thanks to Paul Boersma for this help.

# Updated in March 2018 to fix an issue with incorrect calculation of the locations of extrema.
# Thanks to Claire Bowern for pointing this out.

# Minor update now extracts intensity contour as well. 3/23/18

# Update to 6.2 in April 2019 to fix memory overload error. Thanks to Richard Hatcher.

# Update in December 2019 to add in adjacent interval information.

# Update by Miao Zhang to create one single header row for all recordings.

# Update by Miao Zhang to include the amplitude of F0 movement and the average velocity of F0 movement. 10/12/2020

# Number of intervals you wish to extract from.

form Extract Pitch data from labelled intervals
   sentence Directory_name: /Users/zenmule/Research/KansaiJPN_CF0/Experiment/recordings/M1_HK
   sentence Log_file _f0
   positive Numintervals 5
   positive Position_tier_number 3
   positive Lexeme_tier_number 3
   positive Syllable_tier_number 3
   positive Labeled_tier_number 3
   positive Analysis_points_time_step 0.005
   positive Record_with_precision 1
   comment F0 Settings:
   positive F0_minimum 70
   positive F0_maximum 350
   positive Octave_jump 0.10
   positive Voicing_threshold 0.65
   positive Pitch_window_threshold 0.03
endform

# Create header row
fileappend 'directory_name$''log_file$'.txt label'tab$'Segment'tab$'Syllable'tab$'Word'tab$'Position'tab$'start'tab$'end'tab$'cdur'tab$'dur'tab$'Sylldur'tab$'

for i to numintervals
	fileappend 'directory_name$''log_file$'.txt 'i'val_F0'tab$'
endfor
for m to numintervals
	fileappend 'directory_name$''log_file$'.txt 'm'val_int'tab$'
endfor

fileappend 'directory_name$''log_file$'.txt F0min'tab$'F0max'tab$'F0locmin'tab$'F0locmax'tab$'F0_amp'tab$'F0_roc
fileappend 'directory_name$''log_file$'.txt 'newline$'

# If your sound files are in a different format, you can insert that format instead of wav below.

Create Strings as file list... list 'directory_name$'/*.wav
num = Get number of strings
for ifile to num
	select Strings list
	fileName$ = Get string... ifile
	Read from file... 'directory_name$'/'fileName$'
	soundID1$ = selected$("Sound")
	soundID2 = selected("Sound")
	Read from file... 'directory_name$'/'soundID1$'.TextGrid
	textGridID = selected("TextGrid")


	# Get all intervals
	num_labels = Get number of intervals... labeled_tier_number
	for i to num_labels
		select 'textGridID'
		label$ = Get label of interval... labeled_tier_number i

			# Skip unlabeled intervals
		if label$ <> ""
			fileappend 'directory_name$''log_file$'.txt 'fileName$''tab$'
   			intvl_start = Get starting point... labeled_tier_number i
			intvl_end = Get end point... labeled_tier_number i
			seg$ = do$ ("Get label of interval...", labeled_tier_number, i)

			syll_num = do ("Get interval at time...", syllable_tier_number, intvl_start)
			syll_start = Get starting point: syllable_tier_number, syll_num
			syll_end = Get end point: syllable_tier_number, syll_num
			sylldur = syll_end - syll_start
			syll$ = do$ ("Get label of interval...", syllable_tier_number, syll_num)

			lex_num = do ("Get interval at time...", lexeme_tier_number, intvl_start)
			lex$ = do$ ("Get label of interval...", lexeme_tier_number, lex_num)

			position_num = do ("Get interval at time...", position_tier_number, intvl_start)
			position$ = do$ ("Get label of interval...", position_tier_number, position_num)

			select 'soundID2'
			Extract part... intvl_start intvl_end Rectangular 1 no
			intID = selected("Sound")
			vdur = Get total duration
			cdur = sylldur - vdur
			fileappend 'directory_name$''log_file$'.txt 'seg$''tab$''syll$''tab$''lex$''tab$''position$''tab$''intvl_start''tab$''intvl_end''tab$''cdur''tab$''vdur''tab$''sylldur''tab$'

			pstart = intvl_start - pitch_window_threshold
			pend = intvl_end + pitch_window_threshold

			#Pitch analysis
			select 'intID'
			if vdur < 0.04
				size = vdur/numintervals
					for q to numintervals
						start = (q-1) * size
						end = q * size
						val_F0  = 0
						val_int = 0
						fileappend 'directory_name$''log_file$'.txt 'val_F0''tab$''val_int''tab$'
					endfor
				min = 0
				max = 0
				locmin = 0
				locmax = 0
				f0_amp = 0
				f0_roc = 0
				fileappend 'directory_name$''log_file$'.txt 'min''tab$''max''tab$''locmin''tab$''locmax''tab$''f0_amp''tab$''f0_roc'
				fileappend 'directory_name$''log_file$'.txt 'newline$'

				select 'intID'
				Remove
			else
				select 'soundID2'
				Extract part... pstart pend Rectangular 1 no
				soundID3 = selected("Sound")
				To Pitch (ac)... 0 f0_minimum 15 yes 0.03 voicing_threshold octave_jump 0.35 0.14 f0_maximum
				pitchID = selected("Pitch")

				# Filtered intensity
				select 'soundID3'
				Filter (pass Hann band): 40, 4000, 100
				soundID4 = selected("Sound")
				To Intensity: f0_minimum, 0, "yes"
				intensID = selected("Intensity")

				select 'pitchID'
				size = vdur/numintervals
					for h to numintervals
						start = (((h-1) * size) + pitch_window_threshold)
						end = h * size + pitch_window_threshold
						val_F0  = Get mean: start, end, "Hertz"
							if val_F0 = undefined
								fileappend 'directory_name$''log_file$'.txt NA'tab$'
							else
								fileappend 'directory_name$''log_file$'.txt 'val_F0''tab$'
							endif
					endfor

				select 'intensID'
				size = vdur/numintervals
					for q to numintervals
						start = (((q-1) * size) + pitch_window_threshold)
						end = q * size + pitch_window_threshold
						val_int  = Get mean: start, end, "dB"
							if val_int = undefined
								fileappend 'directory_name$''log_file$'.txt NA'tab$'
							else
								fileappend 'directory_name$''log_file$'.txt 'val_int''tab$'
							endif
					endfor

				select 'soundID3'
				ostart = Get start time
				oend = Get end time
				start = ostart + pitch_window_threshold
				end = oend - pitch_window_threshold
				dur2 = end - start
				select 'pitchID'

				min = Get minimum... start end Hertz Parabolic
					if min = undefined
						fileappend 'directory_name$''log_file$'.txt NA'tab$'
					else
						fileappend 'directory_name$''log_file$'.txt 'min''tab$'
					endif

				max = Get maximum... start end Hertz Parabolic
					if max = undefined
						fileappend 'directory_name$''log_file$'.txt NA'tab$'
					else
						fileappend 'directory_name$''log_file$'.txt 'max''tab$'
					endif

				plocmin = Get time of minimum... start end Hertz Parabolic
				locmin = (plocmin - pitch_window_threshold)/dur2
					if plocmin = undefined
						fileappend 'directory_name$''log_file$'.txt NA'tab$'
					else
						fileappend 'directory_name$''log_file$'.txt 'locmin''tab$'
					endif

				plocmax = Get time of maximum... start end Hertz Parabolic
				locmax = (plocmax - pitch_window_threshold)/dur2
					if plocmax = undefined
						fileappend 'directory_name$''log_file$'.txt NA'tab$'
					else
						fileappend 'directory_name$''log_file$'.txt 'locmax''tab$'
					endif

					if min = undefined or max = undefined
						fileappend 'directory_name$''log_file$'.txt NA'tab$'NA
					else
						f0_amp = max - min
						f0_roc = f0_amp/(plocmax - plocmin)
						fileappend 'directory_name$''log_file$'.txt 'f0_amp''tab$''f0_roc'
					endif
				fileappend 'directory_name$''log_file$'.txt 'newline$'

				select 'pitchID'
				plus 'intensID'
				plus 'soundID3'
				plus 'soundID4'
				plus 'intID'
				Remove
			endif
		else
			#do nothing
  		endif
	endfor

	select 'textGridID'
	Remove
	select 'soundID2'
	Remove
endfor
select all
Remove
