# List of libraries to check
libraries <- c(
  "rstudioapi", "stringr", "dplyr", "purrr", 
  "ggplot2", "igraph", "reshape2", "tidyr"
)

# Function to check and install missing libraries
check_and_install <- function(pkg_list) {
  for (pkg in pkg_list) {
    if (!require(pkg, character.only = TRUE)) {
      cat(paste("Installing missing library:", pkg, "\n"))
      install.packages(pkg, dependencies = TRUE)
    } else {
      cat(paste("Library", pkg, "is already installed.\n"))
    }
  }
}

# Run the function
check_and_install(libraries)

# Load all libraries
lapply(libraries, library, character.only = TRUE)
