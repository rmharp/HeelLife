#!/usr/bin/env Rscript

# Test script to verify the GUI email composer option works
# This simulates the email composition part of the HeelMail script

library(HeelLife)

cat("Testing GUI email composer option...\n\n")

cat("📝 Email Content Options\n")
cat("=======================\n")
cat("Choose how you want to compose your email:\n")
cat("1. Use the GUI email composer (recommended)\n")
cat("2. Type message in console\n")
cat("3. Use default template\n\n")

# Simulate user choosing option 1
email_option <- "1"
cat("User selected option:", email_option, "\n\n")

if (email_option == "1") {
  # Use GUI composer
  cat("🎨 Opening GUI email composer...\n")
  cat("A web browser will open with the email composer.\n")
  cat("Compose your email with rich text formatting, then click 'Save Draft'.\n\n")
  
  email_html <- compose_email_gui(
    initial_text = paste0("Dear Department,\n\n"),
    window_title = "HeelMail Email Composer Test"
  )
  
  if (!is.null(email_html)) {
    email_body <- email_html
    cat("✅ Email composed successfully using GUI!\n")
    cat("HTML content preview:\n")
    cat(substr(email_body, 1, 200), "...\n\n")
  } else {
    cat("❌ Email composition was cancelled. Using default template.\n\n")
    email_body <- create_dept_email_template(
      from_name = "test_user",
      reply_to_email = "test@unc.edu",
      custom_message = "I'm reaching out to you regarding an important matter.",
      signature_title = "",
      organization_name = ""
    )
  }
  
} else if (email_option == "2") {
  cat("Option 2 selected - console input\n")
} else {
  cat("Option 3 selected - default template\n")
}

cat("✅ Test completed successfully!\n")

