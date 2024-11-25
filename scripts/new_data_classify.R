library(jsonlite)
library(httr)
classify_email_details <- function(email_file, sender, receiver,
                                   api_url = "https://api.openai.com/v1/chat/completions", 
                                   api_key = "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",
                                   model = "gpt-4o-mini") {
  # Load API key from environment variable for security
  email_content = email_lines <- readLines(email_file, warn = FALSE)
  if (is.null(api_key) || api_key == "") {
    stop("API key not found. Please set OPENAI_API_KEY as an environment variable.")
  }
  
  # Check for empty email content
  if (nchar(email_content) == 0 || nchar(sender) == 0 || nchar(receiver) == 0) {
    stop("Email content, sender, and receiver must not be empty.")
  }
  
  # Prepare the request data
  request_data <- list(
    model = model,
    messages = list(
      list(role = "system", content = paste(
        "You are an assistant that determines the departments of two given people and the tone of their communication.",
        "The sender and receiver's departments should be one of the following:",
        "Trading, Operations, Engineering, Finance, Technology, Human, Legal",
        "The email's tone should be classified as one of the following:",
        "Imperative, Deferential, Informative, Supportive.",
        "Respond in the form of a list/array with three entries: [sender_department, receiver_department, tone].",
        "Each entry should be a single word. Do not include any explanations or additional text."
      )),
      list(role = "user", content = paste(
        "Given the sender:", sender, 
        "and receiver:", receiver,
        "please classify the email content:", email_content
      ))
    ),
    max_tokens = 20,  # Short response since output is just three words
    temperature = 0.0  # Deterministic output
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
  
  # Extract the email details (array with three single-word entries)
  email_details <- parsed_response$choices[[1]]$message$content
  email_details <- trimws(email_details)  # Remove extra spaces
  
  # Check format (should be a list/array with three words)
  if (!grepl("^\\[\\w+,\\w+,\\w+\\]$", email_details)) {
    stop("Unexpected response format. Expected a list/array with three single-word entries.")
  }
  
  # Parse the response into a proper R list
  email_details <- gsub("[\\[\\]]", "", email_details)  # Remove brackets
  email_details <- strsplit(email_details, ",")[[1]]   # Split into words
  
  return(email_details)  # Return the list: [sender_department, receiver_department, tone]
}

