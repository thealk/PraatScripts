# Find out how many files of a given type are in a folder
# files must be informat experiment_participant_item_condition
# Thea Knowles
# McGill 2013

#################### SET UP ##########################
# FORMS = SETTINGS SCREENS THAT ALLOW USERS TO INPUT 
# INFORMATION WITHOUT EDITING THE SCRIPT
#
# Useful for directories, parameters that change depending on the dataset, etc
# Variables in this form: 
#	- Title of "form" is "Make Selection"
#	- comment = A message to the user
#	- sentence = A string variable that the user will enter
#		- the variable name is the word that immediately follows "sentence"
#		- in the form window, this variable name must be capitalized.
#		- However, everywhere else variables must be lower-case

# Good practice: Indenting between start/end points of functions
# Easier to follow, debug if necessary, and keep track of what's going on

form Make Selection
	comment Enter directory of files
	comment Files must have format: experiment_participant_item_condition
        comment Directory must include the final slash
	sentence Directory /Users/mcgillLing/Google Drive/PraatScriptingTutorial/data/
	sentence Extension .wav
endform

# "INFO" refers to the Praat Info window that prints out information to the user
# We're going to be listing the participants in the info window, so we'll get rid of any extra
# stuff there first:

clearinfo

###################### GET FILES #########################
#
#	 Next we need to get all the files in the directory we specified
#	 To do this we need to make a list of all the files that exist in the folder with a given extension
# 	 Praat commands like "Create", "Remove", "Get", etc must be capitalized
# 	 (Praat capitalization can get annoying)

#	 - "Create Strings as file list" is the command
#	 - "myList" is the variable name
#	 - 'directory$' and 'extension$' must be referred to in single quotes when they are being referred to as input
#	 	(to show they're variables that have already been declared)
#	 	and with a "$" to show that they're string variables
#	 - "*" says "look for all files that end with the following extension"


Create Strings as file list... myList 'directory$'*'extension$'
numberFiles = Get number of strings

# We'll be counting how many times certain parts of the files reappear as we iterate over the list
# Here we set up base variables with default values of 0 or empty strings
	count_files = 0
	count_exp = 0
	count_part = 0
	last_experiment$ = ""
	last_participant$ = ""



# Iterate through the file list
for file from 1 to numberFiles
	select Strings myList
	filename$ = Get string... file
	Read from file... 'directory$''filename$'
	soundfile$ = selected$ ("Sound")

	# Get length of filename and extension string values
	# No single quotes, but yes "$" in string functions like "length()"

	lengthFile = length (filename$)
	lengthExt = length(extension$)
	length = lengthFile - lengthExt
	name$ = left$(filename$,length)

# This next part relies on a very specific filename format (which is how all of our lab collected files are named)
# 1experiment_2participant_3item_4condition

############ GET INFORMATION ABOUT FILE ###############
# 	Print statements are useful to see what the script is doing at a given time
#	 This next part chops up the filename into relevant parts
#	 (This can also be done with a repeat procedure)
	
	first_us = index(name$, "_")
		#print first underscore: ' first_us:0' 'newline$'
	experiment$ = left$(name$, first_us - 1)
		#print experiment: 'experiment$' 'newline$'
	rest$ = right$(name$, length - first_us)
	restlen = length(rest$)
	second_us = index(rest$,"_")
	participant$ = left$(rest$, second_us - 1)
		#print participant: 'participant$' 'newline$'
	rest$ = right$(rest$, restlen - second_us)
	third_us = index(rest$,"_")
	item$ = left$(rest$, third_us -1)
		#print item: 'item$' 'newline$'
	item = 'item$'
	condition$ = right$(rest$, restlen - third_us)
		#print condition: 'condition$' 'newline$'
###################################################


##################### COUNT AND PRINT #########################
#	The files are run in alphabetic/numeric order
#	The first time around, last_experiment$ and last_participant$ are empty strings
#	At the end of each for-loop iteration we reset these values to the *current* values
#	If the new values are the same as the previous values, 'count' stays the same
#	If it sees a new value, 'count' increases by 1
#
#	We'll print out the values to the Praat info window

	# count experiments
	if experiment$ = last_experiment$
		count_exp = count_exp
	else
		count_exp = count_exp+ 1
		print experiment: 'experiment$''newline$'
		print 'newline$'
	endif

	# count participants
	if participant$ = last_participant$
		count_part = count_part
	else
		count_part = count_part + 1
		print participant 'count_part': 'participant$''newline$'
	endif

	# reset values
	last_experiment$ = experiment$
	last_participant$ = participant$
	
	# every iteration of the for-loop constitutes a unique file
	count_files = count_files + 1

endfor

# Print total counts
# Variables to be printed must have single quotes
# printline and print 'newline$' do the same thing

print 'newline$'
printline Total number of experiments: 'count_exp'
print Total number of participants: 'count_part' 'newline$'
print Total number of 'extension$' files: 'count_files' 'newline$'

# Good practice: Clean up the Praat object window
select all
Remove
	