################################################################
## This script will calculate the following measurements for a fricative segment 
##  from a set of soundfiles and corresponding textgrids:
##
##		duration
##		intensity
##		COG 
##		COG standard deviation
##		skewness
##		kurtosis
##		spectral slope		
##
## It will output the results to a text file. 
##
## Thea Knowles
## McGill 2013
## thea.knowles@gmail.com
################################################################


##  Specify the directory containing your sound files in the next line:

form Make Selection
	comment Is the script in the same folder as the soundfiles?
	boolean SameFolder 
	comment If not, enter directory of TextGrids
	comment ***Include final backslash in folder names***
	sentence Directory  /Users/mcgillLing/9_PraatTutorial/data/
	comment tier for segment label
	positive Seg_tier 4
	comment tier for word label
	positive Word_tier 2
	#sentence Label S
endform

clearinfo

if sameFolder
	directory$ = ""
endif

# set up the .txt file column headers
# fileappend adds text to a file. If the file doesn't exist already, it will be created.
# Since this is outside of the for-loop that looks at each file, the following lines will only happen once after running the script
# These lines thus should be used to set up your column headers

	fileappend "'directory$'spectral_info.txt" filename 'tab$' word 'tab$' segment 'tab$' word start 'tab$' 'word end 'tab$' seg start 'tab$' seg midpoint 'tab$' seg end 'tab$' seg dur 'tab$' intensity (dB) 'tab$'
	fileappend "'directory$'spectral_info.txt" COG 'tab$' COG sd 'tab$' skewness 'tab$' kurtosis 'tab$' slope(dB) 'newline$'
        	
# get the sound and textgrid files from the directory to work on
# Here I'm using the variable name "list" to refer to my string list (instead of "myList" as we've seen before)

Create Strings as file list...  list 'directory$'*.wav
number_files = Get number of strings

# iterate through the file list

for file from 1 to number_files
	select Strings list
	current_token$ = Get string... 'file'

# get the sound
# object_name refers to the name of the file without its extension
# look at an object in the Praat window; you'll see this is how it's parsed.

     	Read from file... 'directory$''current_token$'
	object_name$ = selected$ ("Sound")

# get the textgrid

	Read from file... 'directory$''object_name$'.TextGrid

# get the intensity object
	
	select Sound 'object_name$'
	To Intensity... 100 0 yes

# get the pitch object
# We don't actually need the pitch object for this analysis since we won't be looking at f0.
	# pitch floor and ceiling (Hz)
	#floor = 75
	#ceiling = 600
	#step_size = 0.01

	#select Sound 'object_name$'
	#To Pitch... step_size floor ceiling

# Spectrogram settings
# Window length (broadband=0.005, narrowband=0.030)
	win_len = 0.015

# Max frequency
	max_freq = 10000

# Time step (distance between frames)
	time_step = 0.005

# Frequency step (distance between bins)
	freq_step = 20

														
	select Sound 'object_name$'
	To Spectrogram... win_len max_freq time_step freq_step Gaussian

# find the inteval with the right label

	select TextGrid 'object_name$'
	number_of_intervals = Get number of intervals... seg_tier

	# Here the variable name for each interval is 'b'. I want it to be short because I'll be referring
	# to it a lot and don't want to have to type a long name every time.
	
     	for i from 1 to number_of_intervals
		select TextGrid 'object_name$'
          	interval_label$ = Get label of interval... seg_tier 'i'

	# This is saying "if the interval is not blank, do something"
	# This will thus look at all non-empty intervals on the tier
		if interval_label$ <> ""			

# get the segment duration
		
			seg_start = Get starting point... seg_tier 'i'
															
			seg_start = seg_start+0.00001	
			seg_number = Get interval at time... seg_tier seg_start
			word_number = Get interval at time... word_tier seg_start											
			word_label$ = Get label of interval... word_tier word_number
														
               		seg_end   = Get end point... seg_tier 'i'
               		duration = (seg_end - seg_start)
			mid = seg_start + (duration/2)

# get the word start for the word containing the segment
			seg_word_start = Get starting point... word_tier word_number
			seg_word_end = Get end point... word_tier word_number

# get the word duration --> ORIG WORD DUR!
# if you are looking at segments at either the beginning or end of the word
# use seg_start or seg_end instead of word_start or word_end for this part
		word_duration = (seg_end - seg_word_start)
		#word_duration = (word_end - seg_word_start)

# get average intensity of the segment
			select Intensity 'object_name$'
			intensity = Get mean... seg_start seg_end dB

# clean up
			select TextGrid 'object_name$'
			plus Sound 'object_name$'
			Extract non-empty intervals... seg_tier no

			select Sound 'interval_label$'
			
# sample the spectrogram frames

			t = mid

# get analysis
# For a power of 2, the weighting is done by the power spectrum (default)
# For a power of 1, the weighting is done by the absolute spectrum
			select Spectrogram 'object_name$'
			To Spectrum (slice)... t
			
			cog = Get centre of gravity... 2
			sd = Get standard deviation... 2
			sk = Get skewness... 2
			ku = Get kurtosis... 2
			mo = Get central moment... 3 2

			# New cue: spectral slope, calculated by Get band energy difference
			# Settings: standard:
			# Low band floor (Hz): 0
			# Low band ceiling (Hz): 500
			# High band floor (Hz): 500
			# High band ceiling (Hz): 4000

			sl = Get band energy difference... 0 500 500 4000
				
			#select Spectrogram 'object_name$'
			#plus Spectrum 'object_name$'
			#Remove
		 
	# print out results
			fileappend "'directory$'spectral_info.txt" 'object_name$' 'tab$' 'word_label$' 'tab$' 'interval_label$' 'tab$' 'seg_word_start:4' 'tab$' 'seg_word_end:4' 'tab$' 'seg_start:4' 'tab$'  'mid:4' 'tab$' 'seg_end:4' 'tab$' 'duration:4' 'tab$' 'intensity:2' 'tab$' 
			fileappend "'directory$'spectral_info.txt" 'cog:0' 'tab$' 'sd:0' 'tab$' 'sk:1' 'tab$' 'ku:1' 'tab$' 'sl:2' 'newline$'
		
		endif
	endfor

	select all
	minus Strings list
	Remove

endfor
select all
Remove

printline The file "spectral_info.txt" is in 'directory$'.
printline 'number_files' files were considered.