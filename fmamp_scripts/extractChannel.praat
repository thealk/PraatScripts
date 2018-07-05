# Extract left, right channel for FMAmp study

form Enter the directory
	comment Is script in same directory as files?
	boolean SameDirectory 1
	comment If not, enter directory below
	sentence Directory /Users/TVS/TVS/Datasets/Wildcat Diapix Conversation English/Native English Speakers1/all/
	boolean MakeDirectory 1
endform

if sameDirectory = 1
	directory$ = ""
endif

if makeDirectory
	createDirectory("'directory$'0_original")
	createDirectory("'directory$'1_extractedUtterances")
endif


Create Strings as file list... list 'directory$'*.wav
num_files = Get number of strings
for istring from 1 to num_files
	select Strings list
	current_token$ = Get string... 'istring'
	Read from file... 'directory$''current_token$'
	object_name$ = selected$("Sound")
	#tgName$ = "'object_name$'.TextGrid"
	#Read from file... 'directory$''tgName$'

	# Headset mic: Channel 1
	select Sound 'object_name$'
	Extract one channel... 1
	ch1$ = "'object_name$'_ch1"
	Save as WAV file... 'directory$'1_extractedUtterances/'ch1$'.wav
	
	# Table mic: Channel 2
	select Sound 'object_name$'
	Extract one channel... 2
	ch2$ = "'object_name$'_ch2"
	Save as WAV file... 'directory$'1_extractedUtterances/'ch2$'.wav

	select all
	minus Strings list
	minus Sound 'object_name$'
	Remove

	
	printline 'object_name$'
	#select Sound 'object_name$'
	#system mv "'directory$''istring$'" 'directory$'0_original/'istring$'

	select all
	minus Strings list
	Remove
endfor