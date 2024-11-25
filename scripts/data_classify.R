
library(rstudioapi)
library(stringr)
library(dplyr)
library(purrr)
library(ggplot2)
library(igraph)
library(reshape2)
current_script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
source(file.path(current_script_dir, "classify_email_type.R"))
inbox_category <- inboxes.from.to.raw.df %>%
   mutate(category = sapply(to, function(x) find_label(x,1)))
sentimental.df <- all.within.fromto.df %>%
   mutate(sentimental = sapply(to, function(x) find_label(x,2)))

parent_dir <- file.path(current_script_dir, "..")
results_path <- file.path(parent_dir, "results")
save(inbox_category,sentimental.df, file = file.path(results_path, "categorized.Rdata"))