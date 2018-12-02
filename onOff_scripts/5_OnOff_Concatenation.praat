################################################################################
# This script concatenates a number of sound files with a specified
# silence period in between (intended to be a response period) in
# a random order for perceptual presentation of speech stimuli.
# 10% of items will be doubled for reliability (randomly).
#
# If multiple listener tracks are needed, num_listeners will
# specify the number of times the script should be run.
# 
# Due to length, the script will cut each track into two parts.
#
# Ding notification goes off every 10 samples, starting before
# the first sound. The ding sound effect was created by Tim Kahn
# and is available here: https://freesound.org/people/tim.kahn/sounds/91926/
#
# The dingsil.wav file is Tim's ding concatenated with 1.5s of leading silence
# resampled at 44.1 kHz to match the samples. dingsil.wav is in a separate
# child directory called Ding to avoid it being included with the
# speech samples.
# 
# Two additional subfolders need to be specified: Chains, and Output
# Chains stores the samples concatenated with the response silence, 
# and Output stores the final output files for each listener.
# 
# Daryn Cushnie-Sparrow, 2018 
# Western University
# dcushni@uwo.ca
#
################################################################################

form Directory info
	sentence Directory C:/Users/daryncsparrow/Desktop/WIStops/Perceptual/
	sentence Directory_chains C:/Users/daryncsparrow/Desktop/WIStops/Perceptual/Chains/
	sentence Directory_output C:/Users/daryncsparrow/Desktop/WIStops/Perceptual/Output/
	positive Silence_length 3
	positive Num_listeners 1
endform
clearinfo

# Silence creation
Create Sound from formula: "silence", 1, 0, silence_length, 44100, "0"

# File list
Create Strings as file list... orig_list 'directory$'*.wav
num_files = Get number of strings

# Chain creation can happen outside of the listener loop
# because it only needs to happen once. 

# Create an empty strings list for chains using a dummy .txt file
# super hacky way to do this...
Create Strings as file list... chainList 'directory_chains$'
num_chains_start = Get number of strings
for empty to num_chains_start ; empty list loop
	Remove string: 1
endfor ; empty list loop

# open each file, concatenate with silence to form a chain
for f from 1 to num_files ; file loop before chains
	current_token$ = "NA"
	object_name$ = "NA"
	chain_name$ = "NA"
	select Strings orig_list
	current_token$ = Get string... 'f'
	Read from file... 'directory$''current_token$'
	object_name$ = selected$ ("Sound")
	select Sound 'object_name$'
	plus Sound silence
	Concatenate
	selectObject: "Sound chain"
	chain_name$ = object_name$ + "_ch"
	Save as WAV file: directory_chains$ + chain_name$ + ".wav"
	select Strings chainList
	Insert string... 1 'chain_name$'

	# clean up in between files
	select all
	minus Strings orig_list
	minus Sound silence
	minus Strings chainList
	Remove
endfor ; file loop before chains
printline Chains done


###############################################################################
# PROCEDURE FOR TRACK CREATION
##############################################################################

procedure track

# listener number
listener$ = "listener'listen'"
printline 'listener$' 'measure$'

# Make list of chains and copy this for reliability
select Strings chainList
Copy: "reliabilityList"

# Randomize the list of chains
select Strings chainList
Randomize
Save as text file: directory_output$ + listener$ + measure$ + "_Chain_List.txt"

select Strings reliabilityList
number_of_items = Get number of strings
number_of_doubles = number_of_items div 10
Randomize

# Remove 90% of items - means that 10% will have been doubled
while number_of_items > number_of_doubles
	select Strings reliabilityList
	Remove string: 1
	number_of_items = Get number of strings
endwhile

# Save this list
Save as text file: directory_output$ + listener$ + measure$ + "_Reliability_List.txt"

# Select both strings and append into a combined list
select Strings chainList
plus Strings reliabilityList
Append
select Strings appended
Rename: "completeList"
Randomize
Save as text file: directory_output$ + listener$ + measure$ + "_Complete_List.txt"

select Strings completeList
number_of_total = Get number of strings
total_half = number_of_total div 2
total_half_next = total_half + 1
counter = 0
Read from file: directory$ + "Ding/dingsil.wav"

# first half
for total_one from 1 to total_half
	select Strings completeList
	totalName$ = Get string: total_one
	totalFile$ = totalName$ + ".wav"
	Read from file: directory_chains$ + totalFile$
	counter = counter + 1
	if counter = 10
		Read from file: directory$ + "Ding/dingsil.wav"
		counter = 0
	endif
endfor

# select everything except lists
select all
minus Strings orig_list
minus Sound silence
minus Strings chainList
minus Strings reliabilityList
minus Strings completeList

# Concatenate recoverably - generates a TextGrid
Concatenate recoverably
select Sound chain
Save as WAV file: directory_output$ + listener$ + measure$ + "_part1.wav"
select TextGrid chain
Save as text file: directory_output$ + listener$ + measure$ + "_part1.TextGrid"

# Clean up
select all
minus Sound silence
minus Strings orig_list
minus Strings chainList
minus Strings reliabilityList
minus Strings completeList
Remove
printline All done with first half for 'listener$' 'measure$'

# second half
counter = 0
for total_two from total_half_next to number_of_total
	select Strings completeList
	totalName$ = Get string: total_two
	totalFile$ = totalName$ + ".wav"
	Read from file: directory_chains$ + totalFile$
	counter = counter + 1
	if counter = 10
		Read from file: directory$ + "Ding/dingsil.wav"
		counter = 0
	endif
endfor

# select everything except lists
select all
minus Strings orig_list
minus Sound silence
minus Strings chainList
minus Strings reliabilityList
minus Strings completeList

# Concatenate recoverably - generates a TextGrid
Concatenate recoverably
select Sound chain
Save as WAV file: directory_output$ + listener$ + measure$ + "_part2.wav"
select TextGrid chain
Save as text file: directory_output$ + listener$ + measure$ + "_part2.TextGrid"

# Clean up
select all
minus Sound silence
minus Strings orig_list
minus Strings chainList
#minus Strings reliabilityList
#minus Strings completeList
Remove
printline All done with 'listener$' 'measure$'

endproc
##################################################################################

for listen to num_listeners ; listener for loop
	# measure 1: intelligibility
	measure$ = "_intell"
	call track

	# measure 2: precision
	measure$ = "_precision"
	call track

	# measure 3: rate
	measure$ = "_rate"
	call track

	# measure 4: monopitch
	measure$ = "_monopitch"
	call track

	printline All done with 'listener$'
endfor ; listener for loop

printline All done!
