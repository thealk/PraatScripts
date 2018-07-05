# Extract non empty intervals
# This script will extract soundfiles corresponding to 
# all non-empty intervals from a given tier and save them 
# with that interval label appended to the end of the filename.
# It will optionally also save the corresponding extracted TextGrids
#
# Currently, must be in same directory as sound files (TO DO)
#
# Thea Knowles
# McGill University 2013
#
# Edited December 2017 for OnOff Project
# The name of the file will now be originalFileName_label.TextGrid/wav
#	e.g., PD-05-S0_ch1.TextGrid --> PD-05-S0_ch1_aifast.TextGrid
#
############
# IMPORTANT: 
# WITHIN A FILE, INTERVALS MUST HAVE UNIQUE LABELS (pattie1, pattie2, rp, etc).
# NON-UNIQUE INTERVAL LABELS WILL CAUSE EXTRACTED FILES TO BE OVERWRITTEN.
# THE LAST INTERVAL WITH THAT LABEL WILL BE THE ONE THAT WILL BE SAVED.
# This means that "conversation" which appears as con multiple times throughout
# the protocol
#############
# 
# tknowle3@uwo.ca

form TextGrid Information
	positive Tier_number 1
	#comment Enter the time at which you'd like to start
	#positive Start_time
	comment Check this box if you'd like to create a new folder for the extracted files
	boolean Make_directory
	comment Enter the name of the folder
	sentence Folder_name extracted_examples
	comment Check this box if you want to generate TextGrids for the extracted files
	boolean Save_textgrids
	comment Check this box if you want to create .lab files for "Rainbow Passage" and "Pattie"
	boolean Make_lab_files 1
endform
clearinfo

directory$ = ""

if make_directory
	createDirectory (folder_name$)
endif

Create Strings as file list...  list 'directory$'*.wav
number_files = Get number of strings

# iterate through the file list

for j from 1 to number_files
	select Strings list
	current_token$ = Get string... 'j'

# get the sound

     	Read from file... 'directory$''current_token$'
	object_name$ = selected$ ("Sound")

# get the textgrid

	Read from file... 'directory$''object_name$'.TextGrid
	select TextGrid 'object_name$'

# iterate through the intervals
	num_of_intervals = Get number of intervals... tier_number
	for b from 1 to num_of_intervals
		select TextGrid 'object_name$'
		label$ = Get label of interval... tier_number 'b'
		label_alt$ = ""
		if label$ <> ""


# CREATE .LAB FILES
# NOTE: This would be better suited as a function or external script but I am lazy so here it is for now.
			# Is it pattie?? Save all but the last character in label_alt
			# There are multiple "She saw Pattie" reps, saved as pattie1, pattie2, etc
			label_alt$ = left$(label$, length(label$)-1)

			if label$ == "rp" or label_alt$ == "pattie" 
				if label$ == "rp"
				# Make RP .lab
					labText$ = "WHEN THE SUNLIGHT STRIKES RAINDROPS IN THE AIR THEY ACT AS A PRISM AND FORM A RAINBOW THE RAINBOW IS A DIVISION OF WHITE LIGHT INTO MANY BEAUTIFUL COLORS THESE TAKE THE SHAPE OF A LONG ROUND ARCH WITH ITS PATH HIGH ABOVE AND ITS TWO ENDS APPARENTLY BEYOND THE HORIZON THERE IS  ACCORDING TO LEGEND A BOILING POT OF GOLD AT ONE END PEOPLE LOOK BUT NO ONE EVER FINDS IT WHEN A MAN LOOKS FOR SOMETHING BEYOND HIS REACH HIS FRIENDS SAY HE IS LOOKING FOR THE POT OF GOLD AT THE END OF THE RAINBOW "

				elsif label_alt$ == "pattie"
					labText$ = "SHE SAW PATTIE BUY TWO POPPIES"			
				endif
				writeFileLine: "'directory$''folder_name$'/'object_name$'_'label$'.lab", "'labText$'"
			endif

			
			
# Get start and end time of interval
			start = Get starting point... tier_number 'b'
			end = Get end point... tier_number 'b'

# Open soundfile and extract selection
			select Sound 'object_name$'
			Edit
			editor Sound 'object_name$'
			Select... start end
			Extract selected sound (time from 0)
			Close

			select Sound untitled

# Save the extracted sound (and textgrid)
			Write to WAV file... 'directory$''folder_name$'/'object_name$'_'label$'.wav
			Remove

			select TextGrid 'object_name$'
			Edit
			editor TextGrid 'object_name$'
			Select... start end
			Extract selected TextGrid (time from 0)
			Close

			if save_textgrids
				select TextGrid 'object_name$'
				Write to text file... 'directory$''folder_name$'/'object_name$'_'label$'.TextGrid
			endif
			select TextGrid 'object_name$'
			Remove
		endif
	endfor
# Clean up
			select all
			minus Strings list
			Remove
endfor

select Strings list
Remove
print All done!

