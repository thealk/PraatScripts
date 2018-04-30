# Goals: Edit sound files for PD sentence processing eye tracking stimuli
# Modified version for Aspect Project
# 	Record the duration between the onset of the sound and the onset of the aux verb
# 	Standardize the start time such that the duration to the onset of the article is the same for each sound. Do this by adding silence
# 	Add silence at the end and record total duration of the sound
# 
# This script will take a TextGrid with a point tier and log the times. 
# 5 points (Aux onset is point 1)
#
# Thea Knowles
# tknowle3@uwo.ca
# University of Western Ontario
# November, 2014
# Updated February, 2016 for Aspect Experiment

# If ready=1 silence will be inserted and the files will be resaved. If ready=0 there will only be a printout of the utterance times.
ready=1
directory$ = "/Users/thea/Documents/11_McRae/2_AspectExperiment/Sound files/2_RMS/1_annotated/"
createDirectory("'directory$'../4_adjusted/")

fileappend "'directory$'../utteranceInfo.txt" filename 'tab$' start 'tab$' initialSilDur 'tab$' utteranceStart 'tab$' auxStart 'tab$' verbStart 'tab$' artStart 'tab$' nounStart 'tab$' finalSilDur 'tab$' totalDur 'newline$'


Create Strings as file list... list 'directory$'*.TextGrid
nFiles = Get number of strings
for i from 1 to nFiles
	select Strings list
	currentFile$ = Get string... 'i'
	Read from file... 'directory$''currentFile$'
	objectName$ = selected$("TextGrid")

	# Get start of utterance (should be 0), onset of verb, onset of article, end of utterance
	select TextGrid 'objectName$'

	numPoints = Get number of points... 1
	utteranceStart = 0
	auxStart = Get time of point... 1 1
	auxEnd = Get time of point... 1 2
	verbStart = Get time of point... 1 3
	articleStart = Get time of point... 1 4
	nounStart = Get time of point... 1 5
	utteranceEnd = 0

	# Add silence to the beginning of each utterance such that the onset of the aux occurs at 750ms. 
	diff = auxStart

if ready==1
		silDur = 0.75-auxStart

	# Create the silence with the following command:
		# Create Sound from formula... name channel start end samplingFrequency formula
		# default sampling frequency (sf) = 44100 hz
	do ("Create Sound from formula...", "silStart", 1, 0, 'silDur', 44100, "0")
	
	# Open the cropped sound (this is so the sounds appear in the order you want to concatenate them)
	Read from file... 'directory$''objectName$'.wav

	# Create 300 ms of silence at the end
	do ("Create Sound from formula...", "silEnd", 1, 0, 0.3, 44100, "0")	
	# Combine: silenceStart, cropped stimuli, silenceEnd
	# The sounds must be in the correct order
	select Sound silStart
	plus Sound 'objectName$'
	plus Sound silEnd

	Concatenate

	# New times:
	# Start = 0
	newUtteranceStart = 'utteranceStart' + 'silDur'
	newAuxStart = 'auxStart' + 'silDur'
	newVerbStart = 'verbStart' + 'silDur'
	newArticleStart = 'articleStart' + 'silDur'
	newNounStart = 'nounStart' + 'silDur'

	# Save the new sound
	select Sound chain
	totalDur = Get total duration
	Save as WAV file... 'directory$'../4_adjusted/'objectName$'_adjusted.wav
	To TextGrid... time time
		Insert point... 1 'newAuxStart' A1
		Insert point... 1 'newVerbStart' V1
		Insert point... 1 'newArticleStart' V2
		Insert point... 1 'newNounStart' N
	Save as text file... 'directory$'../4_adjusted/'objectName$'_adjusted.TextGrid

endif
	
	printline utt: 'utteranceStart:2' 'tab$' Aux: 'auxStart:2' 'tab$' V: 'verbStart:2' 'tab$' artStart: 'articleStart:2' 'tab$' nounStart: 'nounStart:2' 'tab$' nPoints: 'numPoints'

	# Format:
	# fileappend "'directory$'../utteranceInfo.txt" filename 'tab$' start 'tab$' initialSilDur 'tab$' utteranceStart 'tab$' auxStart 'tab$' verbStart 'tab$' artStart 'tab$' nounStart 'tab$' finalSilDur 'tab$' totalDur 'newline$'
	fileappend "'directory$'../utteranceInfo.txt" 'objectName$'_adjusted 'tab$' 0 'tab$' 'silDur:2' 'tab$' 'newUtteranceStart:4' 'tab$' 'newAuxStart:4' 'tab$' 'newVerbStart:4' 'tab$' 'newArticleStart:4' 'tab$' 'newNounStart:4' 'tab$' 0.3 'tab$' 'totalDur:4' 'newline$'

	# Clean up
	select all
	minus Strings list
	Remove

endfor

select all
Remove
printline
printline All done