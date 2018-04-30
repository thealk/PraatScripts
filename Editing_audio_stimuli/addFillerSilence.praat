# Add 300ms of silence to beginning, end of sound files
# Used for fillers in Aspect Study
# Rationale: In experimental stimuli, goal was to have 750 seconds to onset of aux, so add
# 	n ms of silence to achieve that for each file. This was ~300ms on average. 300ms of silence was
#	also added to the end of each file.
# Fillers are not annotated, but 300ms of silence will be added to beginning & end of each sound file
#	to make them comparable to the experimental stimuli

dir$ = "/Users/thea/Documents/11_McRae/2_AspectExperiment/Sound files/2_RMS/Filler/"
createDirectory("'dir$'silenceAdded")



Create Strings as file list... list 'dir$'*.wav
nFiles = Get number of strings
for i from 1 to nFiles

	# Create 300ms of silence, named "sil"
	# To combine silence & sound, files must be in correct order (silence, sound, silence)
	do ("Create Sound from formula...", "silStart", 1, 0, 0.3, 44100, "0")

	# Read stimuli
	select Strings list
	currentFile$ = Get string... 'i'
	Read from file... 'dir$''currentFile$'
	objectName$ = selected$("Sound")

	# Create end silence
	do ("Create Sound from formula...", "silEnd", 1, 0, 0.3, 44100, "0")

	# Combine
	select Sound silStart
	plus Sound 'objectName$'
	plus Sound silEnd

	Concatenate

	# Save
	select Sound chain
	Save as WAV file... 'dir$'silenceAdded/'objectName$'_adjusted.wav

	printline 'objectName$'

	# Clean up
	select all
	minus Strings list
	Remove
endfor