# Praat Scripting Interactive
clearinfo


repeat
beginPause("Praat interactive tutorial: Home")
	comment("Enter your working directory")
	sentence("Directory","data")
	comment("Which level would you like to access first?")
	comment("	Level 1 = simple directory structure")
	comment("	Level 2 = basic TextGrid manipulation, saving")
	comment("	Level 3 = intermediate TextGrid manipulation")
	comment("	Level 4 = phonetic analyisis, writing to files")
	choice("Level",5)
		option("1")
		option("2")
		option("3")
		option("4")
		option("most recent")
clicked = endPause("Continue","End",1)
if clicked <> 2

beginPause("Instructions")
	comment("The text in the print info will show you part of a script")
	comment("You'll be asked to complete or add certain lines to make the script run.")
	comment("When you're ready to go on click Continue.")
clickedContinue=endPause("Continue",1)

if right$(directory$,1)<>"/"
	directory$ = "'directory$'/"
endif

printline 'directory$'
t$ = "'"
if level = 1
printline Level 'level': SIMPLE DIRECTORY STRUCTURE

printline
printline ##### 1.1 #####
printline
printline Create Strings as file list... myList 't$'directory$'*.TextGrid
printline numberFiles = Get number of strings
printline
printline ##############

# actual code
Create Strings as file list... myList 'directory$'*.TextGrid
numberFiles = Get number of strings
printline

beginPause("1.1: Getting information about files in a directory")
	comment("'Create strings as file list...' is a command that is always available")
	comment("from the Praat objects window under 'New'.")
	comment("It takes two arguments:")
	comment("	1) the name you'd like to give the list and")
	comment("	2) the path to the directory containing the files you'd like to list.")
	comment("Appending *.TextGrid to the path says 'only look for files ending in .TextGrid.'")
	comment("When a String object is selected, more commands become available in the")
	comment("dynamic menu on the right side of the object window.")
	comment("")
	comment("Try clicking on the object called 'myList' in the Object window now")
	comment("and seeing what other commands are available.")
	comment("When you're finished, click 'Continue'.")
clicked = endPause("Continue",1)
beginPause("1.1: Getting information about files in a directory")
	comment("'Get number of strings' is a Praat command available for lists in 'Query'.")
	comment("It takes no arguments. When you run this command manually, the number")
	comment("of rows in the list appears in the print window.")
	comment("In this script, the variable called 't$'numberFiles' stores that number.")
clicked = endPause("Continue",1)
beginPause("1.1: Getting information about files in a directory")
	comment("To see what a variable stores, you can print it to the print window with")
	comment("command 'print' or 'printline'")
	comment("")
	comment("Note: ")
	comment("	File paths leading to a folder must end in '/''.")
	comment("	File paths leading to a file do not need a final '/'.")
clicked = endPause("Continue",1)

repeat
beginPause("1.1: Getting information about files in a directory")
	comment("Which variable shoud you print if you want to know ")
	comment("how many files are in your directory?")
	choice("Variable",1)
		option("'myList'")
		option("'t$'directory$'")
		option("'t$'numberFiles'")
clickedVar = endPause("Continue","Skip",2)

if clickedVar <> 2
	if variable = 1
		printline # printline 't$'myList'
		printline 	'myList'
		printline # 'myList' is an object, so cannot be printed to the screen.
		printline # Only the variable name (here in single quotes) will be printed.

		beginPause("Not quite - see what that option prints out")
		click = endPause("Try again",1)

	elsif variable = 2
		printline # printline 't$'directory$'
		printline
		printline 'directory$'
		printline
		printline # 't$'directory$' prints out the path you specified. This is where the script will look.
		printline # As long as the variable is referred to 1) in single quotes and 2) with a "$" at the end (since it is a string variable, or text)
		printline # the variable value will be printed. If it is not properly referenced, just the word will print (not its value). E.g.:
		printline 'directory'
		printline or
		printline directory$
		printline etc...
		
		beginPause("Not quite - see what that option prints out")
		click = endPause("Try again",1)

	elsif variable = 3
		printline # printline 't$'numberFiles'
		printline
		printline 'numberFiles'
		printline
		printline Right! As long as numberFiles is correctly assigned and referenced in the code
		printline it will print out the number of files on the list you create, which corresponds to the number of files
		printline with the extension ".TextGrid" in the specified directory.
		
		beginPause("Correct!")
			comment("Note: These variables could also be given other names ")
			comment("The important thing is how they are referred to later.")
			comment("All variables must be referred to in single quotes ' '")
			comment("String variables must also have a '$' at the end.")
			comment("Variables storing numbers (like numberFiles) do not.")
		click = endPause("Next: How to iterate over files",1)

	endif
until variable = 3
endif


printline
printline ##### 1.2 #####
printline
printline for file from 1 to numberFiles
printline 	select Strings myList
printline 	filename$ = Get string... file
printline 	printline 't$'filename$'
printline endfor
printline
printline ##############

repeat
beginPause("1.2: Iterating over files")
	comment("Here a for-loop is being used to iterate over the number of files in the list.")
	comment("All for-loops in Praat scripts must have the structure:")
	comment("	for [VAR] from [START] to [END]")
	comment("		...")
	comment("	endfor")
clicked = endPause("Continue",1)
beginPause("1.2: Iterating over files")
	comment("How many times will the value of the variable 't$'filename$' ")
	comment("print to the screen?")
	choice("Number_of_times",1)
		option("1")
		option("'numberFiles'")
		option("Never")
clicked = endPause("Continue","Skip",2)
if clicked <> 2

	# actual code
	for file from 1 to numberFiles
		select Strings myList
		filename$ = Get string... file
		printline 'filename$'
	endfor

	if number_of_times = 1
	printline
		beginPause("Not quite - see what that option prints out")
		click = endPause("Try again",1)
	elsif number_of_times = 3
	printline
		beginPause("Not quite - see what actually gets printed")
		click = endPause("Try again",1)
	else

		beginPause("Correct!")
			comment("Right!")
			comment("The printline statement will be used once for each iteration of the for-loop.")
			comment("The for-loop will iterate from 1 to numberFiles, a variable that was set earlier.")
			comment("On each iteration, the value of 't$'file' will increase by 1.")
			comment("The command 'Get string...' takes one argument: The position or row number.")
			comment("For each iteration, it gets the text stored in the row 'file' in the object 'myList'.")
			comment("You could also tell it just to loop once:")
			comment("	'for file from 1 to 1'")
			comment("You could also tell it to start at the second file:")
			comment("	'for file from 2 to numberFiles'")
			comment("etc...")
		click = endPause("Next: How to open files in Praat",1)
	endif
until number_of_times = 2
endif


printline 
printline ##### 1.3 #####
printline
printline for file from 1 to numberFiles
printline 	select Strings myList
printline 	filename$ = Get string... file
printline 	Read from file... 't$'directory$''t$'filename$'
printline 	tg$ = selected$ ("TextGrid")
printline endfor
printline
printline ##############

# actual code
Create Strings as file list... myList 'directory$'*.TextGrid
numberFiles = Get number of strings
for file from 1 to 1
	select Strings myList
	filename$ = Get string... file
 	Read from file... 'directory$''filename$'
 	tg$ = selected$ ("TextGrid")
endfor

beginPause("1.3: Opening files in Praat")
	comment("'Read from file...' is a Praat command.")
	comment("It takes a single argument: the path to the file you'd like to open.")
	comment("Here the path is stored in the variable called 't$'directory$'.")
	comment("The names of all the files with the extension .TextGrid are listed in the")
	comment("String object called 'myList'.")
	comment("Here the script is iterating over each item in the list with the variable")
	comment("'t$'filename$'")
clicked = endPause("Continue",1)
beginPause("1.3: Opening files in Praat")
	comment("The type of file that is opened determines how Praat treats it as an object.")
	comment("A file with the extension .TextGrid will be read as a TextGrid object.")
	comment("A .wav file will be read as a Sound object.")
	comment("These objects are named according to the filename minus the extension.")
	comment("The most recently opened file will be selected in the object window by default.")
clicked = endPause("Continue",1)
repeat
beginPause("1.3: Opening files in Praat")
	comment("What value is stored in 't$'tg$'? in the first iteration of the for-loop?")
	choice("Value",1)
		option("'tg$'")
		option("'filename$'")
clickedVar = endPause("Continue","Skip",1)
if value = 1
	beginPause("Correct!")
		comment("'t$'tg$' stores the name of the TextGrid object (no extension).")
		comment("'t$'filename$' stores the whole name of the file, which was retrieved")
		comment("from myList.")
	clicked = endPause("Next: Saving files",1)
else
	beginPause("Not quite")
		comment("'t$'tg$' stores the name of the TextGrid object (no extension).")
		comment("'t$'filename$' stores the whole name of the file, which was retrieved")
		comment("from myList.")
	clicked = endPause("Continue",1)
	
endif
until value = 1

# saving files
printline ##### 1.4 #####
printline
printline createDirectory("'t$'directory$'newTextGrids")
printline
printline Create Strings as file list... myList 'directory$'*.TextGrid
printline numberFiles = Get number of strings
printline
printline for file from 1 to numberFiles
printline 	select Strings myList
printline 	filename$ = Get string... file
printline 	Read from file... 't$'directory$''t$'filename$'
printline 	tg$ = selected$ ("TextGrid")
printline 	tg_new$ = "'tg$'_new"
printline 	Save as text file... 't$'directory$'newTextGrids/'new_tg$'.TextGrid
printline endfor
printline
printline ##############

createDirectory("'directory$'newTextGrids")
Create Strings as file list... myList 'directory$'*.TextGrid
numberFiles = Get number of strings
for file from 1 to numberFiles
	select Strings myList
	filename$ = Get string... file
	Read from file... 'directory$''filename$'
	tg$ = selected$ ("TextGrid")
	tg_new$ = "'tg$'_new"
	Save as text file... 'directory$'newTextGrids/'new_tg$'.TextGrid
endfor

beginPause("1.4: Saving files: createDirectory")
	comment("'createDirectory('newDirectoryPath$') generates a new folder.")
	comment("")
	comment("By first specifying your directory ('t$'directory$'), then following it with the")
	comment("name you'd like to give your new folder, you can create a place to save your")
	comment("new TextGrids so that you don't overwrite the originals.")
	comment("")
	comment("Notice that the whole directory name is in double quotes,")
	comment("but the variable 't$'directory$' is in single quotes.")
clicked = endPause("Continue",1)

beginPause("1.4: Saving files: Save as text file...")
	comment("'t$'tg_new$' saves the name of our TextGrids with the suffix ''_new'' so that ")
	comment("they're clearly distinguishable from the originals (this will not always be necessary).")
	comment("(Notice that the whole name '''t$'tg$'_new'' is in double quotes, but the variable")
	comment("'t$'tg$' is in single quotes.)")
	comment("")
	comment("'Save as text file...' takes one argument: the path and ")
	comment("file name you'd like to save, just as if you were to save it manually.")
	comment("")
	comment("Specifying that the file should be saved as .TextGrid is important")
	comment("because 't$'new_tg$' does not include the extension.")
clicked = endPause("Continue",1)

beginPause("1.4: Saving files")
	comment("Look in your directory to see if the new folder and new TextGrids ")
	comment(" have been saved.")
clicked = endPause("Next: Write a script!",1)

beginPause("1.5: Write a script!")
	comment("When you click 'Create a new Praat script', a new window called ")
	comment("'untitlted script' will pop up.")
	comment("Write a script that does the following:")
	comment("	1. Defines a directory containing at least some wav files")
	comment("	(You may want to create a new test directory for this.)")
	comment("	2. Creates a list of these wav files and creates a new directory.")
	comment("	3. Opens the wav files one by one and saves them each with a new")
	comment("	name in the new directory.")
	comment("	4. Prints the name of each file that's saved on a new line in the Praat info ")
	comment("	window.")
	comment("Save the script as demo1.praat in the Praat Tutorial folder and run it.")
	comment("You may leave this script running and continue from the home window when")
	comment("you're ready to proceed.")
clicked = endPause("Create a new Praat script",1)


New Praat script
clearinfo

elsif level = 2
clearinfo
printline Level 'level': BASIC TEXTGRID MANIPULATION

printline 
printline ##### 2.1 #####
printline # The following block of code assumes that:
printline # 1. the directory has already been defined
printline # 2. the file list has been created
printline # 3. a new folder called newTextGrids has been created within the directory
printline
printline # Define the tier number you'd like to duplicate
printline duplicateTier = 2
printline
printline for file from 1 to numberFiles
printline 	select Strings myList
printline 	filename$ = Get string... file
printline 	Read from file... 't$'directory$''t$'filename$'
printline 	tg$ = selected$ ("TextGrid")
printline
printline 	numTiers = Get number of tiers
printline 	newTier = numTiers + 1
printline 	Duplicate tier... duplicateTier newTier annotate
printline 
printline 	# Save new TextGrid
printline 	Save as text file... 't$'directory$'newTextGrids/'tg$'.TextGrid
printline endfor
printline
printline ##############


beginPause("2.1: Duplicate tier")
	comment("In this example we'll duplicate an existing tier of a TextGrid.")
	comment("")
	comment("Two new TextGrid commands are used:")
	comment("	'Get number of tiers'")
	comment("	'Duplicate tier...'")
	comment("")
	comment("Try manually selecting a TextGrid in the Object window and find the ")
	comment("command 'Duplicate tier...'. It takes 3 arguments:")
	comment("	Tier number: The number of the tier you'd like to duplicate.")
	comment("	Position: The position of the new tier you'll be making.")
	comment("	Name: The name of the new tier.")
clicked = endPause("Run this code","Skip",1)

if clicked <> 2

# 2.1 actual code
createDirectory("'directory$'newTextGrids")
Create Strings as file list...  myList 'directory$'*.TextGrid
number_files = Get number of strings
duplicateTier = 2

for file from 1 to number_files
	select Strings myList
	filename$ = Get string... 'file'
	Read from file... 'directory$''filename$'
	tg$ = selected$("TextGrid")

	numTiers = Get number of tiers
	newTier = numTiers + 1
	Duplicate tier... duplicateTier newTier annotate
	Save as text file... 'directory$'newTextGrids/'tg$'.TextGrid
endfor


beginPause("2.1: Duplicate tier")
	comment("")
	comment("Take a look at the TextGrids saved in newTextGrids.")
	comment("")
clicked = endPause("See last","Skip",1)
if clicked = 1
	select all
	minus TextGrid 'tg$'
	Remove
	select TextGrid 'tg$'
	Edit
beginPause("2.1: Duplicate tier")
	comment("")
	comment("Got it!")
	comment("")
	clicked2 = endPause("Continue",1)

	if clicked2 = 1
		select all
		Remove
	endif
	
else
	select all
	Remove
endif



repeat
beginPause("2.1: Duplicate tier")
	comment("Now try changing the value of the arguments in this code and see what the")
	comment("new output is by opening up the new TextGrids.")
	comment("(The previous TextGrids in newTextGrids will be overwritten.)")
	comment("")
	comment("What happens if...")
	comment("	- duplicateTier is a greater than the number of tiers?")
	comment("	- newTier is greater than the number of tiers?")
	comment("	- duplicateTier or newTier are given string values?")
	comment("	- name is given a numerical value?")
	comment("")
	positive("duplicateTier",2)
	positive("newTier",3)
	sentence("name","annotate")
	comment("")
	comment("Click 'Run' when you're ready to run the code with the new arguments.")
	comment("Click 'Done' when you're ready to move on.")
clicked2 = endPause("Run","Done","Skip",1)
if clicked2 = 1

	for file from 1 to number_files
		select Strings myList
		filename$ = Get string... 'file'
		Read from file... 'directory$''filename$'
		tg$ = selected$("TextGrid")

		Duplicate tier... duplicateTier newTier 'name$'
		Save as text file... 'directory$'newTextGrids/'tg$'.TextGrid
	endfor
	select all
	minus TextGrid 'tg$'
	minus Strings myList
	Remove

	select TextGrid 'tg$'
	Edit

until clicked2 = 2

endif
endif

elsif level = 5

# 2.2
clearinfo
printline 
printline ##### 2.2 #####
printline # The following block of code assumes that:
printline # 1. 
printline
printline # Define the tier you'd like to search ( in this example 1 = phones, 2 = words)
printline searchTier = 1
printline # Define text you want to find
printline label$ = "S"
printline for file from 1 to numberFiles
printline 	select Strings myList
printline 	filename$ = Get string... file
printline 	Read from file... 't$'directory$''t$'filename$'
printline 	tg$ = selected$ ("TextGrid")
printline
printline 	num_tiers = Get number of tiers
printline 	soiTier = num_tiers + 1
printline 	num_ints = Get number of intervals... searchTier
printline 	Insert interval tier... soi_tier soi
printline 
printline 	for int from 1 to num_ints
printline 		select TextGrid 'tg$'
printline 		current_label$ = Get label of interval... searchTier int
printline 		if current_label$ == label$
printline 			start = Get starting point... searchTier int
printline 			end = Get end point... searchTier int
printline 			Insert boundary... soiTier start
printline 			Insert boundary... soiTier end
printline 			soiInt = Get interval at time... soiTier start+0.001
printline 			Set interval text... soiTier soiInt 'label$'
printline 		endif
printline 	endfor
printline
printline 	Save as text file... 't$'directory$'newTextGrids/'tg$'.TextGrid
printline endfor
printline
printline ##############

beginPause("2.2: Extract intervals with a given text")
	comment("In this example we'll pull out all intervals with a given text")
	comment("onto a new tier. Click 'Run Code' to run and see one of the TextGrids.")
clicked = endPause("Run code",1)


Create Strings as file list...  myList 'directory$'*.TextGrid
numberFiles = Get number of strings
searchTier = 1
label$ = "S"
for file from 1 to numberFiles
	select Strings myList
	filename$ = Get string... file
	Read from file... 'directory$''filename$'
	tg$ = selected$ ("TextGrid")
	num_tiers = Get number of tiers
	soiTier = num_tiers + 1
	num_ints = Get number of intervals... searchTier
	Insert interval tier... soiTier soi
	for int from 1 to num_ints
		select TextGrid 'tg$'
		current_label$ = Get label of interval... searchTier int
		if current_label$ == label$
			start = Get starting point... searchTier int
			end = Get end point... searchTier int
			Insert boundary... soiTier start
			Insert boundary... soiTier end
			soiInt = Get interval at time... soiTier start+0.001
			Set interval text... soiTier soiInt 'label$'
		endif
	endfor
Save as text file... 'directory$'newTextGrids_2/'tg$'.TextGrid
endfor

# open it up for them to see
select TextGrid 'tg$'
Edit
beginPause("2.2: Extract intervals with a given text")
clicked = endPause("Got it!",1)
select all
Remove

# Edit code
repeat
repeat
beginPause("2.2: Extract intervals with a given text")
	comment("Now try changing the value of the arguments in this code and see what the")
	comment("new output is by opening up the new TextGrids.")
	comment("(The previous TextGrids in newTextGrids will be overwritten.)")
	comment("")
	comment("What happens if...")
	comment("	- The label doesn't exist in the TextGrid?")
	comment("	- You search on a different tier?")
	comment("")
	positive("searchTier",2)
	sentence("label","S")
	comment("")
	comment("Click 'Run' when you're ready to run the code with the new arguments.")
	comment("Click 'Done' when you're ready to move on.")
clicked2 = endPause("Run","Done","Skip",1)
if clicked2 = 1
printline 'searchTier' 'label$'
	Create Strings as file list...  myList 'directory$'*.TextGrid
	numberFiles = Get number of strings
	searchTier = searchTier
	label$ = label$
	for file from 1 to numberFiles
		select Strings myList
		filename$ = Get string... file
		Read from file... 'directory$''filename$'
		tg$ = selected$ ("TextGrid")
		num_tiers = Get number of tiers

		# message to user (so as not to crash script)
		if searchTier > num_tiers or searchTier <=0
			beginPause("Error!")
				comment("The variable searchTier must be less than or equal to the number of tiers")
				comment("in the TextGrid, but greater than 0.")
				comment("If it is too big, your script will crash.")
				comment("If it is less than 0, the script won't crash, but you will get an error.")
			clicked = endPause("Back",1)
			tierError = 1
		else
			tierError = 0
		endif
until tierError = 0
		soiTier = num_tiers + 1
		num_ints = Get number of intervals... searchTier
		Insert interval tier... soiTier soi
		for int from 1 to num_ints
			select TextGrid 'tg$'
			current_label$ = Get label of interval... searchTier int
			if current_label$ == label$
				start = Get starting point... searchTier int
				end = Get end point... searchTier int
				Insert boundary... soiTier start
				Insert boundary... soiTier end
				soiInt = Get interval at time... soiTier start+0.001
				Set interval text... soiTier soiInt 'label$'
			endif
		endfor
		Save as text file... 'directory$'newTextGrids_2/'tg$'.TextGrid
	endfor

# open it up for them to see
select TextGrid 'tg$'
Edit

until clicked2 = 2
endif

beginPause("2.2: Extract intervals with a given text")
	comment("Note:")
	comment("Some variables can be changed by the user depending on what they want to ")
	comment("look for in their data.")
	comment("However, other variables, such as start and end times, shouldn't be ")
	comment("manipulated by the user.")
	comment("Other variables should remain constant while the script is running, such as ")
	comment("the number of files in the directory.")
	comment("Be cautious of how you are defining variables, especially those defined within ")
	comment("loops and conditional statements.")
clicked = endPause("Got it!",1)

printline
printline ##### 2.2 #####
printline ##############
printline 		for int from 1 to num_ints
printline 			select TextGrid 'tg$'
printline 			current_label$ = Get label of interval... searchTier int
printline 			if current_label$ == label$
printline 				start = Get starting point... searchTier int
printline 				end = Get end point... searchTier int
printline 				Insert boundary... soiTier start
printline 				Insert boundary... soiTier end
printline 				soiInt = Get interval at time... soiTier start+0.001
printline 				Set interval text... soiTier soiInt 'label$'
printline 			endif
printline 		endfor
printline ##############


beginPause("2.2: Extract intervals with a given text: Loops and Jumps")
	comment("Pay attention to the contents of the for-loop and if-statement in the print window.")
	comment("This is saying: loop through every interval on the 'searchTier' and get its label.")
	comment("If that label ('current_label') is the exact same as the label the user is looking for ('label'), then:")
	comment("	1. Get the start and end time (notice that these commands take both a tier and an interval number as arguments)")
	comment("	2. Then use those times to insert boundaries on another tier.")
	comment("		Note! Inserting this new tier must be done *outside* the for-loop! This is important! ")
	comment("		What would happen if you included the 'Insert interval tier' command within the for-loop that iterated over the number of intervals in a tier? ")
	comment("		How many tiers would get inserted?")
	comment("	3. Then, get the number of the interval that you just inserted on the new tier.")
	comment("		Notice that one of the arguments is a point in time. This is the start time plus a very small amount (to make sure you are looking *in* the correct spot)")
	comment("	4. Then, use the number of the interval you just created to set its label.")
	comment("")
	comment(" What happens if current_label is *not* equal to the label you're looking for?")
	comment("")
clicked = endPause("Got it!",1)




elsif level = 3
clearinfo
printline Level 'level': INTERMEDIATE TEXTGRID MANIPULATION

elsif level = 4
clearinfo
printline Level 'level': PHONETIC ANALYSIS, WRITING TO FILES
endif


until clicked = 2
endif
printline
printline Finished!
