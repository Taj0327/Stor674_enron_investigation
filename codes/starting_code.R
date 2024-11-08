# E-mail corpus consists of nested folders per user with e-mails as text files
# Create list of all available e-mails
rm(list=ls())

#Retrieval all files in the maildir
emails.all.files <- list.files("enron_mail_20150507/maildir/", full.names = T, recursive = T)
length(emails.all.files)

#Filter by inbox only
emails.inbox.files <- emails.all.files[grep("/inbox", emails.all.files)]
length(emails.inbox.files)

# Create list of sender and receiver (inbox owner)
inboxes.from.to.raw.df <- data.frame(
  from = apply(as.data.frame(emails.inbox.files), 1, function(x){readLines(x, warn = F)[3]}),
  to = emails.inbox.files,
  stringsAsFactors = F
)

#Let's focus on email communications inside enron.

# String manipulation - keep only "xx@enron.com" and strip all but username
# e.g., inboxes[1,1] = heather.dunton
#       inboxes[1,2] = allen-p

#this part can be done using commands from the class
library(stringr) # String manipulation
inboxes.from.to.raw.df <- inboxes.from.to.raw.df[grepl("@enron.com", inboxes.from.to.raw.df$from),]
inboxes.from.to.raw.df$from <- str_sub(inboxes.from.to.raw.df$from, 7, nchar(inboxes.from.to.raw.df$from) - 10)
inboxes.from.to.raw.df$to <- sapply(str_split(inboxes.from.to.raw.df$to, "/"), "[", 4)

# Create list of usernames in inboxes
# and remove those users without "sent mails" (inactive account)
users <- data.frame(user.folder = paste0("enron_mail_20150507/maildir/", unique(inboxes.from.to.raw.df$to)))
sent <- apply(users, 1, function(x){sum(grepl("sent", dir(x)))})
users <- subset(users, sent != 0)

# Replace user.folder name with e-mail name
users$mailname <- NA
for (i in 1:nrow(users)){
  sentmail <- dir(paste0(users$user.folder[i], "/sent_items/"))
  name <- readLines(paste0(users$user.folder[i], "/sent_items/", sentmail[1]), warn = F)[3]
  name <- str_sub(name, 7, nchar(name)-10)
  users$mailname[i] <- name
}

users$user <- str_sub(users$user.folder, 9)
inboxes <- merge(inboxes.from.to.raw.df, by.x="to", users, by.y="user")
inboxes.from.to.df <- data.frame(from = inboxes$from, to = inboxes$mailname)

inboxes.from.to.df$from <- as.character(inboxes.from.to.df$from)
inboxes.from.to.df$to <- as.character(inboxes.from.to.df$to)

# Future process the data 
#only e-mails between inbox users
#inboxes.from.to.df <- inboxes.from.to.df[inboxes.from.to.df$from %in% inboxes.from.to.df$to,]

# Remove no.address
#inboxes.from.to.df <- subset(inboxes.from.to.df, from != "no.address" & to != "no.address")

# Remove emails to self
#inboxes.from.to.df <- subset(inboxes.from.to.df, inboxes.from.to.df$from != inboxes.from.to.df$to)

