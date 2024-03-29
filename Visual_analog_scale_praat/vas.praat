# README
#
# The goal of this script is to collect listener perceptual (e.g., intelligibility) ratings
# The script will execute the following tasks:
# 	- Iterate through a directory of .wav files and play them one at a time
#	- Present the listener with a visual analog scale (VAS) 
#	- Allow the listener to click anywhere along the visual analog scale once they've heard the audio clip
#	- Allow them to press a key to continue to the next audio file
# 	- Log the results to a .csv file
# Additionally, if desired by the user, it allows:
#	- Randomization of the sound files
#	- A given percentage of sounds to be played again for reliability purposes
#		- This is rounded down
#		- These files get added to the list before randomization occurs
#	- The user to listen to each recording twice by default
#	- The user to have the option to replay the recording themselves (the timer of the sound is restarted when this button is clicked)
#	- The VAS value to be printed to the screen (helpful as a sanity check to the researcher, less so during actual listening experiments)
#
# Source for original code for procedures for setting up the VAS interface: 
#		https://uk.groups.yahoo.com/neo/groups/praat-users/conversations/topics/8008
#	 	José Joaquín Atria
# 		www.pinguinorodriguez.cl
#
#
# Thea Knowles
# Western University
# tknowle3@uwo.ca
# Last updated: November 2018


form Visual Analog Scale Ratings
	comment Please enter the listener ID
	sentence Listener 01
	comment Is this the first session for this listener?
	boolean First_session 1
	comment If it is not the first session, please indicate the session number
	positive Session_number 1
	comment Please enter the output .csv file name
	sentence Output_name vas_responses
	comment Please enter the VAS anchor labels
	sentence Left_anchor Low intelligibility
	sentence Right_anchor High intelligibility
	comment Would you like to randomize the presentation of the files?
	boolean Randomize_files 1
	comment What percentage of files would you like repeated for reliability?
	real Reliability_percent 10
	comment Would you like to play each sentence twice?
	boolean Play_twice 1
	comment Would you like to see the VAS value output on the screen?
	boolean Show_vas_output
	comment Please ensure the script is in the same directory as the .wav files
endform

clearinfo

# Assumes soundfiles are in the same directory as the script
directory$ = ""
ext$ = ".wav"

########################
# VAS SET UP & PROCEDURES
########################
# Set default for advancing to next trial to false (changes to true if user clicks button)
demo Axes: 0, 100, 100, 0	
# Background colour
background$ = "white"
# Set font
demo Times
# Set default for advancing to next trial to false (changes to true if user clicks button)
continue = 0

# "Scroll bar" dimensions
line["x0"] = 15
line["x1"] = 85
line["y0"] = 20
line["y1"] = 21
line["y0margin"] = 1
line["y1margin"] = 40



procedure drawLine ()
demo Erase all
demo Paint rectangle: "grey", line["x0"], line["x1"], line["y0"], line["y1"]
demo Text: line["x0"]-15, "Centre", line["y0"], "Half", left_anchor$
demo Text: line["x1"]+15, "Centre", line["y0"], "Half", right_anchor$
endproc

procedure drawButton ()
continue = 0
demo Paint rectangle: "pink", 30, 70, 70, 84
demo Text: 50, "centre", 77, "half", "Continue"
endproc

procedure drawText ()
# Get value from the "scroll bar"
@lineValue()
# If there was a value, print it
if lineValue.value != undefined
.string$ = fixed$(lineValue.value, 2) + "\% "
demo Text: 50, "Centre", 60, "Half", .string$
endif
endproc

procedure lineValue ()
	# This is the percentage of the box clicked; different from just screen value
	# Box value is undefined unless the user clicked in the box
	.value = undefined
	@clickedOnLine()
	if clickedOnLine.return
	.value = demoX() - line["x0"]
	.value = .value * 100 / (line["x1"] - line["x0"])
	endif
	endproc

	procedure clickedOnLine ()
	# Check whether user clicked in the acceptable margins of the line
	# x margins remain the same as original length (x0, x1)
	# y margin allows for users to click above or below the line
	.return = 0
	if demoX ( ) >= line["x0"] and demoX ( ) < line["x1"] and
	... demoY ( ) >= line["y0margin"] and demoY ( ) < line["y1margin"]

	.return = 1
	endif
endproc


procedure drawTick ()
	# Draw a vertical line where the user clicked

	# Get value from the "scroll bar"
	@lineValue()
	# Clear the text area
	demo Paint rectangle: background$, 0, 100, line["y1"], 100

	@drawButton()
	# If there was a value, print it
	if lineValue.value != undefined
		@drawLine()
		# Draw the "tick" at the position of the click
		pos = demoX()
		demo Paint rectangle: "black", pos, pos+0.1, line["y0"]-5, line["y1"]+5

	# Select in form if you want to see the output of drawText() as a sanity check
		if show_vas_output == 1
			@drawText()
		endif
		@drawButton()
		@drawPlayAgainButton
	endif

endproc


procedure drawPlayAgainButton()
	demo Paint rectangle: "grey", 90, 110, 100, 110
	demo Text: 100, "centre", 105, "half", "Repeat"
endproc

procedure refreshScreen()
	demo Font size: 24
	@drawLine()
	@drawButton()
	@drawPlayAgainButton()
endproc

########################
# INSTRUCTIONS
# ALLOW THE USER TO DECIDE WHEN THEY'RE READY TO START
########################
demo 24
demo Text: 50, "centre", 0.0, "half", "Instructions"
demo Text: 50, "centre", 0.0, "half", ""
demo 14
demo Text: 50, "centre", 20, "half", "For each spoken utterance, please indicate your rating on the line from low to high intelligibility."
demo Text: 50, "centre", 30, "half", "You will not be able to replay the sound, though you are able to adjust your rating if you'd like." 
demo Text: 50, "centre", 40, "half", "Clicking the Continue button will allow you to advance to the next utterance."
demo Text: 50, "centre", 40, "half", ""
demo 24
demo Text: 50, "centre", 60, "half", "Click the button when you're ready to begin."

demo Paint rectangle: "grey", 30, 70, 70, 84
demo 24
demo Text: 50, "centre", 77, "half", "Begin"

while demoWaitForInput ( )
	if demoClickedIn (30, 70, 70, 84)
		demo Erase all
		goto BEGIN
	endif
endwhile





########################
# BEGIN
########################

label BEGIN
demo Erase all
demo 24


# IF FIRST SESSION
if first_session == 1
	########################
	# SET UP OUTPUT FILE AND LOG FILE
	########################

	fileappend "'directory$''output_name$'.csv" filename,listener,session,order,percentage,'newline$'
	fileappend "'directory$'logfile_'listener$'.csv" filename,listener,session_number,'newline$'
	

	Create Strings as file list... list 'directory$'*'ext$'

	if randomize_files == 1
		Randomize
	endif

	#######################
	# RELIABILITY
	#######################

	nFiles_orig = Get number of strings

	if reliability_percent > 0
		#nReliability = round(nFiles_orig * (reliability_percent/100))
		nReliability = nFiles_orig div reliability_percent
		#printline nFiles_orig: 'nFiles_orig''tab$'nReliability: 'nReliability'

		# If the user input a value > 0 for reliability, but that percentage results in rounding to 0, change to 1
		# 	e.g., if there are only 4 files, and the user put 10%, this would equal 
		if nReliability = 0
			nReliability = 1
		endif

		# Copy the original list of files to sample from
		# By always sampling from the original list and removing rows as you go, you won't resample
		Copy... list_orig
		Copy... list_untouched
		select Strings list

		for i from 1 to nReliability
			
			# Get the number of strings left in list_orig for each loop
			select Strings list_orig
			nFiles_orig = Get number of strings
			# Get a random row
			randRowInt = randomInteger (1, 'nFiles_orig')
			
			# Get the string associated and then remove it from list_orig to prevent taking the same file more than once
			select Strings list_orig
			randRow$ = Get string... 'randRowInt'
			Remove string... 'randRowInt'
			#printline 'randRow$'

			select Strings list
			Insert string... 0 'randRow$'
		endfor
	else
		#printline nFiles_orig: 'nFiles_orig''tab$'nReliability: 'reliability_percent'
	endif



	########################
	# ITERATE THROUGH SOUND FILES AND PLAY THEM 
	########################

	select Strings list
	# Randomize again to mix in reliability clips
	if randomize_files == 1
		Randomize
	endif

	# SAVE TABLE SO THAT USER CAN PICK UP AGAIN LATER
	Save as raw text file... 'directory$'listener_'listener$'_order.txt

	sessionStart = 1

# IF NOT FIRST SESSION 
else
	Read Strings from raw text file... 'directory$'listener_'listener$'_order.txt
	Rename... list

	# Open log file
	#Read table from comma-separated file... "'directory$''vas_output_name$'.csv"
	Read Table from comma-separated file... 'directory$'logfile_'listener$'.csv
	nCompleted = Get number of rows
	sessionStart = nCompleted+1
endif

select Strings list
nFiles = Get number of strings
for iFile from sessionStart to nFiles

	# Reset values to default
	continue = 0

	# Default value for intell is 9999 to make cases in which is was not reset identifiable
	intell = 9999
	# Changing this to allowed_to_advance to make it distinct from intell values
	allowed_to_advance = 0

	select Strings list
	filename$ = Get string... 'iFile'

	repeated = 0 
	while repeated < 1
		Read from file... 'directory$''filename$'
		sound_name$ = selected$ ("Sound")
		sound_dur = Get total duration

		# Refresh screen
		@refreshScreen()
		

		# Begin timing the user to prevent them from clicking Continue too early
		stopwatch
		trial_start_time = stopwatch
		time_elapsed = trial_start_time

		select Sound 'sound_name$'
		# asynchronous play allows the script to continue running while the sound is playing
		asynchronous Play

		if play_twice == 0
			repeated = 1
		endif


		while continue == 0
			
			# Get input
			while demoWaitForInput ( )
				if demoClicked ( )

					# Only allowed to continue if have finished listening to the sound AND intell has been reset (vas clicked)
					if time_elapsed > sound_dur 
						if intell <> 9999
							allowed_to_advance = 1
						endif
					endif
					
					# If clicked in continue box
					# Indicates they have finalized their rating and are ready to continue to the next audio clip
				    if demoClickedIn (30, 70, 70, 84)

						time_clicked = stopwatch
						time_elapsed = time_elapsed + time_clicked

						# Ensure a rating was made
						if intell == 9999
							beginPause("Incomplete")
								comment("Please indicate your rating by clicking along the scale.")
								comment("Only click Continue after you have given your rating.")
							clicked = endPause("Okay",1)
						elsif time_elapsed < sound_dur
							beginPause("Clicked too soon")
								comment("You cannot advance until the sound is finished playing")
								comment("Sound duration: 'sound_dur:2''tab$'Time: 'time_elapsed:2'")
							clicked = endPause("Okay",1)
						else
							if repeated == 0
								asynchronous Play
								repeated = 1
							
							
								continue = 1

								# Save response to output file
								fileappend "'directory$''output_name$'.csv" 'filename$','listener$','session_number','iFile','intell:4','newline$'

								select all
								minus Strings list
								Remove

								demo Erase all
								goto NEXT
							else
								printline ERROR: what is value of repeated?
							endif
						endif
					
					# If they clicked in the play again button
					elsif demoClickedIn (90, 110, 100, 110)
						select Sound 'sound_name$'
						asynchronous Play

						# Begin stopwatch again
						stopwatch
						trial_start_time = stopwatch
						time_elapsed = trial_start_time

					# If they didn't click either button, check to ensure they clicked the VAS line
					else
						@clickedOnLine()
						if clickedOnLine.return
							# Redraw if there's been a click
							@drawTick()
							@lineValue()
							intell = lineValue.value
						endif
					endif 
				endif
			endwhile
		endwhile

		label NEXT
	endwhile
	fileappend "'directory$'logfile_'listener$'.csv" 'filename$','listener$','session_number','newline$'
endfor

goto EXIT
label EXIT
demo Erase all
demo Axes: 0, 100, 100, 0
demo Text: 50, "centre", 77, "half", "All done!"

printline Thank you! All done!
select all
Remove



