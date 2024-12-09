This folder contains all the R scripts needed in our analysis. For those people who want to run the code in their local environment, please run `prepare_lib.R` first to install all required packages. 

## Data Cleaning and Processing

If you are going to modify the data cleaning and processing of our analysis, please follow this order so that the variables logic won't conflict:

  1. `download_enron.R`, if you need to customize your downloading of the data.
  2. `Generate_users.R`, **highly recommended leave it as it is**. The `users` dataframe has already contain all the essential information of the users.
  3. `data_loading.R`, if you need to customize the data loading pipeline.

## Cluster analysis


## Semantic Analysis

This part contains three scripts for performing semantic analysis on email data. Below is an overview of the scripts and their functions.

1. `semantic_analysis.R`
This script includes the primary methods and results of the semantic analysis. It serves as the main script for conducting the analysis.

2. `new_data_classify.R`
This script interacts with the ChatGPT API to label emails. If you want to use this functionality:
- Read through the code to understand the setup process.
- Follow the instructions in this README to ensure all necessary configurations are in place.

3. `data_classify.R`
This script processes the raw data used by `semantic_analysis.R` to prepare it for analysis.


