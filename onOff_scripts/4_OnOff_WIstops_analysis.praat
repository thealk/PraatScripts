##############################################################################
# This script will pull acoustic measures from word-initial stops
# previously labeled. Measures include spectral moments,
# burst mean and burst peak, closure intensity, voicing in the closure
# and spirantization in the closure, and duration of segments. 
# 
# Labels: 
#	Target stop: "B", "T", etc
#	Burst: "x"
#	Transient: "v"
#	Following vowel: "UW1", "IY2" etc
# 
# Daryn Cushnie-Sparrow, 2018 
# dcushni@uwo.ca
#
# Special thanks to Thea Knowles for all her support!
# 
# Acknowledgments: Stop analysis portions were adapted from Meghan Clayards'
# (mclayards@bcs.rochester.edu) stop analysis script, edited by Thea Knowles. 
#
################################################################################

form Directory info
	sentence Directory C:\Users\daryncsparrow\Desktop\WIStops\WOI\
	sentence Output_file wiStops_out
	comment File with a list of words of interest
	sentence Woi_file woi_rp.txt
endform
clearinfo

# Setup of string list

Create Strings as file list... list 'directory$'*.wav
num_files = Get number of strings

# Word-of-interest comparison text file
Read Strings from raw text file... 'directory$''woi_file$'
num_woi = Get number of strings
woiCount = 0

# Tier labels
wordTier=1
soiTier=3
woiTier=5

# Set up printing
fileappend 'directory$''output_file$'.txt file'tab$'word'tab$'consonant'tab$'
fileappend 'directory$''output_file$'.txt vowel'tab$'closure_dur'tab$'closure_int'tab$'
fileappend 'directory$''output_file$'.txt closure_voice'tab$'closure_spir'tab$'Vextent_voice'tab$'
fileappend 'directory$''output_file$'.txt Vextent_unvoice'tab$'vot'tab$'burst_mean'tab$'burst_peak'tab$'
fileappend 'directory$''output_file$'.txt burst_mean_fil'tab$'burst_peak_fil'tab$'transient_dur'tab$'
fileappend 'directory$''output_file$'.txt vowel_dur'tab$'vowel_int'newline$'

# Read all files, set up names for files

for file from 1 to num_files ; file loop
	current_token$ = "NA"
	select Strings list
	current_token$ = Get string... 'file'
	Read from file... 'directory$''current_token$'
	object_name$ = selected$ ("Sound")
	Read from file... 'directory$''object_name$'.TextGrid

# Initialize word$ and woiCount to NA
	word$ = "NA"
	woiCount = 0
	woi_lab$ = "NA"
	iterate = 1

# Set all numbers for the specific file	
	select TextGrid 'object_name$'
	num_words = Get number of intervals... 'wordTier'
	num_labels = Get number of intervals... 'soiTier'
	num_woi_tier = Get number of intervals... 'woiTier'

# Create necessary intensity, filter band and pitch objects 

# Unfiltered intensity contour
	select Sound 'object_name$'
	To Intensity... 100 0 yes
	Rename... int_all

# Pitch contour for extent of voicing
	select Sound 'object_name$'
	To Pitch... 0.01 75 500
	Rename... pitch_all

# Filter for voicing in closure
	select Sound 'object_name$'
	Filter (pass Hann band): 70, 500, 100
	To Intensity... 100 0 yes
	Rename... int_voice

# Filter for spirantization in closure
	select Sound 'object_name$'
	Filter (stop Hann band): 0, 500, 100
	To Intensity... 100 0 yes 
	Rename... int_spir

# Iterate through all the intervals in the WOI tier 
# check for missing words

	while iterate < num_woi_tier ; word loop
		select TextGrid 'object_name$'
		word$ = Get label of interval: 'woiTier', iterate

		# Initialize measure variables
		cons_lab$ = "NA"
		vowel_lab$ = "NA"
		closure_dur = 99999
		closure_int = 99999
		closure_voice = 99999
		closure_spir = 99999
		voice_CLR = 99999
		unvoice_CLR = 99999
		vot = 99999
		burst_mean = 99999
		burst_peak = 99999
		burst_mean_fil = 99999
		burst_peak_fil = 99999
		transient_dur = 99999
		vowel_dur = 99999
		vowel_int = 99999

		if word$ <> ""
			woiCount = woiCount + 1
			select Strings woi_rp
			woi_lab$ = Get string... 'woiCount'
			if word$ = woi_lab$
				select TextGrid 'object_name$'
				word_start = Get starting point... 'woiTier' iterate
				first_seg = Get interval at time... 'soiTier' 'word_start'+0.005
				first_seg_lab$ = Get label of interval... 'soiTier' 'first_seg'
				if first_seg_lab$ <> ""
					closure = first_seg
					cons_lab$ = Get label of interval... 'soiTier' 'closure'
					burst = first_seg + 1
					transient = first_seg + 2
					vowel = first_seg + 3
					vowel_lab$ = Get label of interval... 'soiTier' 'vowel'
# do each individual batch of measures
# CLOSURE
# Closure duration, voicing intensity, spirantization intensity & extent of voicing.
					select TextGrid 'object_name$'
					closure_start = Get starting point... 'soiTier' 'closure'
					closure_end = Get end point... 'soiTier' 'closure'
					closure_dur = closure_end - closure_start

					select Intensity int_all
					closure_int = Get mean... 'closure_start' 'closure_end' energy
					select Intensity int_voice
					closure_voice = Get mean... 'closure_start' 'closure_end' energy
					select Intensity int_spir
					closure_spir = Get mean... 'closure_start' 'closure_end' energy

# extent of voicing - need to copy in and adapt from Megan Claynards
# Extent of voicing: number of steps with a detectable pitch
# from Megan Clayards

					select Pitch pitch_all
					voice_CLR = 0	
					unvoice_CLR = 0
					fr_start = Get frame number from time... closure_start
					fr_end = Get frame number from time... closure_end
					null$ = "--undefined--"
				
					for f from fr_start to fr_end
						temp$ = Get value in frame... f Hertz
						if temp$ = null$	
							unvoice_CLR = unvoice_CLR + 1
						else
							voice_CLR = voice_CLR + 1
						endif
					endfor ; extent of voicing

# BURST
# Burst amplitude and VOT
					select TextGrid 'object_name$'
					burst_start = Get starting point... 'soiTier' 'burst'
					burst_end = Get end point... 'soiTier' 'burst'
					vot = burst_end - burst_start
# Get burst mean/peak for unfiltered and filtered (for spirantization)
					select Intensity int_all
					burst_mean = Get mean... 'burst_start' 'burst_end' energy
					burst_peak = Get maximum... 'burst_start' 'burst_end' Parabolic
					select Intensity int_spir
					burst_mean_fil = Get mean... 'burst_start' 'burst_end' energy
					burst_peak_fil = Get maximum... 'burst_start' 'burst_end' Parabolic

# TRANSIENT
# Duration
					select TextGrid 'object_name$'
					transient_start = Get starting point... 'soiTier' 'transient'
					transient_end = Get end point... 'soiTier' 'transient'
					transient_dur = transient_end - transient_start
				
# VOWEL 
# Duration, intensity
					select TextGrid 'object_name$'
					vowel_start = Get starting point... 'soiTier' 'vowel'
					vowel_end = Get end point... 'soiTier' 'vowel'
					vowel_dur = vowel_end - vowel_start
					select Intensity int_all
					vowel_int = Get mean... 'vowel_start' 'vowel_end' energy

				endif ; first seg is not blank

			endif ; word is equal to woi lab so no skip

			# Printing
			fileappend 'directory$''output_file$'.txt 'current_token$''tab$''word$''tab$''cons_lab$''tab$'
			fileappend 'directory$''output_file$'.txt 'vowel_lab$''tab$''closure_dur''tab$''closure_int''tab$'
			fileappend 'directory$''output_file$'.txt 'closure_voice''tab$''closure_spir''tab$''voice_CLR''tab$'
			fileappend 'directory$''output_file$'.txt 'unvoice_CLR''tab$''vot''tab$''burst_mean''tab$''burst_peak''tab$'
			fileappend 'directory$''output_file$'.txt 'burst_mean_fil''tab$''burst_peak_fil''tab$''transient_dur''tab$'
			fileappend 'directory$''output_file$'.txt 'vowel_dur''tab$''vowel_int''newline$'
			
		endif ; word is not blank

		iterate = iterate + 1

	endwhile ; word done 

	select all 
	minus Strings list
	minus Strings woi_rp
	Remove

	printline File completed: 'object_name$'

endfor ; file done

printline All done!