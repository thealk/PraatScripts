# REMOVE DUPLICATES FUNCTION for VAS.PRAAT OUTPUT

# This will get rid of duplicate filenames
# Designed to handle output csv files from vas.praat

# Input: dataframe (df) corresponding to csv output from vas.praat. Assumes input is a df that contains columns:
#    - filename
#    - listener
#    - order
# Output:
#    - df_unique: original df with duplicates removed. 'df' matches name provided as input (1st listener presentation)
#    - df_duplicates: df of the files that were duplicated (2nd listener presentation). Original structure preserved

remove_duplicates <- function(file){
     file$listener <- factor(file$listener)
     df_unique_allListeners <- data.frame()
     df_duplicate_allListeners <- data.frame()
     
     for(l in 1:length(levels(file$listener))){
          current_l <- levels(file$listener)[l]
          temp <- subset(file, listener==current_l)
          temp$is_duplicate <- temp$filename %in% temp$filename[duplicated(temp$filename)]
          temp_unique <- subset(temp, is_duplicate=="FALSE")
          temp_duplicate <- subset(temp, is_duplicate=="TRUE")
          
          # Order by listening order & create new column, order2, which corresponds to row number
          temp_duplicate <- temp_duplicate[order(temp_duplicate$filename,
                                                 temp_duplicate$order),] %>%
               mutate(order2 = seq(1:length(filename)))
          # Add keep column that is TRUE if order2 is odd (was the first presentation) and FALSE if order2 is even (was second presentation)
          temp_duplicate$keep <- FALSE
          temp_duplicate$keep[temp_duplicate$order2 %% 2 != 0] <- TRUE
          
          # duplicate1 will get shuffled back in to the main data, duplicate2 will be preserved for ICC analyses later
          temp_duplicate_1 <- subset(temp_duplicate, keep == TRUE) %>%
               select(-is_duplicate, -order2, -keep)
          temp_duplicate_2 <- subset(temp_duplicate, keep == FALSE) %>%
               select(-is_duplicate, -order2, -keep)
          temp_unique <- temp_unique %>%
               select(-is_duplicate)
          
          # Shuffle temp_duplicate_1 back in to temp_unique
          df_unique <- rbind(temp_unique, temp_duplicate_1)
          df_duplicate <- temp_duplicate_2
          
          df_unique_allListeners <- rbind(df_unique_allListeners, df_unique)
          df_duplicate_allListeners <- rbind(df_duplicate_allListeners, df_duplicate)
     }
     
     # Assign return dfs names based on function input
     df_unique_name <- paste(as.character(sys.call()[-1]), "_unique", sep = "")
     df_duplicate_name <- paste(as.character(sys.call()[-1]), "_duplicate", sep = "")
     assign(df_unique_name,
            df_unique_allListeners,envir=parent.frame())
     assign(df_duplicate_name,
            df_duplicate_allListeners,envir=parent.frame())
     
}

# USAGE:
#    remove_duplicates(vwlsb)

# SANITY CHECK:
# If all values from the following line are FALSE, it means there are no duplicates (per listener)
#        subset(vwlsb_unique,listener=="1")$filename %in% subset(vwlsb_unique,listener=="1")$filename[duplicated(subset(vwlsb_unique,listener=="1")$filename)]

# Use this line to plot counts of filenames. All should be equal to 1
#    ggplot(vwlsb_unique, aes(x=filename))+
#         geom_bar()+
#          facet_grid(~listener)

   
   
