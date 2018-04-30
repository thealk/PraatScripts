# Goals: Edit sound files for PD sentence processing eye tracking stimuli
# 	Record the duration between the onset of the sound and the onset of the verb
# 	Record the duration between the onset of the verb and the onset of the article in the complement
# 	Standardize the start time such that the duration to the onset of the article is the same for each sound. Do this by adding silence
# 	Add silence at the end and record total duration of the sound
# 
# This script will take a TextGrid with a point tier and measure the distance between
# the first and second points. It will print this distance to the screen.
# For part 1: 4 points (verb is point 2)
# For part 2: 3 poitns (verb is point 1)
# Set part below:
#
# Thea Knowles
# tknowle3@uwo.ca
# University of Western Ontario
# November, 2014

form Make Selection
	comment Enter directory. Don't forget the final forward slash (/).
	sentence Directory /Volumes/SeagateBackupPlusDrive/11_McRae/1_PDEyetracking/Sounds_Oct_30_14/test/
	comment This script will normalize the onset of an audio file to a given time point 
	comment by adding silence.
	comment Which points on the TextGrid denote the verb and the article?
	comment Enter a number corresponding to the point position:
	positive Verb 2
	positive Article 3
	comment This script marks onset and offset of the utterance as the start and end of the audio.
endform


createDirectory("'directory$'../4_adjusted/")
fileappend "'directory$'../utteranceInfo.txt" filename 'tab$' start 'tab$' initialSilDur 'tab$' utteranceStart 'tab$' verbStart 'tab$' articleStart 'tab$' finalSilDur 'tab$' totalDur 'newline$'

Create Strings as file list... list 'directory$'*.TextGrid
nFiles = Get number of strings
for i from 1 to nFiles
	select Strings list
	currentFile$ = Get string... 'i'
	Read from file... 'directory$''currentFile$'
	objectName$ = selected$("TextGrid")

	# Get start of utterance (should be 0), onset of verb, onset of article, end of utterance
	select TextGrid 'objectName$'

utteranceStart = Get start time
utteranceEnd = Get end time
verbStart = Get time of point... 1 verb
articleStart = Get time of point... 1 article

# Commented out previous version that used point numbers either 1 or 2 to denote verb (depending on whether this was the part 1 "she will" trials or the part 2 "look at the" trials.
#	if pointOfInterest == 2
#		utteranceStart = Get time of point... 1 1
#		verbStart = Get time of point... 1 2
#		articleStart = Get time of point... 1 3
#		utteranceEnd = Get time of point... 1 4
#	elsif pointOfInterest == 1
#		utteranceStart = Get time of point... 1 1
#		verbStart = Get time of point... 1 1
#		articleStart = Get time of point... 1 2
#		utteranceEnd = Get time of point... 1 3
#	else
#		printline PointOfInterest must be 1 or 2.
#		x
#	endif

	# Get the duration between the utterance start and the verb onset (the difference between the points)
	# The greatest difference is 71ms. We want the difference between the start of the sound and the verb onset to be the same.
	# We'll round up to 750 ms. The time needed to get to 0.75 seconds will be the duration of silence to be added at the beginning.
	diff = verbStart - utteranceStart

	#if part == 1
		silDur = 0.75-diff
	#elsif part == 2
	#	silDur = 0.75
	#endif

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
	newVerbStart = 'verbStart' + 'silDur'
	newArticleStart = 'articleStart' + 'silDur'

	# Save the new sound
	select Sound chain
	totalDur = Get total duration
	Save as WAV file... 'directory$'../4_adjusted/'objectName$'_adjusted.wav
	
	printline utt: 'utteranceStart:2' 'tab$' V: 'verbStart:2' 'tab$' artStart: 'articleStart:2' 'tab$' diff: 'diff:2' 'tab$' silDur: 'silDur:2'

	# Format:
	# fileappend "'directory$'../utteranceInfo.txt" filename 'tab$' start 'tab$' initialSilDur 'tab$' utteranceStart 'tab$' verbStart 'tab$' articleStart 'tab$' finalSilDur 'tab$' totalDur 'newline$'
	fileappend "'directory$'../utteranceInfo.txt" 'objectName$'_adjusted 'tab$' 0 'tab$' 'silDur:2' 'tab$' 'newUtteranceStart:4' 'tab$' 'newVerbStart:4' 'tab$' 'newArticleStart:4' 'tab$' 0.3 'tab$' 'totalDur:4' 'newline$'

	# Clean up
	select all
	minus Strings list
	Remove

endfor

select all
Remove
printline
printline All done`