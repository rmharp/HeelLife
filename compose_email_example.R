#!/usr/bin/env Rscript

# Example script demonstrating the new email composer GUI
# This script shows how to use the rich text email composer
# with your existing HeelMail email functions

# Load the HeelLife package
library(HeelLife)

# Example 1: Open the email composer GUI
cat("Opening email composer GUI...\n")
cat("You can now compose your email with rich text formatting.\n")
cat("Use the toolbar to format text, then click 'Save Draft' when done.\n\n")

# Open the GUI - this will open in your default web browser
email_html <- compose_email_gui(
  initial_text = "Hello,\n\nThis is a test email with rich text formatting.\n\nBest regards,\nYour Name"
)

# Check if email was composed
if (!is.null(email_html)) {
  cat("✅ Email composed successfully!\n")
  cat("HTML content preview:\n")
  cat(substr(email_html, 1, 200), "...\n\n")
  
  # Example 2: Use the composed email with HeelMail
  cat("You can now use this email with your HeelMail functions:\n\n")
  
  # Example code (commented out since it requires credentials):
  # contacts <- get_unc_dept_contacts()
  # send_dept_emails_heelmail(
  #   contacts_df = contacts,
  #   username = "your_onyen",
  #   password = "your_password",
  #   subject = "Important Announcement",
  #   email_body = email_html
  # )
  
  cat("To send the email, uncomment the code above and provide your credentials.\n")
  
} else {
  cat("❌ Email composition was cancelled or failed.\n")
}

# Example 3: Compose email with custom title
cat("\n", paste(rep("=", 50), collapse=""), "\n")
cat("Example 3: Custom title\n")

email_html2 <- compose_email_gui(
  initial_text = "Dear Department,\n\nWe would like to invite you to our event.",
  window_title = "Event Invitation Composer"
)

if (!is.null(email_html2)) {
  cat("✅ Second email composed successfully!\n")
} else {
  cat("❌ Second email composition was cancelled.\n")
}

cat("\n", paste(rep("=", 50), collapse=""), "\n")
cat("Email composer GUI demonstration complete!\n")
cat("The GUI provides:\n")
cat("- Rich text formatting (bold, italic, underline)\n")
cat("- Font family and size selection\n")
cat("- Text alignment options\n")
cat("- Color picker\n")
cat("- Real-time HTML preview\n")
cat("- Save draft functionality\n")
cat("\nYour composed emails are returned as HTML strings\n")
cat("that can be used directly with your email functions.\n")
