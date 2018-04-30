# Clear Praat Info window
clearinfo
printline Generating list of average intensities...

# Set directory and create text file with headers
# Include the final slash in directory on a Mac, or backslash on a PC
directory$ = "/Volumes/SeagateBackupPlusDrive/11_McRae/PirateStudy/Soundfiles/test/"
fileappend "'directory$'averageInt.txt" filename 'tab$' averageInt(dB) 'newline$'

# Create a list of the files you want to look at
Create Strings as file list... list 'directory$'*.wav
nFiles = Get number of strings

# Set up count and sum variabels to add to
count = 0
sum = 0

# Iterate through the file list
for i from 1 to nFiles
	select Strings list
	currentFile$ = Get string... 'i'

# For each file, open it in Praat, query its average intensity, print results to text file
	Read from file... 'directory$''currentFile$'
	objectName$ = selected$("Sound")

	select Sound 'objectName$'
	intensity = Get intensity (dB)

	fileappend "'directory$'averageInt.txt" 'objectName$' 'tab$' 'intensity:4' 'newline$'

	# Set minimum/maximum intensity from first iteration
	if i == 1
		min = intensity
		max = intensity
	endif

# Check each subsequent file to find min & max values
	if intensity < min
		min = intensity
	endif
	if intensity > max
		max = intensity
	endif

# Increase count & sum on each iteration. (count could also be nFiles)
	count = count+1
	sum = sum+intensity

endfor

average = sum/count

fileappend "'directory$'averageInt.txt" 'newline$'Minimum: 'tab$' 'min:4' 'newline$'
fileappend "'directory$'averageInt.txt" Maximum: 'tab$' 'max:4' 'newline$'
fileappend "'directory$'averageInt.txt" Average: 'tab$' 'average:4' 'newline$'

select all
Remove
printline All done!
