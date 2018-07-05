# Extract segments of interest from Rainbow Passage
# Goal: 
#	Take force aligned TextGrid and identify segments of interest
#	to extract onto new tier.
#	SOI lookup to be done using text file with idenitifier attached to each word
# 	All SOIs at this stage are word-initial, so script needs to look up word of interest,
#	then take first segment from that word.
#
# Thea Knowles
# Western University 
# January2018
# tknowle3@uwo.ca
#
# Acknowledgements: modified from WOI script in Michael Wagner's McGill Prosody Lab:
# https://github.com/prosodylab/prosodylab.praatscripts/blob/master/WordOfInterest/English/0_annotate_woi.praat



form WOI file information
	comment WOI file must be in same directory as TextGrids
	sentence Woi_filename rpWOI.csv
	sentence Directory /Users/thea/Google Drive/PhD Projects/OnOff_Data/data/3_aligned_RP/
	comment Check this box if you'd like to make a new directory for the edited TextGrids
	boolean Make_directory
	comment Enter the name of the output directory
	sentence Directory_output /Users/thea/Google Drive/PhD Projects/OnOff_Data/data/4_soi/word_init_stops/
	sentence Woi_columnName woiText
	comment Where in the word are the segments of interest?
	choice Soi_type  1
		button Word initial
		button Other
endform
clearinfo

#directory$ = ""

Read Table from comma-separated file... 'directory$''woi_filename$'
woiTab$ = selected$ ("Table")
woiText$ = Get value... 1 'woi_columnName$'
#printline 'woiText$'
space = index(woiText$, " ")
word$ = left$(woiText$, space)
#printline 'word$' 'tab$' 'space'
wordTier = 1
phoneTier = 2


###################################
# PROCEDURE TO ID WORDS OF INTEREST
###################################
procedure parseWoiLine 

woiFound = 0

repeat

space = index(woiText$, " ")
word$ = left$(woiText$, space)
#printline space index: 'space' 'tab$' word: 'word$'

if space = 0
	word$ = woiText$
	space = length(woiText$)
endif

woiKey = index(word$, "_woi") 
#printline woiKey index: 'woiKey'

if woiKey <> 0
#printline woiKey not equal to 0
	woiCount = woiCount + 1
	nextWoi$ = left$(woiText$, (woiKey-1))
#printline nextWoi: 'nextWoi$'
	leng = space - woiKey
	nextLabel$ = mid$(woiText$, (woiKey+1), leng)
	woiFound = 1
endif 

len = length(woiText$)
len = len - space
woiText$ = right$(woiText$,len)
len = length(woiText$)

until (woiFound = 1) or (len=0)

endproc
###################################

##########################################
# PROCEDURE TO EXTRACT WORD INITIAL SEGS
##########################################
procedure extractSoi_initial

#printline
#printline word: 'word$''tab$'int: 'current_woi_interval'

wordStart = start
current_soi_interval = Get interval at time... 'phoneTier' 'wordStart'+0.001
soiStart = wordStart
soiEnd = Get end point... 'phoneTier' 'current_soi_interval'
soi$ = Get label of interval... 'phoneTier' 'current_soi_interval'

Insert boundary... 'soiTier' 'soiStart'
Insert boundary... 'soiTier' 'soiEnd'
soiInt = Get interval at time... 'soiTier' 'soiStart'+0.001
Set interval text... 'soiTier' 'soiInt' 'soi$'

endproc
##########################################

Create Strings as file list...  list 'directory$'*.TextGrid
number_files = Get number of strings

# iterate through the file list

for i from 1 to number_files
	select Strings list
	current_token$ = Get string... 'i'

# reset woiText
	select Table 'woiTab$'
	woiText$ = Get value... 1 'woi_columnName$'
	#printline 'woiText$'
	space = index(woiText$, " ")
	word$ = left$(woiText$, space)

# get the textgrid

	Read from file... 'directory$''current_token$'
	object_name$ = selected$ ("TextGrid")
	select TextGrid 'object_name$'

# insert tier number
	numTiers = Get number of tiers
	soiTier = numTiers+1
	Insert interval tier... soiTier soi
	Insert point tier... soiTier+1 notes

# iterate through the intervals on WORD tier (tier 1)
	wordTier = 1
	numWords = Get number of intervals... 'wordTier'

	# Get first woi
	woiCount = 0
	current_woi_interval = 1
	call parseWoiLine 'woiText$'
	#printline 'woiText$'

	for j from 1 to numWords
		select TextGrid 'object_name$'

		word$ = Get label of interval... 'wordTier' 'j'

		# Convert word to uppercase (why does praat not have a better way of doing this??)
		word$ = replace_regex$ (word$, "[a-z]", "\U&", 0)
   		#printline word: 'word$'

   		if word$ = nextWoi$	

			# WORD START/END TIMES
			start = Get starting point... 'wordTier' 'j'
			end = Get end point... 'wordTier' 'j'

			endprevious = Get starting point... 'soiTier' 'current_woi_interval'

			if endprevious <> start
				#Insert boundary... 'soiTier' 'start'
				current_woi_interval = current_woi_interval + 1
			endif

			#Insert boundary... 'soiTier' 'end'

			#Set interval text... 'soiTier' 'current_woi_interval' 'word$'

			#printline 'nextLabel$' 'word$'
			current_woi_interval = current_woi_interval + 1

			if soi_type = 1
				call extractSoi_initial
				call parseWoiLine 'woiText$'
			else
				printline
				printline Sorry! 
				printline Thea has only written enough of this script to extract word initial segments!
				printline Pick again!
			endif


   		endif  		
		Write to text file... 'directory_output$''object_name$'_wordInitialStops.TextGrid
	endfor

	select all
	minus Table 'woiTab$'
	minus Strings list
	Remove

	printline File completed:  'object_name$'
endfor

select all
Remove
printline
printline All done!
