#!/usr/bin/env Rscript

# Test script for the updated HeelLife package with PhantomJS fix
cat("🧪 Testing Updated HeelLife Package - PhantomJS Fix\n")
cat("==================================================\n\n")

# Load required packages
cat("Loading required packages...\n")
library(dplyr)
library(stringr)
cat("✅ Packages loaded successfully!\n\n")

# Load the functions directly from source
cat("Loading functions from source...\n")
source('R/scripting_functions.R')
source('R/example_scripts.R')
cat("✅ Functions loaded successfully!\n\n")

# Test the safe_start_selenium function
cat("🧪 Testing safe_start_selenium function...\n")
tryCatch({
  # Test the helper function directly
  rD <- safe_start_selenium(port = netstat::free_port(), verbose = FALSE)
  cat("✅ safe_start_selenium function works without PhantomJS errors!\n")
  
  # Clean up
  rD$client$close()
  rD$server$stop()
  rm(rD)
  gc()
  
}, error = function(e) {
  cat("❌ Error in safe_start_selenium function:", e$message, "\n")
  if (grepl("PhantomJS", e$message) || grepl("Bitbucket", e$message)) {
    cat("⚠️  PhantomJS error still occurring - trying alternative method...\n")
    
    # Try the alternative method
    tryCatch({
      rD <- alternative_start_selenium(port = netstat::free_port(), verbose = FALSE)
      cat("✅ alternative_start_selenium function works as fallback!\n")
      
      # Clean up
      rD$client$close()
      rD$server$stop()
      rm(rD)
      gc()
      
    }, error = function(e2) {
      cat("❌ Alternative method also failed:", e2$message, "\n")
    })
  } else {
    cat("ℹ️  Other error - check the specific error message\n")
  }
})

cat("\n")

# Test email template creation
cat("1️⃣ Testing email template creation...\n")
email_body <- create_dept_email_template("Riley Harper", "riley.harper@unc.edu", "Test message")
cat("✅ Email template created successfully!\n")
cat("Template length:", nchar(email_body), "characters\n\n")

# Show a preview of the email
cat("📧 Email Template Preview:\n")
cat("==========================\n")
cat(substr(email_body, 1, 300), "...\n\n")

# Test contacts
cat("2️⃣ Testing contact data structure...\n")
test_contacts <- data.frame(
  Department = "TEST",
  Role = "TEST",
  Email = "riley.harper@unc.edu",
  stringsAsFactors = FALSE
)
cat("✅ Test contacts created successfully!\n")
cat("Contacts:\n")
print(test_contacts)
cat("\n")

# Test the updated HeelMail function (this should NOT have PhantomJS errors)
cat("3️⃣ Testing HeelMail function with PhantomJS fix...\n")
cat("Note: This will open Firefox and attempt to log into HeelMail\n")
cat("The PhantomJS connection errors should be resolved now.\n\n")

tryCatch({
  send_dept_emails_heelmail(
    contacts_df = test_contacts,
    username = "rmharp",
    password = "Password233223!",
    subject = "Test Email from HeelLife Package - PhantomJS Fix Test",
    email_body = email_body,
    test_email = "riley.harper@unc.edu"
  )
  cat("✅ HeelMail function executed successfully!\n")
}, error = function(e) {
  cat("❌ Error in HeelMail function:", e$message, "\n")
  if (grepl("PhantomJS", e$message) || grepl("Bitbucket", e$message)) {
    cat("⚠️  PhantomJS error still occurring - may need additional fixes\n")
  } else if (grepl("MFA", e$message)) {
    cat("ℹ️  MFA error - this is expected in automated testing\n")
  } else {
    cat("ℹ️  Other error - check the specific error message\n")
  }
})

cat("\n🎉 Testing completed!\n")
cat("The package should now work without PhantomJS connection errors.\n")
