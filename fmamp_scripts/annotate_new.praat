# Openfiles 
# michael wagner. chael@mcgill.ca. August 2009

# Important: Before truncating, make a back-up of the folder with the data---
# the script shouldn't erase anything, but you never know.

# Place script in same directory as data that needs to be truncated
# Sounds and TextGrids should be in the same directory, and have identical names (except extension)
# the script saves truncated and untruncated in two separated directories,
# consuming the files as you go along. You can interrupt the process at any point, and 
# start the script later. 
#
# If directories truncated/ and untruncated/ don't exist yet, click on 'make directories'
# The script automatically also truncates the textgrid file if there is one, 
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
	comment Is the script in the same directory as the soundfiles?
	boolean Yes yes
	comment If not, enter the directory below
	sentence Directory_sound
	comment Do you want to make new directories for the annotated folders?
	boolean makeDirectory
	comment Enter the extension of the sound files (.wav, etc)
	sentence Extension .wav
endform


if makeDirectory
	system mkdir 2_annotated
	system mkdir  1_original
	system mkdir 3_noSOI
endif 

if yes
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
         # Insert interval tier... 2 annotation
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
					boolean ("NoSOI",0)                                 
				clicked = endPause("Continue",1)

		endeditor
		newsoundgrid = selected("TextGrid")

		if noSOI=0

			system cp 'directory_sound$''filename$' 2_annotated/'filename$'
			system mv 'directory_sound$''filename$' 1_original/'filename$'

			
			if txtgrd = 1
				select newsoundgrid 
				Write to text file... 2_annotated/'gridshort$'

				Remove
				system mv  'directory_sound$''gridshort$'  1_original/'gridshort$'
    				#system cp 'directory_sound$''labshort$'  1_original/'labshort$'
   				#system mv 'directory_sound$''labshort$'  2_annotated/'labshort$'

			elsif txtgrd = 2
				labshort$ = short$ + ".lab"
				select newsoundgrid 
				labtext$ = Get label of interval... 1 1
    				labtext$ = labtext$ + newline$
				labtext$ > 2_annotated/'labshort$'

				#system cp 'directory_sound$''labshort$'  1_original/'labshort$'
				#system mv 'directory_sound$''labshort$'  2_annotated/'labshort$'
				select newsoundgrid 
				Write to text file... 2_annotated/'gridshort$'
				Remove
			else
				select newsoundgrid 
				Write to text file... 2_annotated/'gridshort$'
				Remove
			endif

		else 
			select soundfile 
		        Remove

			system cp 'directory_sound$''filename$' 1_original/'filename$'
			system mv 'directory_sound$''filename$' 3_noSOI/'filename$'
			if txtgrd = 1
				select soundgrid
				Write to text file... 3_noSOI/'gridshort$'
				Remove
				system mv  'directory_sound$''gridshort$'  1_original/'gridshort$'
				#system cp  'directory_sound$''gridshort$'  1_original/'labshort$'
				#system mv  'directory_sound$''gridshort$'  3_noSOI/'labshort$'
			elsif txtgrd = 2
				select newsoundgrid 
				labtext$ = Get label of interval... 1 1
    				labtext$ = labtext$ + newline$
				labtext$ > 3_noSOI/'labshort$'

				system cp 'directory_sound$''labshort$'  1_original/'labshort$'
				#system mv 'directory_sound$''labshort$'  3_noSOI/'labshort$'
				select newsoundgrid 
				Write to text file... 3_noSOI/'gridshort$'
				Remove
			endif

			printline  'filename$' was *not* truncated and saved!
		endif
	
	
endfor

select filelist
Remove

