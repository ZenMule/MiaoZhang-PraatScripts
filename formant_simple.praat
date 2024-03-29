# This is a script that aims to extract the first four formants from the target vowel.
# This script only works well for monophthongs with a careful choice of reference formants
# values.

# Created by Miao Zhang, University at Buffalo, 2022

form Extract formant values:
  comment Basic settings:
  sentence Directory_name: /Users/zenmule/Programming/Praat/Praat_Scripting_Tutorial/testing_data/L5
  sentence Log_file _u
  sentence Interval_label u
  positive Labeled_tier_number 1
  positive Number_of_chunks 10

  comment Formant extracing settings:
  positive Analysis_points_time_step 0.005
  positive Formant_ceiling 4000
  positive Number_of_formants 4
  positive Window_length 0.025
  positive Preemphasis_from 50
  positive Buffer_window_length 0.04

  comment Reference formant values:
  positive F1_ref 380
  positive F2_ref 780
  positive F3_ref 2500
  positive F4_ref 3600
  positive F5_ref 4660
endform

# Create the log file
fileappend 'directory_name$''log_file$'.txt File_name'tab$'Intv_id'tab$'Seg'tab$'t'tab$'t_m'tab$'F1'tab$'F2'tab$'F3'tab$'F4'newline$'

# Open sound and textgrid files
Create Strings as file list: "fileList", directory_name$ + "/*.wav"
selectObject: "Strings fileList"
num_file = Get number of strings

# Loop through all sound files
for i_file from 1 to num_file
  selectObject: "Strings fileList"
  file_name$ = Get string: i_file
  Read from file: directory_name$ + "/" + file_name$

  # Save the name of the sound file and the sound file itself to different objects
  sound_name$ = selected$("Sound")
  sound_file = selected("Sound")

  # Read in textgrid files
  Read from file: directory_name$ + "/" + sound_name$ + ".TextGrid"
  textGrid_file = selected("TextGrid")

  # Get total number of intervals on the labeled tier in a textgrid file
  num_labels = Get number of intervals: labeled_tier_number

  # Loop through all the intervals
  for i_label from 1 to num_labels

    # Make sure the textgrid file is selected before progressing
    select 'textGrid_file'
    label$ = Get label of interval: labeled_tier_number, i_label


    if label$ = interval_label$
      # Write information in the info window
      writeInfoLine: "Extracting formants from..."
      appendInfoLine: "  Sound file < 'i_file' of 'num_file'>: < 'sound_name$' >."
      appendInfoLine: "    Interval ['i_label']: <'label$'>."

      # Get the starting and end time of the target interval
      label_start = Get starting point: labeled_tier_number, i_label
      label_end = Get end point: labeled_tier_number, i_label
      # Get the total duration of the labeled interval
      dur = label_end - label_start

      # Formant analysis
      # Set the starting and end time of the window of sound extraction for further formant analysis
      fstart = label_start - buffer_window_length
      fend = label_end + buffer_window_length

      # Extract the labeled vowel as an individual sound file
      select 'sound_file'
      Extract part: fstart, fend, "rectangular", 1, "no"
      extracted = selected("Sound")

      # Calculate the length of each formant extracting chunk
      chunk_length = dur/number_of_chunks

      # To Formant (burg)
      select 'extracted'
      To Formant (burg): analysis_points_time_step, number_of_formants, formant_ceiling, window_length, preemphasis_from
      formant_burg = selected("Formant")
      num_form = Get minimum number of formants

      # Get how many formants that should be tracked
      if num_form = 2
        number_tracks = 2
      elif num_form = 3
        number_tracks = 3
      else
          number_tracks = 4
      endif

      # Track the formants with the reference formant values specified in the form
      select 'formant_burg'
      Track: number_tracks, f1_ref, f2_ref, f3_ref, f4_ref, f5_ref, 1, 1, 1
      formant_tracked = selected("Formant")

      for i_chunk from 1 to number_of_chunks
        appendInfoLine: "      chunk ['i_chunk']..."

        # Get the starting, middle and end time point of the current value extracting chunk
        chunk_start = buffer_window_length + (i_chunk - 1) * chunk_length
        chunk_end = buffer_window_length + i_chunk * chunk_length
        chunk_mid = buffer_window_length + chunk_length/2 + (i_chunk - 1) * chunk_length

        # Write vowel info to the log file
        fileappend 'directory_name$''log_file$'.txt 'file_name$''tab$''i_label''tab$''label$''tab$''i_chunk''tab$''chunk_mid:3''tab$'

        # Make sure the formant object is selected
        select 'formant_tracked'
        # F1
        f1 = Get mean: 1, chunk_start, chunk_end, "hertz"
        if f1 = undefined
          f1 = 0
        endif

        # F2
        f2 = Get mean: 2, chunk_start, chunk_end, "hertz"
        if f2 = undefined
          f2 = 0
        endif

        # F3
        f3 = Get mean: 3, chunk_start, chunk_end, "hertz"
        if f3 = undefined
          f3 = 0
        endif

        # F4
        f4 = Get mean: 4, chunk_start, chunk_end, "hertz"
        if f4 = undefined
          f4 = 0
        endif

        # Write the result to the log file
        fileappend 'directory_name$''log_file$'.txt 'f1:0''tab$''f2:0''tab$''f3:0''tab$''f4:0''newline$'
      endfor 

      select 'formant_tracked'
      Remove
      select 'formant_burg'
      Remove
      select 'extracted'
      Remove

    else
      #do nothing
    endif
  endfor

select 'sound_file'
Remove
select 'textGrid_file'

endfor

select all
Remove

writeInfo: "All done!"
