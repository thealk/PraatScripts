# Extract relevant tier
# Purpose: save textgrids that only have one tier (your orthographic transcription) for input to the Montreal Forced Aligner
#	- this is to solve the problem that you may have many tiers on your original textgrids, but you only want to feed 1 tier to the aligner.
# 
# Note: consider using the rename_tiers_to_speaker.praat script to rename your tiers so that they are named according to speaker
#		https://github.com/thealk/PraatScripts/blob/master/mfa_prep/rename_tiers_to_speaker.praat
# 
# Thea Knowles
# thea@msu.edu
# August 2023


#######################################
# PARAMETERS
# 	Be sure to include the final forward slash (/) on Mac 
#	(or change to back slashes (\) if on PC)
#
# Specify the directory containing your original textgrids
# 	BE SURE TO BACK UP YOUR ORIGINAL FILES JUST TO BE SAFE
dir_in$ = "/Users/thea/Documents/test_in/"

# Specify where you would like to save the revised textgrids
# Textgrids will have the same name as the originals
dir_out$ = "/Users/thea/Documents/test_out/"

# Which tier contains your transcript?
tier_n = 1

#######################################


clearinfo

Create Strings as file list: "list","'dir_in$'*.TextGrid"
select Strings list
nFiles = Get number of strings

for iFile from 1 to nFiles
#for iFile from 1 to 10
select Strings list
	current_file$ = Get string... iFile
	Read from file... 'dir_in$''current_file$'
	name$ = selected$ ("TextGrid")

	# Extract the tier of interest
	Extract one tier: tier_n
	Rename: "extracted"

	# Save
	select TextGrid extracted
	Save as text file: "'dir_out$''current_file$'"

	select all
	minus Strings list
	Remove

endfor

select all
Remove

printline All done!
printline Extracted textgrids saved to: 'dir_out$'

