create_subtable <- function(df, i){
  ### create a sub-mail-count table of i-th cluster
  
  c1 <- df$cluster[i]
  indices <- all_names %in% c1[[i]]
  mytable <- mail_count_table[indices, indices]
  diag(mytable) <- 0
  
  return(mytable)
}

