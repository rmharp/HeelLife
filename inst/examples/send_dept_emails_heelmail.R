#!/usr/bin/env Rscript

# HeelLife Package - Department Email Sender via HeelMail
# This script sends emails to UNC Directors of Undergraduate Studies and
# Student Services Managers using the UNC HeelMail web interface.

# Load required libraries
library(HeelLife)
library(readr)
library(dplyr)

cat("📧 UNC Department Email Sender via HeelMail\n")
cat("===========================================\n\n")

# Check if contacts file exists
contacts_file <- "dept_contacts.csv"
if (!file.exists(contacts_file)) {
  cat("❌ Contacts file not found:", contacts_file, "\n")
  cat("Please run 'run_dept_contacts.R' first to scrape department contacts.\n")
  quit(status = 1)
}

# Read the contacts
cat("📖 Reading department contacts from:", contacts_file, "\n")
dept_contacts <- read_csv(contacts_file, show_col_types = FALSE)
cat("📊 Found", nrow(dept_contacts), "contacts\n\n")

# Group by department (combine multiple emails per department)
dept_grouped <- dept_contacts %>%
  group_by(Department) %>% 
  summarise(Email = paste(Email, collapse = ", "))

cat("📋 Departments to email:", nrow(dept_grouped), "\n\n")

# Get user input for email configuration
cat("📝 Email Configuration\n")
cat("=====================\n\n")

cat("Enter your UNC credentials:\n")
username <- readline("UNC ONYEN username: ")
password <- readline("UNC password: ")

cat("\nEnter email details:\n")
subject <- readline("Email subject: ")

cat("\n📝 Email Content Options\n")
cat("=======================\n")
cat("Choose how you want to compose your email:\n")
cat("1. Use the GUI email composer (recommended)\n")
cat("2. Type message in console\n")
cat("3. Use default template\n\n")

email_option <- readline("Enter your choice (1-3): ")

if (email_option == "1") {
  # Use GUI composer
  cat("\n🎨 Opening GUI email composer...\n")
  cat("A web browser will open with the email composer.\n")
  cat("Compose your email with rich text formatting, then click 'Save Draft'.\n\n")
  
  email_html <- compose_email_gui(
    initial_text = paste0("Dear Department,\n\n"),
    window_title = "HeelMail Email Composer"
  )
  
  if (!is.null(email_html)) {
    email_body <- email_html
    cat("✅ Email composed successfully using GUI!\n\n")
  } else {
    cat("❌ Email composition was cancelled. Using default template.\n\n")
    email_body <- create_dept_email_template(
      from_name = username,
      reply_to_email = paste0(username, "@unc.edu"),
      custom_message = "I'm reaching out to you regarding an important matter.",
      signature_title = "",
      organization_name = ""
    )
  }
  
} else if (email_option == "2") {
  # Type message in console
  cat("\n📝 Email Content\n")
  cat("================\n")
  cat("Enter your custom message (press Enter twice when done):\n")
  custom_message <- ""
  while (TRUE) {
    line <- readline()
    if (line == "") {
      if (custom_message == "") {
        custom_message <- readline("Please enter at least one line of message: ")
      } else {
        break
      }
    } else {
      custom_message <- paste0(custom_message, if (custom_message != "") "\n" else "", line)
    }
  }

  # Get additional signature information
  cat("\n📋 Signature Information\n")
  cat("========================\n")
  signature_title <- readline("Your title/position (optional): ")
  organization_name <- readline("Your organization (optional): ")

  # Create the email template
  cat("\n🔧 Creating email template...\n")
  email_body <- create_dept_email_template(
    from_name = username,
    reply_to_email = paste0(username, "@unc.edu"),
    custom_message = custom_message,
    signature_title = signature_title,
    organization_name = organization_name
  )
  
} else {
  # Use default template
  cat("\n📝 Using default email template...\n")
  email_body <- create_dept_email_template(
    from_name = username,
    reply_to_email = paste0(username, "@unc.edu"),
    custom_message = "I'm reaching out to you regarding an important matter.",
    signature_title = "",
    organization_name = ""
  )
}

cat("✅ Email template created successfully!\n\n")

# Additional HeelMail options
cat("🔧 HeelMail Options\n")
cat("==================\n")
high_importance <- readline("Mark emails as high importance? (y/N): ")
high_importance <- tolower(high_importance) == "y"

cc_emails_input <- readline("CC email addresses (comma-separated, or press Enter for none): ")
cc_emails <- if (cc_emails_input != "") {
  strsplit(cc_emails_input, ",")[[1]] %>% trimws()
} else {
  NULL
}

# Preview the email
cat("\n📋 Email Preview\n")
cat("================\n")
cat("From:", username, "@unc.edu\n")
cat("To: [Department Contacts]\n")
if (!is.null(cc_emails)) {
  cat("CC:", paste(cc_emails, collapse = ", "), "\n")
}
cat("Subject:", subject, "\n")
cat("High Importance:", if (high_importance) "Yes" else "No", "\n")
cat("Body preview (first 200 chars):", substr(email_body, 1, 200), "...\n\n")

# 🧪 TESTING SECTION - SEND TO YOURSELF FIRST
cat("\n🧪 TESTING SECTION - SEND TO YOURSELF FIRST\n")
cat("============================================\n")
cat("⚠️  IMPORTANT: Always test with yourself before sending to all departments!\n")
cat("This helps you:\n")
cat("• Verify the email looks correct\n")
cat("• Check formatting and content\n")
cat("• Ensure HeelMail is working properly\n")
cat("• Avoid sending mistakes to all departments\n\n")

test_email <- readline("Enter YOUR email address for testing (e.g., your_onyen@unc.edu): ")

if (test_email != "") {
  cat("\n📧 Sending test email to:", test_email, "\n")
  cat("This will send ONLY to you - no other emails will be sent yet.\n\n")
  
  # Confirm test email
  cat("Confirm test email details:\n")
  cat("From:", username, "@unc.edu\n")
  cat("To:", test_email, "\n")
  cat("Subject:", subject, "\n")
  cat("High Importance:", if (high_importance) "Yes" else "No", "\n")
  if (!is.null(cc_emails)) {
    cat("CC:", paste(cc_emails, collapse = ", "), "\n")
  }
  cat("\nProceed with test email? (y/N): ")
  
  test_confirm <- readline()
  if (tolower(test_confirm) == "y") {
    cat("\n📧 Sending test email...\n")
    
    tryCatch({
      send_dept_emails_heelmail(
        contacts_df = dept_contacts,
        username = username,
        password = password,
        subject = subject,
        email_body = email_body,
        test_email = test_email,
        cc_emails = cc_emails,
        high_importance = high_importance
      )
      cat("✅ Test email sent successfully!\n\n")
      
      # Ask if user wants to review before proceeding
      cat("📋 Test Email Review\n")
      cat("====================\n")
      cat("Please check your email to ensure:\n")
      cat("• Content looks correct\n")
      cat("• Formatting is as expected\n")
      cat("• Subject line is appropriate\n")
      cat("• No typos or errors\n\n")
      
      review_ok <- readline("Does the test email look good? Ready to proceed? (y/N): ")
      if (tolower(review_ok) != "y") {
        cat("❌ Test email review failed. Please fix any issues and run the script again.\n")
        quit(status = 0)
      }
      
    }, error = function(e) {
      cat("❌ Error sending test email:", e$message, "\n")
      cat("Please check your UNC credentials and internet connection.\n")
      cat("Common issues:\n")
      cat("• Firefox browser not installed\n")
      cat("• UNC credentials incorrect\n")
      cat("• MFA code not entered\n")
      cat("• Network connectivity issues\n\n")
      quit(status = 1)
    })
  } else {
    cat("❌ Test email cancelled. Please run the script again.\n")
    quit(status = 0)
  }
} else {
  cat("⚠️  WARNING: No test email provided!\n")
  cat("It's highly recommended to test first. Continue anyway? (y/N): ")
  continue_anyway <- readline()
  if (tolower(continue_anyway) != "y") {
    cat("❌ Script cancelled. Please run again with a test email.\n")
    quit(status = 0)
  }
  cat("⚠️  Proceeding without testing - this is not recommended!\n\n")
}

# Confirm before sending to all departments
cat("⚠️  Ready to send emails to all departments via HeelMail\n")
cat("========================================================\n")
cat("This will send emails to", nrow(dept_grouped), "departments.\n")
cat("Are you sure you want to proceed? (y/N): ")

confirm <- readline()
if (tolower(confirm) != "y") {
  cat("❌ Email sending cancelled.\n")
  quit(status = 0)
}

# Ask for start index (useful for resuming)
cat("\n📍 Starting Position\n")
cat("====================\n")
cat("Enter starting department index (1-", nrow(dept_grouped), ") or press Enter for 1: ")
start_input <- readline()
start_index <- if (start_input == "") 1 else as.numeric(start_input)

if (is.na(start_index) || start_index < 1 || start_index > nrow(dept_grouped)) {
  cat("❌ Invalid start index. Using 1.\n")
  start_index <- 1
}

cat("\n📧 Sending emails to departments via HeelMail...\n")
cat("Starting from index:", start_index, "\n")
cat("Total departments:", nrow(dept_grouped), "\n")
cat("High Importance:", if (high_importance) "Yes" else "No", "\n")
if (!is.null(cc_emails)) {
  cat("CC:", paste(cc_emails, collapse = ", "), "\n")
}
cat("\n")

# Important notes about HeelMail
cat("📋 Important Notes:\n")
cat("• Firefox browser will open automatically\n")
cat("• You'll need to enter MFA code when prompted\n")
cat("• Keep the browser window open during sending\n")
cat("• Process may take several minutes\n\n")

# Send emails to all departments
tryCatch({
  send_dept_emails_heelmail(
    contacts_df = dept_contacts,
    username = username,
    password = password,
    subject = subject,
    email_body = email_body,
    start_index = start_index,
    cc_emails = cc_emails,
    high_importance = high_importance
  )
  
  cat("\n✅ All emails sent successfully via HeelMail!\n")
  cat("📊 Emails sent to", nrow(dept_grouped), "departments\n")
  
}, error = function(e) {
  cat("\n❌ Error during email sending:", e$message, "\n")
  cat("You may need to check your UNC credentials or try again later.\n")
})

cat("\nScript completed.\n")
