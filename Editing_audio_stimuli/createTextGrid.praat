# This script takes a directory of wav files and generates TextGrids with one point tier for each wav.

form Enter directory of .wav files
	sentence Directory /Volumes/SeagateBackupPlusDrive/11_McRae/2_AspectExperiment/Sound files/test/1_individual/
endform

Create Strings as file list... list 'directory$'*.wav
nFiles = Get number of strings
for i from 1 to nFiles
	select Strings list
	currentFile$ = Get string... 'i'
	Read from file... 'directory$''currentFile$'
	objectName$ = selected$("Sound")
	select Sound 'objectName$'
	To TextGrid... edit edit
	select TextGrid 'objectName$'
	Write to text file... 'directory$''objectName$'.TextGrid
endfor
select all
Remove
printline All done.