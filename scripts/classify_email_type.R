library(jsonlite)
library(httr)
classify_email_type <- function(email_content, 
                                api_url = "https://api.openai.com/v1/chat/completions", 
                                api_key = "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", 
                                model = "gpt-4o-mini") {
  # Check for empty email content
  
  if (nchar(email_content) == 0) {
    stop("Email content is empty.")
  }
  
  # Prepare the request data
  request_data <- list(
    model = model,
    messages = list(
      list(role = "system", content = paste(
        "You are an assistant that classifies emails. Respond with a single word only. Choose one from the following categories: Social, Spam, Personal, Promotional, Notification, Business."
      )),
      list(role = "user", content = paste("Classify the following email:", email_content))
    ),
    max_tokens = 10,
    temperature = 0.0
  )
  
  # Send the POST request
  response <- POST(
    url = api_url,
    add_headers(
      Authorization = paste("Bearer", api_key),
      `Content-Type` = "application/json"
    ),
    body = toJSON(request_data, auto_unbox = TRUE)
  )
  
  # Check response status
  if (status_code(response) != 200) {
    stop("Request failed with status code: ", status_code(response), 
         "\nResponse content: ", content(response, as = "text", encoding = "UTF-8"))
  }
  
  # Parse the response content
  response_content <- content(response, as = "text", encoding = "UTF-8")
  parsed_response <- fromJSON(response_content, simplifyVector = FALSE)
  
  # Validate the response structure
  if (is.null(parsed_response$choices) || length(parsed_response$choices) == 0) {
    stop("Unexpected API response format: ", response_content)
  }
  
  # Extract the email label
  email_label <- parsed_response$choices[[1]]$message$content
  email_label <- trimws(email_label)
  
  # Fallback logic if the response is not a single word
  if (!grepl("^[a-zA-Z]+$", email_label)) {
    email_label <- detect_category(email_content)  # Fallback to detect_category
  }
  
  return(map_category_to_code(email_label))
}

classify_email_type_2 <- function(email_content, 
                                api_url = "https://api.openai.com/v1/chat/completions", 
                                api_key = "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", 
                                model = "gpt-4o-mini") {
  # Check for empty email content
  if (nchar(email_content) == 0) {
    stop("Email content is empty.")
  }
  
  # Prepare the request data
  request_data <- list(
    model = model,
    messages = list(
      list(role = "system", content = paste(
        "You are an assistant that classifies emails based on sentiment. Respond with a single word only. Choose one from the following categories: Neutral, Negative, Positive, Imperative. Do not include any explanations or additional text, just the category name so just one word"
      )),
      list(role = "user", content = paste("Classify the following email:", email_content))
    ),
    max_tokens = 10,
    temperature = 0.0
  )
  
  # Send the POST request
  response <- POST(
    url = api_url,
    add_headers(
      Authorization = paste("Bearer", api_key),
      `Content-Type` = "application/json"
    ),
    body = toJSON(request_data, auto_unbox = TRUE)
  )
  
  # Check response status
  if (status_code(response) != 200) {
    stop("Request failed with status code: ", status_code(response), 
         "\nResponse content: ", content(response, as = "text", encoding = "UTF-8"))
  }
  
  # Parse the response content
  response_content <- content(response, as = "text", encoding = "UTF-8")
  parsed_response <- fromJSON(response_content, simplifyVector = FALSE)
  
  # Validate the response structure
  if (is.null(parsed_response$choices) || length(parsed_response$choices) == 0) {
    stop("Unexpected API response format: ", response_content)
  }
  
  # Extract the email label
  email_label <- parsed_response$choices[[1]]$message$content
  email_label <- trimws(email_label)
  
  # Fallback logic if the response is not a single word
  if (!grepl("^[a-zA-Z]+$", email_label)) {
    email_label <- detect_category_2(email_content)  # Fallback to detect_category
  }
  
  return(map_category_to_code_2(email_label))
}




detect_category <- function(input_string) {
  # Define the target categories
  categories <- c("Neutral", "Negative", "Positive", "Imperative")
  
  # Check if any category is present in the input string
  matched_category <- categories[sapply(categories, function(cat) grepl(cat, input_string, ignore.case = TRUE))]
  
  # Return the first matching category or NA if no match is found
  if (length(matched_category) > 0) {
    return(map_category_to_code(matched_category[1]))
  } else {
    return(NA)  # Return NA if no category is found
  }
}

detect_category_2 <- function(input_string) {
  # Define the target categories
  categories <- c("Social", "Spam", "Personal", "Promotional", "Notification", "Business")
  
  # Check if any category is present in the input string
  matched_category <- categories[sapply(categories, function(cat) grepl(cat, input_string, ignore.case = TRUE))]
  
  # Return the first matching category or NA if no match is found
  if (length(matched_category) > 0) {
    return(map_category_to_code_2(matched_category[1]))
  } else {
    return(NA)  # Return NA if no category is found
  }
}



extract_clean_email_content <- function(email_file) {
  # Read the email content
  email_lines <- readLines(email_file, warn = FALSE)
  
  # Find the first blank line to separate headers from the body
  blank_line_index <- which(email_lines == "")[1]
  
  # Extract the email body (everything after the first blank line)
  if (!is.na(blank_line_index) && blank_line_index < length(email_lines)) {
    email_body <- email_lines[(blank_line_index + 1):length(email_lines)]
  } else {
    email_body <- email_lines
  }
  
  # Remove lines containing metadata or non-content information
  email_body <- email_body[!grepl(
    "^(\\s*[-]+ Forwarded by|From:|To:|Subject:|Sent:|Mime-Version:|Content-Type:|Content-Transfer-Encoding:|X-|cc:|bcc:|Message-ID:|Date:|Folder:|Origin:|FileName:|\\/+)$",
    email_body
  )]
  
  # Combine the remaining lines into a single block of text
  email_body_text <- paste(email_body, collapse = " ")
  
  # Clean up the content
  email_body_text <- gsub("[/]+", "", email_body_text)       # Remove excessive /
  email_body_text <- gsub("[ \t\r]+", " ", email_body_text)  # Replace tabs and extra spaces with single space
  email_body_text <- gsub("\n+", " ", email_body_text)       # Remove all newlines
  email_body_text <- trimws(email_body_text)                # Trim leading and trailing whitespace
  email_body_text <- gsub("\n", " ", email_body_text)
  return(email_body_text)
}
find_label <- function(file_path,mode){
   temp = extract_clean_email_content(file_path)
      if(mode == 1){
        return(classify_email_type(temp))
      }else{
        return(classify_email_type_2(temp))
      }    
}

map_category_to_code <- function(category) {
  category_mapping <- c(
    Social = 1,
    Spam = 2,
    Personal = 3,
    Promotional = 4,
    Notification = 5,
    Business = 6
  )
  return(category_mapping[category])
}

map_category_to_code_2 <- function(category) {
  category_mapping <- c(
    Neutral = 0, 
    Negative = 1, 
    Positive = 2, 
    Imperative = 3
  )
  return(category_mapping[category])
}


