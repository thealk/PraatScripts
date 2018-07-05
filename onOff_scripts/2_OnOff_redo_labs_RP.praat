# Make .lab files from retranscribed rainbow passage
# We had to retranscribe the rainbow passage for everyone because there were many misreads
# As a result, each utterance now needs a unique .lab, as opposed to a stock RP text .lab
# New transcripts are in spreadsheet Retranscribed_RP.csv, with columns File and ActualTranscription

clearinfo

retranscription$ = "retranscribing_RP.csv"
directory$ = "/Users/thea/Google Drive/PhD Projects/OnOff_Data/retranscribe/"

Read Table from comma-separated file... 'directory$''retranscription$'
transcripts_tab$ = selected$ ("Table")
nFiles = Get number of rows

file_col$ = "File"
lab_col$ = "ActualTranscription"

for i from 1 to nFiles
	filename$ = Get value... i 'file_col$'
	filename_short$ = left$(filename$, length(filename$)-9)
	printline 'filename_short$'
	lab$ = Get value... i 'lab_col$'
	writeFileLine: "'directory$''filename_short$'_rp.lab", "'lab$'"
endfor

printline All done!

select all
Remove