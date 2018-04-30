# Openfiles 
# michael wagner. chael@mcgill.ca. August 2009
# Modified by Thea Knowles November 2014
# tknowle3@uwo.ca

# Important: Before truncating, make a back-up of the folder with the data---
# the script shouldn't erase anything, but you never know.

# Place script in same directory as data that needs to be annotated
# Sounds and TextGrids should be in the same directory, and have identical names (except extension)
# the script saves annotated and unannotated in two separated directories,
# consuming the files as you go along. You can interrupt the process at any point, and 
# start the script later. 
#
# If directories 0_original and 1_annotated don't exist yet, click on 'make directories'
# The script automatically also opens the textgrid file if there is one, 
# and it copies the label (.lab) file into both folders (if there is one)
#
# Every soundfile in the folder is brought up in an editor window, the suggested truncation is selected.
# You can change the selection by hand.
# Whatever is selected when you hit 'continue' is what the soundfile will be truncated to.

#
echo Truncate Silence from Soundfiles
printline

# This script opens all the sound files with a particular extension
# and any existing collection within a particular directory.
# the script also opens the corresponding TextGrid file, if there is one.
# for each file for which there is no TextGridFile, 
# a message appears in the output window on the screen.

form Truncate Silence from Soundfiles
	natural silenceThreshhold 50
        natural woi 2
	real marginsize 0.2
	sentence Extension .wav
	boolean Soundfile_in_same_directory_as_script yes
	sentence Directory_sound
	boolean makeDirectory
endform


if makeDirectory
	system mkdir 1_annotated
	system mkdir  2_original
endif 

if soundfile_in_same_directory_as_script
    directory_sound$ = ""
endif   


Create Strings as file list... list 'directory_sound$'*'extension$'
filelist = selected("Strings")

numberFiles = Get number of strings

for ifile to numberFiles
   select Strings list
   filename$ = Get string... ifile
    
   Read from file... 'directory_sound$''filename$'
   soundfile = selected("Sound")

   length = length(filename$)
   length2 = length(extension$)
   length = length - length2
   short$ = left$(filename$, length)

   grid$ = directory_sound$+short$+".TextGrid"
   gridshort$ = short$+".TextGrid"

   labshort$ = short$ + ".lab"

   txtgrd = 0
 
    if fileReadable (grid$)
          Read from file... 'grid$'
	  #Insert interval tier... 4 annotation
	  txtgrd = 1
	  soundgrid = selected("TextGrid")	
     elsif fileReadable(labshort$)
	  txtgrd = 2
	  To TextGrid... label
	  soundgrid = selected("TextGrid")
	  Read Strings from raw text file... 'labshort$'
	 labelfile = selected("Strings")
	  label$ = Get string... 1
	 Remove
	   select soundgrid
           Set interval text... 1 1 	'label$'	
          Insert interval tier... 2 annotation
    else
         txtgrd=3
	 To TextGrid... "splicepoint"
	 soundgrid = selected("TextGrid")
    endif

     select soundfile
     totallength = Get end time

 
     onsettime = 0
     offsettime = totallength

		select soundfile
		editorname$ = "Sound"

		if txtgrd <> 0
			plus soundgrid
			editorname$ = "TextGrid"
		endif

		Edit
		 editor 'editorname$' 'short$'
			 	Select... onsettime offsettime					
				Zoom to selection
				beginPause("Annotate!")                              
				clicked = endPause("Continue",1)

		endeditor
		newsoundgrid = selected("TextGrid")

			system cp 'directory_sound$''filename$' 1_annotated/'filename$'
			system mv 'directory_sound$''filename$' 2_original/'filename$'

			
			if txtgrd = 1
				select newsoundgrid 
				Write to text file... 1_annotated/'gridshort$'

				Remove
				system mv  'directory_sound$''gridshort$'  2_original/'gridshort$'

			elsif txtgrd = 2
				labshort$ = short$ + ".lab"
				select newsoundgrid 
				labtext$ = Get label of interval... 1 1
    				labtext$ = labtext$ + newline$

				select newsoundgrid 
				Write to text file... 1_annotated/'gridshort$'
				Remove
			else
				select newsoundgrid 
				Write to text file... 1_annotated/'gridshort$'
				Remove
			endif
endfor

select filelist
Remove

