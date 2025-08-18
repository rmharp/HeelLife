#!/usr/bin/env Rscript

# HeelLife Package Runner Script
# This script can be executed from the terminal to run the HeelLife package

# Load required libraries
library(HeelLife)
library(dotenv)

# Load environment variables from .env file (if it exists)
if (file.exists(".env")) {
  load_dot_env()
  cat("Loaded credentials from .env file\n")
} else {
  cat("No .env file found. You'll need to enter credentials manually.\n")
}

# Get credentials from environment or prompt user
username <- Sys.getenv("ONYEN_USERNAME")
password <- Sys.getenv("ONYEN_PASSWORD")

if (nzchar(username) && nzchar(password)) {
  cat("Using credentials from environment variables\n")
} else {
  cat("Please enter your UNC credentials:\n")
  username <- readline("ONYEN username: ")
  password <- readline("Password: ")
}

# Validate credentials
if (nzchar(username) && nzchar(password)) {
  cat("Starting HeelLife scraping process...\n")
  cat("This will open a Firefox browser and require MFA input.\n")
  cat("Output will be saved to 'heellife_contacts.csv'\n\n")
  
  # Run the scraping function
  tryCatch({
    contacts_data <- get_unc_contacts(
      username = username,
      password = password,
      output_file = "heellife_contacts.csv"
    )
    
    cat("\n✅ Scraping completed successfully!\n")
    cat("📊 Total contacts scraped:", nrow(contacts_data), "\n")
    cat("📁 Data saved to: heellife_contacts.csv\n")
    
    # Show sample of the data
    cat("\n📋 Sample of scraped data:\n")
    print(head(contacts_data, 5))
    
  }, error = function(e) {
    cat("❌ Error during scraping:", e$message, "\n")
    cat("Please check your credentials and internet connection.\n")
  })
  
} else {
  cat("❌ Invalid credentials provided. Exiting.\n")
}
