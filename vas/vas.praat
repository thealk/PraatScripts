# README
#
# The goal of this script is to collect listener intelligibility ratings
# The script will execute the following tasks:
# 	- Iterate through a directory of .wav files and play them one at a time
#	- Present the listener with a visual analog scale (VAS) 
#	- Allow the listener to click anywhere along the visual analog scale once they've heard the audio clip
#	- Allow them to press a key to continue to the next audio file
# 	- Log the results to a .csv file
#
# Source for original code for procedures for setting up the VAS interface: 
#		https://uk.groups.yahoo.com/neo/groups/praat-users/conversations/topics/8008
#	 	José Joaquín Atria
# 		www.pinguinorodriguez.cl
#
# Notes:
#	Place the script in the same directory containing the audio files
#	UPDATES 9/12: 
#		- This script optionally performs full randomization of the sound file order.
#		- You may select whether or not you would like to see the VAS value output to the screen.
#			- if you are testing the script, this option allows you to ensure what you are clicking is what is being logged (sanity check)
#			- otherwise, you probably want to leave it unchecked so that your listeners don't see a numeric value associated with their selection
#		- The user is unable to press continue until the sound has played (e.g., until the timing of their click from the time the sound started exceeds the duration of the sound clip)
#	
#	This script does not allow the user to replay an audio clip
# 
# TODOs:
# 	- allow replay of sound file in case of emergency
#
# Thea Knowles
# Western University
# tknowle3@uwo.ca
# Last updated: September 2018


form Visual Analog Scale Ratings
	comment Please enter the listener ID
	sentence Listener 01
	comment Please enter the audio file extension
	sentence Ext .wav
	comment Please enter the output .csv file name
	sentence Output_name vas_responses
	comment Please enter the VAS anchor labels
	sentence Left_anchor Low intelligibility
	sentence Right_anchor High intelligibility
	comment
	comment Would you like to randomize the presentation of the files?
	boolean randomize_files 1
	comment
	comment Would you like to see the VAS value output on the screen?
	boolean Show_vas_output
	comment Please ensure the script is in the same directory as the .wav files
endform

clearinfo

# Assumes soundfiles are in the same directory as the script
directory$ = ""

########################
# SET UP OUTPUT FILE
########################

fileappend "'directory$''output_name$'.csv" filename,listener,order,intelligibility,'newline$'


########################
# VAS SET UP & PROCEDURES
########################
# Set default for advancing to next trial to false (changes to true if user clicks button)
continue = 0

# "Scroll bar" dimensions
box["x0"] = 0.15
box["x1"] = 0.85
box["y0"] = 0.2
box["y1"] = 0.21
box["y0margin"] = 0.01
box["y1margin"] = 0.4




procedure drawBox ()
demo Erase all
demo Paint rectangle: "grey", box["x0"], box["x1"], box["y0"], box["y1"]
demo Text: box["x0"]-0.15, "Centre", box["y0"], "Half", left_anchor$
demo Text: box["x1"]+0.15, "Centre", box["y0"], "Half", right_anchor$
endproc

procedure drawButton ()
continue = 0
demo Paint rectangle: "pink", 0.30, 0.70, 0.70, 0.84
demo Text: 0.50, "centre", 0.77, "half", "Continue"
endproc

procedure drawText ()
# Get value from the "scroll bar"
@lineValue()
# If there was a value, print it
if lineValue.value != undefined
.string$ = fixed$(lineValue.value, 2) + "\% "
demo Text: 0.5, "Centre", 0.6, "Half", .string$
endif
endproc

procedure lineValue ()
# This is the percentage of the box clicked; different from just screen value
# Box value is undefined unless the user clicked in the box
.value = undefined
@clickedOnLine()
if clickedOnLine.return
.value = demoX() - box["x0"]
.value = .value * 100 / (box["x1"] - box["x0"])
endif
endproc

procedure clickedOnLine ()
# Check whether user clicked in the acceptable margins of the line
# x margins remain the same as original length (x0, x1)
# y margin allows for users to click above or below the line
.return = 0
if demoX ( ) >= box["x0"] and demoX ( ) < box["x1"] and
... demoY ( ) >= box["y0margin"] and demoY ( ) < box["y1margin"]

.return = 1
endif
endproc


procedure drawTick ()
# Draw a vertical line where the user clicked

# Get value from the "scroll bar"
@lineValue()
# Clear the text area
demo Paint rectangle: background$, 0, 1, box["y1"], 1

@drawButton()
# If there was a value, print it
if lineValue.value != undefined
	@drawBox()
	# Draw the "tick" at the position of the click
	pos = demoX()
	demo Paint rectangle: "black", pos, pos+0.001, box["y0"]-0.05, box["y1"]+0.05

# Select in form if you want to see the output of drawText() as a sanity check
	if show_vas_output == 1
		@drawText()
	endif
	@drawButton()
endif

endproc



#############
# LAUNCH VAS
#############
	
demo Axes: 0, 1, 1, 0
# Set default for advancing to next trial to false (changes to true if user clicks button)
continue = 0
	
# Background colour
background$ = "white"
demo Times


########################
# INSTRUCTIONS
# ALLOW THE USER TO DECIDE WHEN THEY'RE READY TO START
########################
demo 24
demo Text: 0.50, "centre", 0.0, "half", "Instructions"
demo Text: 0.50, "centre", 0.0, "half", ""
demo 14
demo Text: 0.50, "centre", 0.2, "half", "For each spoken utterance, please indicate your rating on the line from low to high intelligibility."
demo Text: 0.50, "centre", 0.3, "half", "You will not be able to replay the sound, though you are able to adjust your rating if you'd like." 
demo Text: 0.50, "centre", 0.4, "half", "Clicking the Continue button will allow you to advance to the next utterance."
demo Text: 0.50, "centre", 0.4, "half", ""
demo 24
demo Text: 0.50, "centre", 0.6, "half", "Click the button when you're ready to begin."

demo Paint rectangle: "grey", 0.30, 0.70, 0.70, 0.84
demo 24
demo Text: 0.50, "centre", 0.77, "half", "Begin"

while demoWaitForInput ( )
	if demoClickedIn (0.30, 0.70, 0.70, 0.84)
		demo Erase all
		goto BEGIN
	endif
endwhile




########################
# ITERATE THROUGH SOUND FILES AND PLAY THEM 
########################
label BEGIN
demo Erase all
demo 24


Create Strings as file list... list 'directory$'*'ext$'

if randomize_files == 1
	Randomize
endif


nFiles = Get number of strings
for iFile from 1 to nFiles

	# Reset values to default
	continue = 0
	# Default value for intell is 9999 to make cases in which is was not reset identifiable
	intell = 9999


	select Strings list
	filename$ = Get string... 'iFile'
	Read from file... 'directory$''filename$'
	sound_name$ = selected$ ("Sound")
	sound_dur = Get total duration

	# Draw the box
	@drawBox()
	@drawButton()

stopwatch
trial_start_time = stopwatch
time_elapsed = trial_start_time

	select Sound 'sound_name$'
	# asynchronous play allows the script to continue running while the sound is playing
	asynchronous Play


	while continue == 0
		
		# Get input
		while demoWaitForInput ( )
			if demoClicked ( )
				# If clicked in continue box
				# Indicates they have finalized their rating and are ready to continue to the next audio clip
			    if demoClickedIn (0.30, 0.70, 0.70, 0.84)

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
							comment("Sound dur: 'sound_dur:2''tab$'Time: 'time_elapsed:2'")
						clicked = endPause("Okay",1)
					else
						continue = 1
						# Save response to output file
						fileappend "'directory$''output_name$'.csv" 'filename$','listener$','iFile','intell:4','newline$'

						select all
						minus Strings list
						Remove

						demo Erase all
						goto NEXT
					endif
				
				# If they did not click Continue, check to ensure they clicked the VAS line
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

endfor

goto EXIT
label EXIT
demo Erase all
demo Axes: 0, 1, 1, 0
demo Text: 0.50, "centre", 0.77, "half", "All done!"

# FOR SOME REASON I CAN'T GET TO THE EXIT LABEL UNLESS I PRINT TO THE INFO WINDOW.... TODO
printline Thank you! All done!
select all
Remove



