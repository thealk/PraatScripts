# This script takes TextGrids with one tier (silences) as input.
# These TextGrid should:
#	- have been generated from already-truncated .wav files
# 	- contain two types of intervals: those labelled "silent" (silent periods) and those labelled "sounding" (non-silent periods).
#
# This script will calculate the sum of the durations of the "sounding" intervals
#	and deposit them in a csv file
#
# Thea Knowles
# tknowle3@uwo.ca
# July 2018

form Make Selection
	comment Enter Directory
	sentence Directory /Users/thea/Google Drive/PhD Projects/RADI/AnalysisPrep/3_aligned/slow_audio/textgrids_silences/
	sentence Sounding_label sounding
endform

# Output file saved with the .TextGrid files
fileappend "'directory$'duration_of_nonsilences.csv" filename,condition,participant,item,total_dur,'newline$'

Create Strings as file list...  list 'directory$'*.TextGrid
number_files = Get number of strings

for j from 1 to number_files
	select Strings list
	current_token$ = Get string... 'j'
     	Read from file... 'directory$''current_token$'
	filename$ = selected$ ("TextGrid")

	Read from file... 'directory$''filename$'.TextGrid
	select TextGrid 'filename$'

	# Filename convention: slower4x_301_26_1
	sep = index(filename$,"_")
	condition$ = left$(filename$,sep-1)
		rest$ = right$(filename$,length(filename$) - sep)
		#printline 'rest$'
		sep = index(rest$,"_")
		id$ = left$(rest$,sep-1)
		#printline 'id$'
			rest$ = right$(rest$,length(rest$) - sep)
			sep = index(rest$,"_")
			item$ = left$(rest$,sep-1)
			#printline 'device$'

	#printline 'condition$', 'id$', 'item$'
	
	# Get all intervals from Tier 1
	select TextGrid 'filename$'
	numInts = Get number of intervals... 1
	
	# Reset total_dur to 0
	total_dur = 0
	

	# Iterate over intervals
	for i from 1 to numInts
		select TextGrid 'filename$'
		lab$ = Get label of interval... 1 'i'
		
	# If label = sounding
		if lab$ == "sounding"
			
			start = Get start time of interval... 1 'i'
			end = Get end time of interval... 1 'i'

			current_dur = end - start
			total_dur = total_dur + current_dur
		endif

	
	endfor


fileappend "'directory$'duration_of_nonsilences.csv" 'filename$','condition$','id$','item$','total_dur:4','newline$'
endfor

select all
Remove