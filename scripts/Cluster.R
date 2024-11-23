library(igraph)
library(rstudioapi)
library(dplyr)
set.seed(327)

# get the path and load essential data
script_path <- rstudioapi::getActiveDocumentContext()$path
mother_path <- dirname(dirname(script_path))
load(paste0(mother_path, "/results/dfs.Rdata"))

all_names <- users$name

make_matrix <- function(df, levels = all_names){
  ### make an adjacency matrix out from a dataframe
  
  mail_count_table <- table(factor(df$from, levels = levels), factor(df$to, levels = levels))
  adjmatrix <- mail_count_table + t(mail_count_table)
  return(adjmatrix)
}

test_single_modularity <- function(mat){
  ### input: a matrix
  ### output: the modularity of the cluster formed by the graph of this matrix
  
  g <- graph_from_adjacency_matrix(mat, mode = "undirected", 
                                   weighted = TRUE, diag = FALSE)
  com <- cluster_fast_greedy(g)
  com$membership <- rep(1, vcount(g))
  single_modularity <- modularity(com)
  return(single_modularity)
}

get_top_three <- function(matrix = all.within.fromto.df, cluster_method = cluster_louvain){
  ### Feed in a dataframe, then get the three clusters with top three modularity scores
  
  graph <- graph_from_adjacency_matrix(make_matrix(matrix, 
                                                   levels = all_names), 
                                       mode = "undirected", weighted = TRUE, 
                                       diag = FALSE)
  
  # Filter edges with low weight (e.g., below a threshold)
  # graph <- delete_edges(graph, E(graph)[weight < 5])
  
  communities <- cluster_method(graph)
  community_membership <- membership(communities)
  
  # Initialize a list to store modularity scores for each community
  modularity_scores <- list()
  
  # Calculate modularity for each community individually
  for (i in unique(community_membership)) {
    members <- communities$names[communities$membership == i]
    df <- all.within.fromto.df[all.within.fromto.df$from %in% members, ]
    dfx <- df[df$to %in% members, ]
    adjmat <- make_matrix(dfx, levels = members)
    single_modularity <- test_single_modularity(adjmat)
    modularity_scores[i] <- single_modularity
  }
  
  # Find the community with the highest modularity score
  max_three_communities <- order(unlist(modularity_scores), decreasing = TRUE)[1:3]
  cluster <- list()
  score <- modularity_scores[max_three_communities]
  for (i in seq_along(max_three_communities)){
    cluster <- append(cluster, list(communities$names[communities$membership == max_three_communities[i]]))
  }
  ansdf <- data.frame(cluster = I(cluster), score = I(score))
  
  return(ansdf)
}
