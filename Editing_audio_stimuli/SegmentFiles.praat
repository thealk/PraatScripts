

form SEGMENT FILES
	sentence File_to_read_from: \\Crl\langdev\Experiments\NVPlaus\Sounds\NVPlaus2.wav
	sentence Directory_to_save_segmented_files: \\Crl\langdev\Experiments\NVPlaus\Sounds\NVPlaus2segmented\
endform

select all
nocheck Remove

sound = Read from file... 'file_to_read_from$'
text = To TextGrid (silences)...  45 0 -40 0.8 0.02 silent sounding
select all
Extract intervals where... 1 no "is equal to" sounding
select text
plus sound
Remove

select all
numberOfSounds = numberOfSelected()

for i to numberOfSounds
	sound_'i' = selected("Sound", 'i')
endfor

for i to numberOfSounds
	select sound_'i'
	Write to AIFF file... 'directory_to_save_segmented_files$''i'.aiff
endfor

select all
Remove