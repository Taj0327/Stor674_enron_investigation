# This script downloads the enron email dataset from 'https://www.cs.cmu.edu/~enron/enron_mail_20150507.tar.gz' 
# to the \data folder under the project and unzip it. Then it loads all the email's names and user names.

library(rstudioapi)

script_path <- rstudioapi::getActiveDocumentContext()$path
mother_path <- dirname(dirname(script_path))
script_path <- paste0(mother_path, "/scripts")

enron_url <- "https://www.cs.cmu.edu/~enron/enron_mail_20150507.tar.gz"
dest_file <- paste0(mother_path, "/data/enron_mail_20150507.tar.gz")

download_data <- function(mother_path=mother_path){
  options(timeout = 2000)
  download.file(enron_url, destfile = dest_file, mode = "wb")
  cat("File downloaded:", dest_file, "\n")
  
  # untar the file to 
  untar(dest_file, exdir = paste0(mother_path, "/data/enron_mail_20150507"))
  cat("File extracted. \n")
  
  # delete the compressed file
  file.remove(dest_file)
  cat("Compressed file removed.\n")
}