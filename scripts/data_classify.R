library(rstudioapi)
library(stringr)
library(dplyr)
library(purrr)
library(ggplot2)
library(igraph)
library(reshape2)
# This script is to assign the categories to the dataframe

current_script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
source(file.path(current_script_dir, "new_data_classify.R"))
parent_dir <- file.path(current_script_dir, "..")
results_path <- file.path(parent_dir, "results")
# load(paste0(results_path, "/dfs.Rdata"))
# inbox_category <- inboxes.from.to.raw.df %>%
#    mutate(category = sapply(to, function(x) find_label(x,1)))
# sentimental.df <- all.within.fromto.df %>%
#    mutate(sentimental = sapply(to, function(x) find_label(x,2)))

categorized_data <- within_mailpath_df %>%
   group_by(from, to) %>%
   slice_head(n = 2) %>%
 ungroup()
#categorized_data = categorized_data[1:5,]
# 
# run_the_seperate<- function(start, end){
#   temp = within_mailpath_df[start,end]
#   temp[c("sender_department", "receiver_department", "tone")] <- t(apply(temp, 1, function(row) {
#     classify_email_details(email_file = row["path"], sender = row["from"], receiver = row["to"])
#   }))
#   return (temp)
# }
# temp = head(categorized_data,1)
# temp[c("sender_department", "receiver_department", "tone")] <- t(apply(temp, 1, function(row) {
#   classify_email_details(email_file = row["path"], sender = row["from"], receiver = row["to"])
# })) 

# categorized_data[c("sender_department", "receiver_department", "tone")] <- t(apply(categorized_data, 1, function(row) {
#   classify_email_details(email_file = row["path"], sender = row["from"], receiver = row["to"])
# }))  

for (i in 1:nrow(categorized_data)) {
  # Extract the row details
  row <- categorized_data[i, ]
  
  # Classify email details using the provided function
  details <- classify_email_details(
    email_file = row$path,
    sender = row$from,
    receiver = row$to
  )
  
  # Save results back to the DataFrame
  categorized_data$sender_department[i] <- details[1]
  categorized_data$receiver_department[i] <- details[2]
  categorized_data$tone[i] <- details[3]
  
  # Optionally print progress
}
# temp = categorized_data[5,]
# classify_email_details(email_file = temp$path,temp$to,temp$from)

# first_3k = run_the_seperate(1,3000)
# second_3k = run_the_seperate(3001,6000)
# third_3k = run_the_seperate(6001,9000)
# fourth_3k = run_the_seperate(9001,12000)
# fifth_3k = run_the_seperate(12001,14101)
#categorized_data = temp
save(categorized_data, file = file.path(results_path, "categorized.Rdata"))