#Part 1#########################################################################
library(rstudioapi)
library(dplyr)

script_path <- rstudioapi::getActiveDocumentContext()$path
mother_path <- dirname(dirname(script_path))
script_path <- paste0(mother_path, "/scripts")
mails_path <- paste0(mother_path, '/data/enron_mail_20150507/maildir')

# Retrieval all files in the maildir

emails.all.files <- list.files(mails_path, full.names = T, recursive = T)
cat('The dataset contains', length(emails.all.files), 'emails in total. \n')

# can save the files into the /results folder so that next time won't need to read the filenames again
# save(emails.all.files, file = paste0(mother_path, "/results/emails_all_files.Rdata")) 
# load(file = paste0(mother_path, "/results/emails_all_files.Rdata"))

# Filter by inbox emails only with regex

emails.inbox.files <- emails.all.files[grep("/inbox", emails.all.files)]
cat('The dataset contains', length(emails.inbox.files), 'inbox mails in total. \n')

# can save the files into the /results folder so that next time won't need to read the inbox email filenames again
# save(emails.inbox.files, file = paste0(mother_path, "/results/emails_inbox_files.Rdata"))
# load(file = paste0(mother_path, "/results/emails_inbox_files.Rdata"))

# Create list of sender and receiver (inbox owner)

inboxes.from.to.raw.df <- data.frame(
  from = apply(as.data.frame(emails.inbox.files), 1, function(x){readLines(x, warn = F)[3]}), # read all the FROM lines
  to = emails.inbox.files, # use the folder name for TO
  stringsAsFactors = F # remain the strings as characters
)

# Continue processing inboxes.from.to.raw.df

inboxes.from.to.df <- inboxes.from.to.raw.df %>%
  filter(grepl("@enron.com", from))  # Filter for inside-company emails by filtering all the address end with "@enron.com"

inboxes.from.to.df <- inboxes.from.to.df %>% mutate(
  from = str_sub(from, 7, nchar(from) - 10),  # Extract "FROM" email address by cutting "@enron.com" in the end
  to = str_remove(to, pattern = mails_path),   # Extract "TO" name from folder name
  to = sapply(str_split(to, "/"), "[", 2)
)

all.from.to.raw.df <- data.frame(
  from = apply(as.data.frame(emails.all.files), 1, function(x){readLines(x, warn = F)[3]}), # read all the FROM lines
  to = emails.all.files, # use the folder name for TO
  stringsAsFactors = F # remain the strings as characters
)

all.fromto.df <- all.from.to.raw.df %>%
  filter(grepl("@enron.com", from))  # Filter for inside-company emails by filtering all the address end with "@enron.com"

all.fromto.df <- all.fromto.df %>% mutate(
  from = str_sub(from, 7, nchar(from) - 10),  # Extract "FROM" email address by cutting "@enron.com" in the end
  to =  str_remove(to, pattern = mails_path),   # Extract "TO" name from folder name
  to = sapply(str_split(to, "/"), "[", 2)
)

within_mailpath_df <- all.from.to.raw.df %>%
  filter(grepl("@enron.com", from)) %>%
  mutate(path = to) %>%
  mutate(to = str_remove(to, pattern = mails_path)) %>%
  mutate(to = sapply(str_split(to, "/"), "[", 2),
         from = str_sub(from, 7, nchar(from) - 10))

#Part 2##############################################################################

load(paste0(mother_path, "/results/users.Rdata"))

#Part 3#########################################################################
# filter the mails by asking both the sender and receivers are in our users list
inboxes.within.fromto.df <- inboxes.from.to.df %>%
  filter(from %in% users$mailname)
# print(inboxes.within.fromto.df)

# match the mailnames with names
inboxes.within.fromto.df <- inboxes.within.fromto.df %>%
  mutate(match_row = match(from, users$mailname)) %>%
  filter(!is.na(match_row)) %>%
  mutate(name = users$name[match_row], from = name) %>%
  select(-match_row, -name)

# similarly
all.within.fromto.df <- all.fromto.df %>%
  filter(from %in% unique(users$mailname))

# match the mailnames with names
all.within.fromto.df <- all.within.fromto.df %>%
  mutate(match_row = match(from, users$mailname)) %>%
  filter(!is.na(match_row)) %>%
  mutate(name = users$name[match_row], from = name) %>%
  select(-match_row, -name)

# filter out all those emails sent
all.within.fromto.df <- all.within.fromto.df %>%
  filter(from != to)

within_mailpath_df <- within_mailpath_df %>%
  mutate(match_row = match(from, users$mailname)) %>%
  filter(!is.na(match_row)) %>%
  mutate(name = users$name[match_row], from = name) %>%
  select(-match_row, -name)

# filter out all those emails sent
within_mailpath_df <- within_mailpath_df %>%
  filter(from != to)

###############################################################################


# save the results into /results
save(inboxes.from.to.raw.df, inboxes.from.to.df, inboxes.within.fromto.df, 
     all.fromto.df, all.within.fromto.df, 
     file = paste0(mother_path, "/results/dfs.Rdata"))

# if you want to save the within_mailpath to /results, use the code below
# save(within_mailpath_df, file = paste0(mother_path, "/results/within_mailpath.Rdata"))
