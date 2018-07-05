################################################
## This script adds a new interval tier to an existing TextGrid
## Modified 07/2017 for FMAmp study
## Script must be in same directory as TGs
## Creates orig_tg folder
## Adds "snr" interval tier to num_tiers - 1 (in this case, the 4th tier)
################################################

form Make Selection
	comment Enter directory of TextGrids and directory for new TextGrids
	#sentence Directory 
	boolean makeDirectory 1
endform

clearinfo

directory$ = ""

if makeDirectory
	createDirectory ("1_orig")
endif

# get the sound and textgrid files from the directory to work on

	Create Strings as file list...  list 'directory$'*.TextGrid
	number_files = Get number of strings

# iterate through the file list

	for j from 1 to number_files
		select Strings list
		current_token$ = Get string... 'j'
		Read from file... 'directory$''current_token$'
		object_name$ = selected$ ("TextGrid")
		printline 'object_name$'

			new_label_tier = Get number of tiers
			# Insert one tier above the last tier
			Insert interval tier... new_label_tier snr

# Write and save
		select TextGrid 'object_name$'
				system mv "'directory$''object_name$'.TextGrid"  1_orig/'object_name$'.TextGrid
				Write to short text file... 'object_name$'.TextGrid
				#system cp "'directory$''object_name$'.wav"  1_output/'object_name$'.wav

		select all
     		minus Strings list
     		Remove

	endfor

select Strings list
Remove
print all done 


