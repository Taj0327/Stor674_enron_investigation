# This script downloads the enron email dataset from 'https://www.cs.cmu.edu/~enron/enron_mail_20150507.tar.gz' 
# to the \data folder under the project and unzip it. Then it loads all the email's names and user names.

library(rstudioapi)

script_path <- rstudioapi::getActiveDocumentContext()$path
mother_path <- Sys.getenv("mother_path")

enron_url <- "https://www.cs.cmu.edu/~enron/enron_mail_20150507.tar.gz"
dest_file <- paste0(moher_path, "/data/enron_mail_201505.tar.gz")

download_data <- function(mother_path=mother_path){
  options(timeout = 1000)
  download.file(enron_url, destfile = dest_file, mode = "wb")
  cat("File downloaded:", dest_file, "\n")
  
  # 解压文件到当前目录
  untar(dest_file, exdir = paste0(mother_path, "/data/enron_mail_20150507"))
  cat("File extracted. \n")
  
  # 删除压缩包
  file.remove(dest_file)
  cat("Compressed file removed.\n")
}