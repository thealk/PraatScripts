# FMAmp 2017 Set up script
# This script will iterate over the contents of a directory 
# and look in each participant folder (labeled PD01, PD02, ...PD10, etc).
# It will open all .wav files, create a TextGrid with five labeled interval tiers
# for each, and save the resulting Textgrid in a directory, Analysis/Textgrids.
# It will then extract both channels of the .wav file and save the left channel
# in Analysis/Headset_mic, and save the right channel in Analysis/Table_mic
#
# Problems:
#	This script takes a long time to execute
#	Future solutions: Is there a way to extract .wav duration (for TextGrid creation)
#		without reading in the file?
#
# Thea Knowles
# tknowle3@uwo.ca
# December 2017

form Make Selection
	comment Enter Directory
	sentence Directory /Volumes/FMAMP/FMAmp2017/Audio_backup/Mic_Headset_and_2m/
	sentence Directory_TG /Volumes/FMAMP/FMAmp2017/Analysis/TextGrids/
	sentence Directory_table_mic /Volumes/FMAMP/FMAmp2017/Analysis/Table_mic/
	sentence Directory_headset_mic /Volumes/FMAMP/FMAmp2017/Analysis/Headset_mic/
endform

clearinfo

# Ensure final backslash for main directory
last_char$ = right$(directory$,1)
if last_char$ == "/"
	#printline All set!
else
	#printline Adding backslash to 'directory$'...
	directory$ = "'directory$'/"
	#printline New directory: 'directory$'
endif

# Iterate over subdirectories
# Each subdir corresponds to a participant
Create Strings as directory list... dirList 'directory$'*
nSubDirs = Get number of strings

#for subDir from 1 to nSubDirs
for subDir from 20 to nSubDirs
	select Strings dirList
	current_subDir$ = Get string... 'subDir'
	current_dir$ = "'directory$''current_subDir$'/"
	printline Now looking in: 'current_subDir$'
	Create Strings as file list... fileList 'current_dir$'*.wav
	nFiles = Get number of strings

	for file from 1 to nFiles
		# Read in the file
		select Strings fileList
		current_wav$ = Get string... 'file'
		Read from file... 'current_dir$''current_wav$'
		object_name$ = selected$("Sound")
		printline 	Now reading 'current_wav$'
		select Sound 'object_name$'

		# Make and save TextGrid for file
		To TextGrid... "noise_condition task sentence snr notes"
		Write to text file... 'directory_TG$''object_name$'.TextGrid

		# Split into channels and save separately
		#	ch1: Headset_mic
		#	ch2: Table_mic

		select Sound 'object_name$'
		Extract all channels
		select Sound 'object_name$'_ch1
		Save as WAV file... 'directory_headset_mic$''object_name$'_ch1.wav
		select Sound 'object_name$'_ch2
		Save as WAV file... 'directory_table_mic$''object_name$'_ch2.wav

		select Sound 'object_name$'
		plus TextGrid 'object_name$'
		Remove
	endfor
	select Strings fileList
	Remove
endfor

select all
Remove

printline All done!
