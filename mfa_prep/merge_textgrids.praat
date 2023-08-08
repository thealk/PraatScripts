# Project: Segmentation
# Merge textgrids
# Purpose: merge manually annotated textgrid tier with force aligned tier for later analysis
#
# Thea Knowles
# thea@msu.edu
# July 2023

clearinfo

# Directories
# Original textgrids containing manual annotations
dir_man$ = "/Users/thea/Library/CloudStorage/OneDrive-MichiganStateUniversity/CASALabDocuments/Projects/segmentation/1_caterpillar/0_manually_annotated_caterpillar/bgs_phones/"
# Aligned output
dir_aligned$ = "/Users/thea/Library/CloudStorage/OneDrive-MichiganStateUniversity/CASALabDocuments/Projects/segmentation/1_caterpillar/2_aligned/mfa-train-self/2_aligned/"
# Where to save merged textgrids
dir_out$ = "/Users/thea/Library/CloudStorage/OneDrive-MichiganStateUniversity/CASALabDocuments/Projects/segmentation/1_caterpillar/2_aligned/mfa-train-self/3_merged/"


Create Strings as file list: "list","'dir_man$'*.TextGrid"
select Strings list
nFiles = Get number of strings

for iFile from 1 to nFiles

	select Strings list
	current_file$ = Get string... iFile
		Read from file... 'dir_man$''current_file$'
		name$ = selected$ ("TextGrid")
		Rename: "manual"

		current_path$ = "'dir_aligned$''current_file$'"

		if fileReadable (current_path$)
			Read from file... 'dir_aligned$''current_file$'
			Rename: "aligned"

			select TextGrid manual
			plus TextGrid aligned
			Merge
			# The first tier will be renamed to "baseline". Comment this out if you don't want it.
			Set tier name: 1, "baseline"

			# Save textgrid
			Save as text file: "'dir_out$''name$'.TextGrid"
		else
			printline 'current_file$' not readable
		endif

		select all
		minus Strings list
		Remove
	

endfor

printline All done!
printline Files saved to 'dir_out$'