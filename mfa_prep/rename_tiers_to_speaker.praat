# Rename textgrid tier to speaker ID
# Purpose: This modifies textgrids used as input for the Montreal Forced Aligner, by renaming tiers to match the speaker ID of the file
#			- This is to get the aligner (MFA) speaker adaptation to trigger properly.
#			- See more here: https://github.com/MontrealCorpusTools/Montreal-Forced-Aligner/issues/669
# Assumptions: 
#	- there is one tier (presumably the transcript). This is the tier that will be renamed with the specified number of speaker_characters based on the file name.
#	- speaker IDs consistently have the same number of characters (zero padding is helpful...)
#	- the input textgrid file name begins with unique speaker IDs 
#		- Example 1: in one corpus, filenames are, e.g., caspd_v1_oc14_tk_24_filler_24_0.TextGrid. caspd = project, v1 = version, and oc14 = speaker ID. 
#						Since project & version are consistent across files, I set speaker_chars = 13 which captures caspd_v1_oc14
#		- Example 2: in another corpus, filenames are DM91.TextGrid, TM09.TextGrid, etc, where there is only 1 file per speaker.
#						Here I set speaker_chars = 4 which captures the whole file name in this case.
#
# Thea Knowles
# thea@msu.edu
# August 2023

# Directory containing the original textgrids
dir_in$ = "/Users/thea/CASALabDocuments/Projects/segmentation/2_caspd/1_input_caspd/"
# Directory where you want to save the revised textgrids
dir_out$ = "/Users/thea/CASALabDocuments/Projects/segmentation/2_caspd/2_named_tiers/"

# Number of characters (starting from first character) in the filename that correspond to a unique speaker ID
# This would be the same number used with the -s flag in the MFA commands
speaker_chars = 13

Create Strings as file list: "list","'dir_in$'*.TextGrid"
select Strings list
nFiles = Get number of strings

for iFile from 1 to nFiles
	select Strings list
	current_file$ = Get string... iFile
	Read from file... 'dir_in$''current_file$'
	name$ = selected$ ("TextGrid")
	tier_name$ = left$ (name$, speaker_chars)
	#printline 'tier_name$'
	Set tier name: 1, tier_name$
	Save as text file: "'dir_out$''current_file$'"
	select TextGrid 'name$'
	Remove

# Optional if you also want to copy the wavs over to your output directory
#	Read from file... 'dir_in$''name$'.wav
#	Save as WAV file: "'dir_out$''name$'.wav"
#	select Sound 'name$'
#	Remove

endfor

printline all done!
