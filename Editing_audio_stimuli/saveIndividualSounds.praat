# This script takes .wav file and a corresponding TextGrid with intervals marking the boundaries of
# each utterance, labeled with the names of those utterances.  The script will iterate through the 
# tier with the utterance boundaries. When it finds an interval with a label, it will extract the TextGrid
# interval boundaries and the sound at those boundaries (time from 0) and save them as individual files
# with the name identified in the TextGrid interval label.
# The script also adds a tier to the individual TextGrids to allow for annotating parts of the utterance later
#
# Thea Knowles
# tknowle3@uwo.ca
# Western University
# January, 2015

form Make Selection
	comment Enter directory of Input files (.wav, TextGrids). Include the final forward slash (/)
	sentence Directory_input /Users/thea/Documents/11_McRae/2_AspectExperiment/Sound files/0_original/
	comment Enter director of Output files (individual .wav, TextGrids to be generated)
	sentence Directory_output /Users/thea/Documents/11_McRae/2_AspectExperiment/Sound files/1_individual/
	comment Enter the tier containing the interval labels to be used as file names
	positive Name_tier 1
endform

Create Strings as file list... myList 'directory_input$'*.TextGrid
nFiles = Get number of strings

for i from 1 to nFiles
	select Strings myList
	currentFile$ = Get string... 'i'
	Read from file... 'directory_input$''currentFile$'
	objectName$ = selected$("TextGrid")
	Read from file... 'directory_input$''objectName$'.wav

	select TextGrid 'objectName$'
	nInts = Get number of intervals... name_tier
	for n from 1 to nInts
		select TextGrid 'objectName$'
		lab$ = Get label of interval... name_tier n
		if lab$<>""
			start = Get start point... name_tier n
			end = Get end point... name_tier n
			Extract part... start end 0
			Rename... 'lab$'
			# Removed writing individual TextGrids: no longer used
			# Write to text file... 'directory_output$''lab$'.TextGrid
			Insert point tier... 2 utterance
			select Sound 'objectName$'
			Extract part... start end rectangular 1.0 0
			Rename... 'lab$'
			Save as WAV file... 'directory_output$''lab$'.wav
			select Sound 'lab$'
			plus TextGrid 'lab$'
			Remove
		endif
	endfor
endfor

select all
Remove
printline All done!
