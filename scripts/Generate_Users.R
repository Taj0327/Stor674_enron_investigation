script_path <- rstudioapi::getActiveDocumentContext()$path
mother_path <- dirname(dirname(script_path))
script_path <- paste0(mother_path, "/scripts")
mails_path <- paste0(mother_path, '/data/enron_mail_20150507/maildir')

# Create list of usernames in inboxes and remove those users without "sent mails" (inactive account)

users <- data.frame(user.folder = paste0(mails_path, unique(all.fromto.df$to))) # add a user.folder column
sent <- apply(users, 1, function(x){sum(grepl("sent", dir(x)))}) # filter the users by active or not
users <- subset(users, sent != 0)

# Replace user.folder name with e-mail name

users <- users %>%
  mutate(mailname = vector("list", length = nrow(users)))

# There is a sub-folder in the "/sent_items/" folder in pereira-s named "clickathome", after checking the only email's content in it (ads), we choose to remove it from our investigation

all_possible_mailnames <- c() # store all the mailnames so that we can filter the mails by all the mailnames we have

for (i in 1:nrow(users)){
  
  # for each user, list all his folders
  all_folder_names <- list.dirs(users$user.folder[i], recursive=T, full.names=T)
  
  # get all folders named including "sent", so that we can have all the mailnames one uses
  sent_folders <- all_folder_names[grepl("sent", basename(all_folder_names), ignore.case = TRUE)]
  my_namelist <- c() # store the user's mailnames
  
  for (sent_folder in sent_folders){
    
    # get a list of all mails sent
    sentmail <- dir(sent_folder, full.names = T)
    sentmail <- sentmail[file.info(sentmail)$isdir == FALSE]
    
    # for each mail, extract the mailnames the user uses and store it as a list in the dataframe 'users'
    for (j in range(length(sentmail))){
      name <- readLines(sentmail[j], warn = F)[3]
      name <- str_sub(name, 7, nchar(name)-10)
      
      # if the name is not in the list, then add it
      if (!(name %in% my_namelist)){
        my_namelist <- c(my_namelist, name)
        all_possible_mailnames <- c(all_possible_mailnames, name)
      }
      
    }
    
  }
  users$mailname[[i]] <- my_namelist # add the mailname list to one's row
}

# clean all the mailnames with regex, removing @ and special characters, leaving all the dots(.)
users <- users %>%
  mutate(
    mailname = map(mailname, ~ str_replace_all(.x, "[< >*@]", "")) %>%  # Apply regex to each element in the list
      map(~ str_replace_all(.x, "@$", ""))  # Apply second regex
  )

# get a column to connect the mailnames with the names.
users <- users %>%
  mutate(name = str_remove(user.folder, pattern = paste0(mails_path, "/")))

save(users, file = paste0(mother_path, "/results/users.Rdata"))
