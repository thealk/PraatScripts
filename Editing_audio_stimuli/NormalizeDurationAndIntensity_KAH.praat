
form NORMALIZE SENTENCES
	sentence Directory_to_read_from: /Users/thea/Documents/11_McRae/PirateStudy/Soundfiles/Soundfiles/1_IndividualSoundfiles/
	sentence Directory_to_save: /Users/thea/Documents/11_McRae/PirateStudy/Soundfiles/Soundfiles/3_Edited/
	comment Normalize:
	boolean Intensity: 1
	boolean Art1_Duration: 1
	boolean Agent_Duration: 1
	boolean Verb_Duration: 1
	boolean Art2_Duration: 1
	boolean Obj_Duration: 1
	boolean Read_TextGrid: 1
endform

# remove open files
clearinfo
select all
nocheck Remove

# create table to keep track of durations
results = Create Table with column names... Results 1  File Art1Label AgentLabel VerbLabel  Art2Label ObjLabel SentenceDuration Art1Duration AgentDuration VerbDuration Art2Duration ObjDuration

# get files in a directory
string = Create Strings as file list... files  'directory_to_read_from$'*.wav
numberOfSounds = Get number of strings

if numberOfSounds = 0
	pause You have no files in the directory you selected. Continue?
endif

for i to numberOfSounds
	select string
	file$ = Get string... i
	file'i'$ = file$
	file'i' = Read from file... 'directory_to_read_from$''file$'
	textGrid$ = file'i'$ - ".wav" + ".TextGrid"
	sentenceDuration'i' = Get total duration

	if fileReadable(directory_to_save$ + textGrid$)
		Read from file... 'directory_to_save$''textGrid$'
	else
		startWord = rindex(file$, "_")
		endWord = rindex(file$, ".")		
		word$ = mid$(file$, startWord + 1, endWord - startWord -1) 
		textGrid'i' = To TextGrid... word 
		Insert boundary... 1 sentenceDuration'i'-0.0001
		Insert boundary... 1 sentenceDuration'i'-0.400
		Insert boundary... 1 sentenceDuration'i'-0.800
		Insert boundary... 1 sentenceDuration'i'-0.1200
		Insert boundary... 1 sentenceDuration'i'-0.1600
		Insert boundary... 1 sentenceDuration'i'-sentenceDuration'i'+0.0001
		Set interval text... 1 2  art1
		Set interval text... 1 3  agent
		Set interval text... 1 4  verb
		Set interval text... 1 5  art2
		Set interval text... 1 6  object
		plus file'i'
		Edit
		pause Define the start of the label, close the Window, then press Continue
		select textGrid'i'
	endif

	label_art1$ = Get label of interval... 1 2
	label_agent$ = Get label of interval... 1 3
	label_verb$ = Get label of interval...  1 4
	label_art2$ = Get label of interval... 1 5
	label_obj$ = Get label of interval...  1 6


	art1Duration'i' = Get end point... 1 2
	
	agentStart'i' = Get start point... 1 3
	agentEnd'i' = Get end point... 1 3
	agentDuration'i' = agentEnd'i' - agentStart'i'
	
	verbEnd'i' = Get end point... 1 4
	#verbDuration'i'= agentEnd'i' - verbEnd'i'
	verbDuration'i'= verbEnd'i' - agentEnd'i'

	art2End'i' = Get end point... 1 5
	#art2Duration'i' = verbEnd'i' - art2End'i'
	art2Duration'i' = art2End'i' - verbEnd'i'
		
	objEnd'i' = Get end point... 1 6
	#objDuration'i' = art2End'i' - objEnd'i'
	objDuration'i' = objEnd'i' - art2End'i'

	Write to text file... 'directory_to_save$''textGrid$'
	select results
	Set string value... i File 'file$'
	Set string value... i Art1Label 'label_art1$'
	Set string value... i AgentLabel 'label_agent$'
	Set string value... i VerbLabel 'label_verb$'
	Set string value... i Art2Label 'label_art2$'
	Set string value... i ObjLabel 'label_obj$'

	Set numeric value... i Art1Duration art1Duration'i'
	Set numeric value... i AgentDuration agentDuration'i'
	Set numeric value... i VerbDuration verbDuration'i'
	Set numeric value... i Art2Duration art2Duration'i'
	Set numeric value... i ObjDuration objDuration'i'
	Set numeric value... i SentenceDuration sentenceDuration'i'
	
	if (i < numberOfSounds)
		Append row
	endif
endfor

Write to table file... 'directory_to_save$'results.txt
art1DurationMean = Get mean... Art1Duration
agentDurationMean = Get mean... AgentDuration
verbDurationMean = Get mean... VerbDuration
art2DurationMean = Get mean... Art2Duration
objectDurationMean = Get mean... ObjDuration
sentenceDurationMean = Get mean... SentenceDuration


art1Start = 0
art1End = 'art1DurationMean'
agentStart = 'art1End'
agentEnd = 'agentStart' + 'agentDurationMean'
verbStart = 'agentEnd'
verbEnd = 'verbStart' + 'verbDurationMean'
art2Start = 'verbEnd'
art2End = 'art2Start' + 'art2DurationMean'
objStart = 'art2End'
objEnd = 'objStart' + 'objectDurationMean'

printline 'file$'
printline Art1: 'art1Start''tab$''art1End'
printline Agent: 'agentStart''tab$''agentEnd'
printline Verb: 'verbStart''tab$''verbEnd'
printline Art2: 'art2Start''tab$''art2End'
printline Object: 'objStart''tab$''objEnd'
printline Sentence: 'sentenceDurationMean'
printline



for i to numberOfSounds
	select file'i'

	if intensity
		Scale intensity... 70
	endif

	manipulation = To Manipulation... 0.01 75 600
	Extract duration tier

	if art1_Duration
		art1DurationRatio = art1DurationMean/art1Duration'i'
	else
		art1DurationRatio = 1
	endif

	if agent_Duration
		agentDurationRatio = agentDurationMean/agentDuration'i'
	else
		agentDurationRatio = 1
	endif

	if verb_Duration
		verbDurationRatio = verbDurationMean/verbDuration'i'
	else
		verbDurationRatio = 1
	endif

	if art2_Duration
		art2DurationRatio = art2DurationMean/art2Duration'i'
	else	
		art2DurationRatio = 1
	endif

	if obj_Duration
		objDurationRatio=objectDurationMean/objDuration'i'
	else
		objDurationRatio = 1
	endif

	Add point... 0 art1DurationRatio
	Add point... agentStart'i'-0.0001 art1DurationRatio
	Add point... agentStart'i' agentDurationRatio
	Add point... agentEnd'i'-0.0001 agentDurationRatio
	Add point... agentEnd'i' verbDurationRatio
	Add point... verbEnd'i'-0.0001 verbDurationRatio
	Add point... verbEnd'i' art2DurationRatio
	Add point... art2End'i'-0.0001 art2DurationRatio
	Add point... art2End'i' objDurationRatio
	Add point... objEnd'i' objDurationRatio
	

	plus manipulation
	Replace duration tier
	select manipulation
	Get resynthesis (overlap-add)

	file$ = file'i'$
	Write to WAV file... 'directory_to_save$''file$'


endfor

select all
minus results
Remove