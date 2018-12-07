# This script makes a spectral slice of part of all non-empty intervals on a given tier 
# and saves the bin number, frequency, and power density to a csv file
# Thea Knowles
# McGill University, June 2014
# thea.knowles@gmail.com 

form Make Selection
	comment Enter directory of TextGrids and sound files
	sentence Directory /Users/mcgillLing/11_HYB/spectralScript
	comment Which tier contains the segments of interest?
	positive Soi_tier 3
	comment How much of the segment would you like to use for the spectral slice? 
	comment (enter time in seconds)
	positive Time 0.05
endform


clearinfo

if right$(directory$,1)<>"/"
	directory$ = "'directory$'/"
endif

fileappend "'directory$'spectral_slice_info.txt" filename,segment,bin,frequency,powerDensity,'newline$'


Create Strings as file list...  myList 'directory$'*.TextGrid
number_files = Get number of strings

for file from 1 to number_files
	select Strings myList
	filename$ = Get string... file
	Read from file... 'directory$''filename$'
	name$ = selected$ ("TextGrid")
	Read from file... 'directory$''name$'.wav
	select TextGrid 'name$'
	num_segs = Get number of intervals... soi_tier

     	for seg_num from 1 to num_segs
		select TextGrid 'name$'
		seg_label$ = Get label of interval... soi_tier seg_num
		if seg_label$ <> ""
			start = Get start point... soi_tier seg_num
			end = Get end point... soi_tier seg_num
			mid = (start+end)/2
			new_start = mid-(time/2)
			new_end = mid+(time/2)
			#printline 'start' 'new_start:4' 'mid:4' 'new_end:4' 'end'

			# opening both the sound and textgrid in the editor keep the spectral slices from popping up
			# the editor will still open and close for each file, but it won't stay open
			select Sound 'name$'
			plus TextGrid 'name$'
			Edit
			editor TextGrid 'name$'
				do ("Select...", new_start, new_end)
				do ("View spectral slice")
				
				Close
			endeditor

			spect_name$ = selected$("Spectrum")
			select Spectrum 'spect_name$'
			num_bins = Get number of bins
			bin_width = Get bin width
			for bin from 1 to num_bins
				frequency = Get frequency from bin number... bin
				real = Get real value in bin... bin
				imag = Get imaginary value in bin... bin

				# source for conversion below for powerDensity:
				# Mohamed Al-Khairy, Phonetics Lab, University of Florida
				# https://uk.groups.yahoo.com/neo/groups/praat-users/conversations/messages/1603

				powerDensity = 10 * log10 (2 * (('real')^2 + ('imag')^2)*'bin_width' / 4e-10)

				fileappend "'directory$'spectral_slice_info.txt" 'name$','seg_label$','bin','frequency','powerDensity','newline$'

			
			endfor
		endif
	endfor
endfor

system mv "'directory$'spectral_slice_info.txt" "'directory$'spectral_slice_info.csv"