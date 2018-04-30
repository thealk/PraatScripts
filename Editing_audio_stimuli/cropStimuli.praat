# This script takes a sound file and a TextGrid with a point tier and crops the sound at the first and last point.
# All point tiers have 3 or 4 points (set this below)

directory$ = "/Users/thea/Documents/McRae/Sounds_Oct_30_14/Part1_wav_RMS/2_annotated/"
createDirectory("'directory$'../3_cropped")
Create Strings as file list... list 'directory$'*.wav
nFiles = Get number of strings
for i from 1 to nFiles
	select Strings list
	currentFile$ = Get string... 'i'
	Read from file... 'directory$''currentFile$'
	objectName$ = selected$("Sound")
	Read from file... 'directory$''objectName$'.TextGrid

	# Get the start and end times
	select TextGrid 'objectName$'
	start = Get time of point... 1 1
	

# Change depending on part (part 1: 4 points, part 2: 3 points)
	end = Get time of point... 1 4
	#end = Get time of point... 1 3

	# Crop the sound first
	select Sound 'objectName$'
	Extract part... start end rectangular 1 0
	select Sound 'objectName$'_part
	Save as WAV file... 'directory$'../3_cropped/'objectName$'_cropped.wav

	# Crop the TextGrid next
	select TextGrid 'objectName$'
	Extract part... start end 0
	select TextGrid 'objectName$'_part
	Save as text file... 'directory$'../3_cropped/'objectName$'_cropped.TextGrid

	# clean up
	select all
	minus Strings list
	Remove
endfor

# clean up
select all
Remove