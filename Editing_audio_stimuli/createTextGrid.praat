# This script takes a directory of wav files and generates TextGrids with one point tier for each wav.

form Enter directory of .wav files
	sentence Directory /Users/theaknowles/Documents/radi_audio_soi/calibration/0_calibration/
endform

Create Strings as file list... list 'directory$'*.wav
nFiles = Get number of strings
for i from 1 to nFiles
	select Strings list
	currentFile$ = Get string... 'i'
	Read from file... 'directory$''currentFile$'
	objectName$ = selected$("Sound")
	select Sound 'objectName$'

# Syntax: tier names in first set of "", tiers you wish to be point tiers in second set of ""
	To TextGrid: "calib", ""

	select TextGrid 'objectName$'
	Write to text file... 'directory$''objectName$'.TextGrid
endfor
select all
Remove
printline All done.