##########################################
## This script duplicates a tier to an existing TextGrid
##########################################

form Make Selection
	comment Enter directory of TextGrids
	comment Include final backslash!
	sentence Directory data/
	comment Enter the tier you'd like to duplicate
	positive DuplicateTier 3
	boolean MakeDirectory 1
endform

clearinfo

# If "1_original" doesn't exist already, the user clicks the box "makeDirectory" on the form
# A click indicates a value of 1 which Praat understands as TRUE, which can then be used in an if-statement
if makeDirectory
	createDirectory ("'directory$'0_oldTextGrids")
endif

# get the sound and textgrid files from the directory to work on

Create Strings as file list...  myList 'directory$'*.TextGrid
number_files = Get number of strings

# iterate through the file list

for file from 1 to number_files
	select Strings myList
	current_token$ = Get string... 'file'
	Read from file... 'directory$''current_token$'
	object_name$ = selected$("TextGrid")

	# Print out the file that's being modified so the user knows it's working
	printline 'object_name$'

	# We want to carry out the command Duplicate Tier
	# This takes three arguments (in this order): Tier number, Position, Name
	# The user defined the tier number to be duplicated
	# We want the tier to be at the bottom, which means at the position that is 1 + the number of tiers that already exist
	#	For this we'll define a variable that counts the number of tiers and adds 1
	# We don't need a variable for the tier name, since we want this to be the the same every time the script is run
	#	We'll give that argument a fixed value that refers to its purpose (it will be the tier on which annotations will take place)

	numTiers = Get number of tiers
	newTier = numTiers + 1
	Duplicate tier... duplicateTier newTier annotate

	# Write and save
	# First copy the original TextGrid into the 0_oldTextGrids folder
	# Then save the TextGrid you've edited into the new folder.

	system cp "'directory$''object_name$'.TextGrid"  'directory$'0_oldTextGrids/'object_name$'.TextGrid
	
	select TextGrid 'object_name$'
	Write to text file... 'directory$''object_name$'.TextGrid

	# If you want to copy the wav you can also do that
	# However, then you get a whole bunch of copies of wav files, which take up a lot of space
	#system cp "'directory$''object_name$'.wav"  'directory$'0_oldTextGrids/'object_name$'.wav


	# Remove the TextGrid you just worked on
	# But keep the list of files so that you can keep working on the others
	select all
     	minus Strings myList
     	Remove
endfor

select Strings myList
Remove

# Let the user know the script finished running.
printline all done!
