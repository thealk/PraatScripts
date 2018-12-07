# Randomly check files
# This script will randomly select n .wav and corresponding TextGrids and open them in Praat

n = 10
dir_wav$ = "/Volumes/radi/1_audio_prep/1_alignment/1_dfd_stops/"
dir_tg$ = "/Volumes/radi/1_audio_prep/2_aligned_textgrids/1_dfd_stops/"
dir_comments$ = "/Volumes/radi/1_audio_prep/"

comments_path$ = "'dir_comments$'random_files_checks_log.csv"
if fileReadable(comments_path$) == 0
	fileappend "'comments_path$'" filename,date,concern,comment,followup'newline$'
endif

Create Strings as file list... list 'dir_wav$'*wav
Randomize

for f from 1 to n
	select Strings list
	current_file$ = Get string... f
	Read from file... 'dir_wav$''current_file$'
	name$ = selected$("Sound")
	Read from file... 'dir_tg$''name$'.TextGrid

	select Sound 'name$'
	plus TextGrid 'name$'
	Edit

	beginPause("Inspect file")
		comment("Do you have any major concerns with this file?")
		choice("Concern",1)
			option("No")
			option("Yes")
		comment("Make a comment about this file")
		sentence("Comment","")
	clickedEnd = endPause("Next",1)

	if comment$ <> ""
		date$ = date$ ()
		fileappend "'comments_path$'" 'name$','date$','concern','comment$','newline$'
	endif

	editor TextGrid 'name$'
	Close
	endeditor

	
endfor