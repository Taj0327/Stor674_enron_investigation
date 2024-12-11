## Introduciton

This repository contains all code and data required to reproduce our investigation on the enron mail corpus dataset. The investigation is a course project of STOR 674 Statistical and Computational Tools for Reproducible Data Science at UNC, taught by Professor Zhengwu Zhang and Dr. Jay Hineman. The main goal of this investigation is applying the tools for reproducibility in data science we learnt from the course, with a case study on the enron email corpus dataset. For this investigation, we mainly look into the social network graph of the email users and form clusters on them using various types of clustering algorithms, and analyze the clusters' stability. After that, we pick out two most stable clusters, and dig deeper into the content of the emails. Run GPT API on the text data of the emails within the clusters and do semantic analysis.

## Environment Setting

### 1. Clone this repository to your local machine

Run the following commands in your terminal:

```bash
git clone https://github.com/Taj0327/Stor674_enron_investigation.git
cd Stor674_enron_investigation

```
### 2. Build the Docker image using the `Dockerfile`

Build the Docker image by executing the following command in the project directory (where the `Dockerfile` is located):

```bash
docker build -t enron-project .
```

### 3. Run the Docker Container

After building the Docker image, start the Docker container with the following command:

```bash
docker run -d -p 8787:8787 -e PASSWORD=<your_password> --name enron_project enron-project
```

Replace `<your_password>` with the password you want to use to log in to RStudio Server.

### 4. Access RStudio Server

1. Open your web browser and navigate to:
   ```
   http://localhost:8787
   ```
2. Log in using the following credentials:
   - **Username:** `rstudio`
   - **Password:** `<your_password>` (the password you set when starting the container).

### 5. Stop the Docker Container

To stop the running container, use the following command:

```bash
docker stop enron_project
```

### 6. Restart the Docker Container

To restart the container after stopping it, run:

```bash
docker start enron_project
```

## Dataset

The dataset contains email corpus data organized into folders from 150 users, mostly senior management of Enron, an energy company. A brief introduction can be found in the `Introducing_the_Enron_Corpus.pdf`, which is under the `/data` folder of this repository. Meanwhile, the dataset, along with a thorough explanation of its origin, can be found at [here](http://www-2.cs.cmu.edu/~enron/).

Also, you can download the code with `/scripts/download_enron.R` in our repository, or directly call the script in our `/notebook/experiments.rmd`, which would automatically detect the existence of the untarred dataset and decide whether to download it.

## Instructions of Code

Our project is organized to include results, analysis, EDA, explanations, and data processing. The main tasks can be executed by directly running `/notebook/experiments.rmd`. Below is a detailed guide to understanding and using the code:

1. **Functions**  
   - Most of the functions used in this project, include data downloading, data loading and processing as well as other functions used in our analysis, can be found under the `/scripts` directory, where a more detailed README.md file is provided.

2. **html Version**  
   - For better readability, a html version of the notebook is available at `/notebook/experiments.html`. You can have a clear view of our experiments and analyses on the enron dataset. Feel free to modify it and do your own experiments!

3. **Results**  
   - The dataframe results of our pipeline are stored in an RData file at `/results/dfs.Rdata`. This file is pre-loaded by `/notebook/experiments.rmd`. Need to notice that, the dataframe `users` is produced in `/scripts/Generate_Users.R` and we highly recommend to leave it there and load it before your own experiments, unless you need to modify it for some purpose.
   - To reproduce our pipeline to get the result dataframes:
     1. Run the data loading script located at `/script/data_loading.R`.
     2. Follow the experiments outlined in `/notebook/experiments.rmd` or design your own experiments.

### API Setting

To verify whether the labels are assigned fairly in the dataset, we provide the script `Classify_email.R`. To use this script, you will need an API key and API URL. Below are instructions to obtain them:

#### Free GPT API
You can access a free GPT API through third-party platforms. For example, the [ChatAnywhere GitHub repository](https://github.com/chatanywhere/GPT_API_free) provides guidance on obtaining a free API key and API URL.

#### Official ChatGPT API
For the official OpenAI ChatGPT API, visit the [OpenAI API settings page](https://platform.openai.com/signup) to set up your API key and endpoint.



