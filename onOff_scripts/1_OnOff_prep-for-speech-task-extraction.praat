# On Off study: Prepare data
# The goals of this script are to:
#	- Iterate over directories containing the On/Off speech data
#	- Create a TextGrid for each .wav with two tiers:
#		- Tier 1: speech task: this is where the boundaries of the rainbow passage, she saw pattie sentence, etc. will be marked
#		- Tier 2: filename: this will contain one interval containing the name of the file.
#			It will only be edited if the filename is incorrect for some reason.
#
# To consider:
#	- Directory structure: One folder for each participant (PD-01 - PD-63)
#		PD-01
#		- PD-01-S0_calib.wav
#		- PD-01-S0_SV1.wav
#		- PD-01-S0.wav
#		- PD-01-S1_calib.wav
#		- PD-01-S1_SV1.wav
#		- PD-01-S1.wav
#	- There are multiple .wav files.
#		_calib.wav: calibration
#		_SV1.wav: sustained vowel
#		-S0.wav: off data (all speech tasks)
#		-S1.wav: on data (all speech tasks)
#	- There are likely some discrepancies in the filenames.
#
# Thea Knowles
# tknowle3@uwo.ca
# December 2017

form Make Selection
	comment Enter input directory. Include final backslash (PC) or forward slash (Mac)
	sentence Directory /Users/thea/Google Drive/PhD Projects/OnOff_Data/
	comment Enter output directory (where the extracted channels and TextGrids will be saved)
	sentence Directory_output /Users/thea/Google Drive/PhD Projects/OnOff_Data/1_prep-for-extraction/
	boolean Mac yes
endform

clearinfo

# Ensure final backslash for main directory if on MAC
last_char$ = right$(directory$,1)
if mac==1
	if last_char$ <> "/"
		directory$ = "'directory$'/"
	endif
else
	if last_char$ <> "\"
		directory$ = "'directory$'\"
	endif
endif

# Iterate over subdirectories
# Each subdir corresponds to a participant
Create Strings as directory list... dirList 'directory$'*
nSubDirs = Get number of strings

for subDir from 1 to nSubDirs
#for subDir from 1 to 10
	select Strings dirList
	current_subDir$ = Get string... 'subDir'
	current_dir$ = "'directory$''current_subDir$'/"
	printline Now looking in: 'current_subDir$'
	Create Strings as file list... fileList 'current_dir$'*.wav
	nFiles = Get number of strings
	#printline 'current_dir$'

# Iterate over file list and look at each .wav
	for file from 1 to nFiles
		# Read in the file
		select Strings fileList
		current_wav$ = Get string... 'file'

		# We are only interested in .wav files that end in S0.wav or S1.wav
		wav_suffix$ = left$(right$(current_wav$, 6),2)
		#printline 'wav_suffix$'

		if wav_suffix$ == "S0" or wav_suffix$ == "S1"

			Read from file... 'current_dir$''current_wav$'
			object_name$ = selected$("Sound")
			printline 	Now reading 'current_wav$'
			select Sound 'object_name$'

			Extract one channel... 1
			select Sound 'object_name$'_ch1
			Save as WAV file... 'directory_output$''object_name$'_ch1.wav

			# Make and save TextGrid for file
			To TextGrid... "speechTask"
			
			# Insert interval text to be filename, which is assigned to 'current_wav$'
			# Set interval text... tier interval text
			select TextGrid 'object_name$'_ch1
			#Set interval text... 2 1 'current_wav$'

			# Save 
			Write to text file... 'directory_output$''object_name$'_ch1.TextGrid

			select all
			minus Strings dirList
			minus Strings fileList
			Remove
		endif


		


	endfor
	select Strings fileList
	Remove
endfor

select all
Remove

printline All done!