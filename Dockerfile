# Use the rocker/tidyverse image as the base image
FROM rocker/tidyverse:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=C.UTF-8

# Install additional system dependencies for R packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install R packages required for the project
RUN R -e "install.packages(c('rstudioapi', 'dplyr', 'jsonlite', 'httr', 'stringr', 'purrr', 'ggplot2', 'igraph', 'reshape2'))"

# Set the working directory inside the container
WORKDIR /home/project

# Copy the entire project folder into the container
COPY . /home/project

# Set permissions for the project folder
RUN chmod -R 755 /home/project

# Expose port 8787 for RStudio Server (optional, if needed)
EXPOSE 8787

# Default command: Start a bash shell for interactive use
CMD ["bash"]
