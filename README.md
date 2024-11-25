## Introduciton

This repository contains all code and data required to reproduce our investigation on the enron mail corpus dataset. The investigation is a course project of STOR 674 Statistical and Computational Tools for Reproducible Data Science at UNC, taught by Professor Zhengwu Zhang and Dr. Jay Hineman. The main goal of this investigation is applying the tools for reproducibility in data science we learnt from the course, with a case study on the enron email corpus dataset. For this investigation, we mainly look into the social network graph of the email users and form clusters on them using various types of clustering algorithms, and analyze the clusters' stability. After that, we pick out two most stable clusters, and dig deeper into the content of the emails. Run GPT API on the text data of the emails within the clusters and do semantic analysis.

## Environment Setting

### Pull the Image from Docker Hub
To use the pre-built Docker image for this project, run:
```bash
docker pull chengze123/enron-project:latest
```


## Dataset

The dataset contains email corpus data from 150 users, mostly senior management of Enron, organized into folders. A brief introduction can be found in the `Introducing_the_Enron_Corpus.pdf`, which is under the `\data` folder of this repository. Meanwhile, the dataset, along with a thorough explanation of its origin, can be found at <http://www-2.cs.cmu.edu/~enron/>.

Also, you can download the code with `/scripts/download_enron.R` in our repository, or directly call the script in our `/notebook/investigation.rmd`, which would automatically detect the existence of the dataset and decide whether to download it.

## Instruction of Code

Our project is organized to include results, analysis, EDA, explanations, and data processing. The main tasks can be executed by directly running `/notebook/investigation.rmd`. Below is a detailed guide to understanding and using the code:

1. **Functions**  
   - Most of the functions used in this project are located in the `/script` directory.

2. **PDF Version**  
   - For better readability, a PDF version of the notebook is available at `/notebook/investigation.pdf`.

3. **Results**  
   - The results are stored as an RData file at `/results/dfs.Rdata`. This file is pre-loaded by `/notebook/investigation.rmd`.
   - To reproduce our results:
     1. Comment out the line in `/notebook/investigation.rmd` that loads this dataset.
     2. Run the data loading script located at `/script/data_loading`.
     3. Follow the experiments outlined in `/notebook/investigation.rmd` or design your own experiments.


### API Setting

To verify whether the labels are assigned fairly in the dataset, we provide the script `Classify_email.R`. To use this script, you will need an API key and API URL. Below are instructions to obtain them:

#### Free GPT API
You can access a free GPT API through third-party platforms. For example, the [ChatAnywhere GitHub repository](https://github.com/chatanywhere/GPT_API_free) provides guidance on obtaining a free API key and API URL.

#### Official ChatGPT API
For the official OpenAI ChatGPT API, visit the [OpenAI API settings page](https://platform.openai.com/signup) to set up your API key and endpoint.



