# Script generated for Language & Cognition Lab (Project: How people understand sentences)
# This script is similar to editStim_logTimes. In November 2014, We originally logged the
# sound file start, initial silence duration, utterance onset, verb onset, article onset, final silence
# duration, and total duration for each stimulus.
# In May 2015, we will also log the verb offset and the noun onset.
# This script takes TextGrids with the verb offset and noun onset marked and logs them in
# a .txt file.
# This .txt file will later be manually merged with the existing utterance info logs.
# Assumptions:
#	Verb offset precedes Noun onset
#	There is one point tier containing two points
#
# Thea Knowles
# tknowle3@uwo.ca
# University of Western Ontario
# May, 2015

#directory$ = "/Users/thea/Documents/McRae/Sounds_Oct_30_14/Part1_wav_RMS/5_adjusted_verbOffset-annotated/1_annotated/"
directory$ = "/Users/thea/Documents/McRae/Sounds_Oct_30_14/Part2_wav_RMS/5_adjusted_verbOffset-annotated/1_annotated/"
#fileappend "'directory$'../utteranceinfo-Part2.txt" filename 'tab$' verbEnd 'tab$' nounStart 'newline$'
fileappend "'directory$'../utteranceinfo-Part2.txt" filename 'tab$' nounStart 'newline$'

Create Strings as file list... list 'directory$'*.TextGrid
nFiles = Get number of strings
for i from 1 to nFiles
	select Strings list
	currentFile$ = Get string... 'i'
	Read from file... 'directory$''currentFile$'
	objectName$ = selected$("TextGrid")

	# Get time of first point (verbEnd)
	#verbEnd = Get time of point... 1 1
	# Get time of second point (nounStart)
	nounStart = Get time of point... 1 1

	# Print
	printline 'objectName$': 'tab$'verb: 'verbEnd:2''tab$'noun: 'nounStart:2'

	# Append to file
	#fileappend "'directory$'../utteranceinfo-Part2.txt" filename 'tab$' verbEnd 'tab$' nounStart 'newline$'
	#fileappend "'directory$'../utteranceinfo-Part2.txt" 'objectName$'_adjusted 'tab$' 'verbEnd:4' 'tab$' 'nounStart:4' 'newline$'
fileappend "'directory$'../utteranceinfo-Part2.txt" 'objectName$'_adjusted 'tab$' 'nounStart:4' 'newline$'

	# Clean up
	select all
	minus Strings list
	Remove
	
endfor

select all
Remove
printline
printline All done!