##############################################################################################################
###########################################################################################################
## This script will adjust boundaries for an interval with a given segment on a given tier
## It is a simplified version of addTier_adjustBoundaries.
##
## It is an edited version of the script add_sibilant_tier_sr.Praat by Eric Doty. The orignal description appears below:
## This script will copy the sibilant segments of interest to a new tier and adjusts for aligner error
##
## Eric Doty
## eric.doty@mail.mcgill.ca
## McGill University, February 2012
## Edited by Thea Knowles
## thea.knowles@mail.mcgill.ca
## McGill University, Nov 2012 - June 2013
## last edit made March 2014
###########################################################################################################


form Make Selection
	comment Enter directory of TextGrids
	comment Include final backslash!
	sentence Directory data/
	comment Specify the tier you'd like to adjust
	positive AdjustmentTier 4
	comment Enter the label and error value (in seconds) for the left 
	comment and right edge of a phoneme
	comment e.g. Positive error means shift boundary to the right
	sentence SoiLabel 1
	real Left_error 0.009
	real Right_error 0.01
	boolean MakeDir 
endform

clearinfo

if makeDir
	createDirectory ("'directory$'1_oldTextGrids")
endif


################## Look at all TextGrids in the directory #################

Create Strings as file list...  myList 'directory$'*.TextGrid
number_files = Get number of strings

# iterate through the file list

for file from 1 to number_files
	select Strings myList
	current_token$ = Get string... file
	Read from file... 'directory$''current_token$'
	object_name$ = selected$ ("TextGrid")
	printline 'object_name$'

################### Look at all intervals on the tier  ####################
	select TextGrid 'object_name$'
	num_segs = Get number of intervals... adjustmentTier

     	for seg_num from 1 to num_segs
		select TextGrid 'object_name$'
		seg_label$ = Get label of interval... adjustmentTier seg_num

##################### Look at *relevant* intervals #####################
		if seg_label$ == soiLabel$ 

	# find stop and word boundaries
			seg_start = Get starting point... adjustmentTier seg_num
			seg_end = Get end point... adjustmentTier seg_num

	# Remove current interval text (we'll put it back in later)
	# Command syntax is "Set interval text... [tier number] [interval number] [text]
	# Since we want to get *rid* of the text, we'll leave the last argument blank

			Set interval text... adjustmentTier seg_num


	# Define & set new boundaries
			new_seg_start = seg_start + left_error
			new_seg_end = seg_end + right_error

			Remove boundary at time... adjustmentTier seg_start
			Insert boundary... adjustmentTier new_seg_start

			Remove boundary at time... adjustmentTier seg_end
			Insert boundary... adjustmentTier new_seg_end

			Set interval text... adjustmentTier seg_num 'soiLabel$'

		endif
	endfor
	
####################### Write and save ###########################

	select TextGrid 'object_name$'

			system cp "'directory$''object_name$'.TextGrid"  'directory$'1_oldTextGrids/'object_name$'.TextGrid
			Write to text file... 'directory$''object_name$'.TextGrid
			
	select all
     	minus Strings myList
     	Remove

endfor

# Clean up
select Strings myList
Remove
print all done!


