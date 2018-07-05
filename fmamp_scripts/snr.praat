## Measuring Speech-to-Noise Levels in the DFD for the Speech in Noise study
# This script will take a TextGrid containing a tier "snr". This tier contains: 
#	intervals of speech (words of interest) labeled "sp"
#	intervals of silence labeled "sil"
#	blank intervals
# This script uses the TextGrids to look at the right microphone .wav files in the DFD
# For each speaker file, the script logs the intensity of each speech, silence interval and logs them to an output file
# It them averages the intensity of each speaker's speech intensity, noise/silence intensity level
# and subtracts the silence average from the speech average to get a speech to noise ratio for each individual.

# MODIFIED VERSION 07/2017 for FMAMP STUDY
# For three of four device conditions (ND, CV, WA120) this script should work okay as is 
#	(though will need to add parse for task, SIT vs Pic). 
# For 351VR, however, will need more mod because calculating SNR will require 2 files: 
#	1. the file containing the 351VR receiver input and
#	2. the file from the table mic to calculate the background noise levels

form Confirm
	sentence Directory_TG /Volumes/FMAMP/FMAmp2017/Analysis/TextGrids/
	comment Wav Directory must be for the table mic or the 351VR receiver. 
	comment If the latter, edit the script below to account for filename format.
	sentence Directory_wav /Volumes/FMAMP/FMAmp2017/Analysis/Headset_mic/
	comment Enter the tier number containing the intervals "sil" & "sp"
	positive Snr_tier 4
	comment Enter the tier number containing the noise condition
	positive noise_tier 1
	comment Enter the tier number containing the speech task
	positive task_tier 2
	boolean Ready 1
endform

# Output file saved with the .wav files
fileappend "'directory_wav$'SNR_info_fmamp.csv" filename,Participant,Noise,Device,Task,interval,start,end,dur,intensity'newline$'

Create Strings as file list...  list 'directory_wav$'*.wav
number_files = Get number of strings
for j from 1 to number_files
	select Strings list
	current_token$ = Get string... 'j'
     	Read from file... 'directory_wav$''current_token$'
	sound_name$ = selected$ ("Sound")

######################################
# CHECK HERE TO TOGGLE 351VR VS REST #
######################################
# TextGrid name is identical except excludes suffix "_ch2"
	tg_name$ = left$(sound_name$,length(sound_name$) - 4)
# And for 351VR, tg name is the same
#	tg_name$ = sound_name$
######################################

	Read from file... 'directory_TG$''tg_name$'.TextGrid
	select Sound 'sound_name$'

	# Participant ID
	sep = index(sound_name$,"_")
	study$ = left$(sound_name$,sep-1)
		rest$ = right$(sound_name$,length(sound_name$) - sep)
		#printline 'rest$'
		sep = index(rest$,"_")
		id$ = left$(rest$,sep-1)
		#printline 'id$'
			rest$ = right$(rest$,length(rest$) - sep)
			sep = index(rest$,"_")
			device$ = left$(rest$,sep-1)
			printline 'device$'

	#printline 'id$'


	# INTENSITY SETTINGS - no filtering
	minPitch = 100
	timeStep_int = 0
	subtractMean$ = "yes"
	To Intensity... minPitch timeStep_int subtractMean$

	select TextGrid 'tg_name$'
#printline 'snr_tier'
	numInts = Get number of intervals... 'snr_tier'
	for i from 1 to numInts
		select TextGrid 'tg_name$'
		lab$ = Get label of interval... snr_tier 'i'
		
		if lab$ == "sp" or lab$ == "sil"
			start = Get starting point... snr_tier 'i'
			end = Get end point... snr_tier 'i'
			dur = end - start

			noiseInt = Get interval at time... noise_tier start+0.001
			noiseCond$ = Get label of interval... noise_tier noiseInt

			taskInt = Get interval at time... task_tier start+0.001
			task$ = Get label of interval... task_tier taskInt

# Get Intensity
			select Intensity 'sound_name$'
			intensity = Get mean... start end dB
			
# Print out results
	fileappend "'directory_wav$'SNR_info_fmamp.csv" 'sound_name$','id$','noiseCond$','device$','task$','lab$','start','end','dur','intensity''newline$'
		endif
	endfor

# Clean up
	select all
	minus Strings list
	Remove
endfor
