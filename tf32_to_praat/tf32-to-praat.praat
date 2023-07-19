# Convert TF32 labels into TextGrids
# Assumptions:
#	- .wav files and .LBL TF23 label files that have the same name
#	- .wav and .LBL files are located in the same folder as the script
#	- .LBL files have 3 columns: start, end, and label of intervals
#	- .LBL start and end times are in miliseconds (& will get converted to seconds)
#
#	This script additionally includes conversion for a specific numeric vowel coding system.
#	This part can be removed or changed as needed.
#
# Thea Knowles
# thea@msu.edu
# July 2023

clearinfo

# Print info?
verbose = 1

# Assumes files and script are in same directory
dir$ = ""
Create Strings as file list: "list","'dir$'*.wav"
select Strings list
nFiles = Get number of strings


for iFile from 1 to nFiles
	select Strings list
	current_file$ = Get string... iFile
	Read from file... 'dir$''current_file$'
	name$ = selected$ ("Sound")
	To TextGrid: "phones",""

	Read Matrix from raw text file: "'dir$''name$'.LBL"
	nRows = Get number of rows

	prev_end = 0

	for nRow from 1 to nRows

		select Matrix 'name$'
		start = Get value in cell: 'nRow',1
		end = Get value in cell: 'nRow',2
		start = 'start'/1000
		end = 'end'/1000
		code = Get value in cell: 'nRow',3
		lab$ = string$(code)

	# Convert code to arpabet vowel, based on Jeff Berry's vowel coding gloss
	# Set include to 0 if does not apply
		include=1
		if include
			if code == 1
				lab$ = "iy"
			elsif code == 4
				lab$ = "ae"
			elsif code == 5
				lab$ = "uw"
			elsif code == 8
				lab$ = "aa"
			elsif code == 15
				lab$ = "ay"
			else
				lab$ = "unknown"
				printline 'start''tab$''lab$'
			endif
		endif

	# Insert TextGrid boundaries and labels

		select TextGrid 'name$'

		if start <> prev_end
			# Only add boundary if it doesn't overlap with existing one
			Insert boundary: 1, 'start'
		endif

		Insert boundary: 1, 'end'

		int = Get interval at time: 1, 'start'+0.001
		Set interval text: 1, 'int', lab$

	# Troubleshooting for overlapping boundaries
		prev_end = end

		if verbose
			printline 'name$''tab$''nRow''tab$''start:4''tab$''end:4''tab$''code'
		endif

	endfor

	# Save TextGrid
	select TextGrid 'name$'
	Save as text file: "'dir$''name$'.TextGrid"



# Clean up files
select all
minus Strings list
Remove

endfor

select all
Remove
printline All done!



