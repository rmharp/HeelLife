#!/usr/bin/env Rscript

# HeelLife Package - Department Email Sender
# This script sends emails to UNC Directors of Undergraduate Studies and
# Student Services Managers using the scraped contact information.

# Load required libraries
library(HeelLife)
library(readr)

cat("📧 UNC Department Email Sender\n")
cat("=====================================\n\n")

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

cat("Enter your email details:\n")
from_email <- readline("From email address: ")
from_name <- readline("Your name: ")
reply_to_email <- readline("Reply-to email address: ")
subject <- readline("Email subject: ")

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
  from_name = from_name,
  reply_to_email = reply_to_email,
  custom_message = custom_message,
  signature_title = signature_title,
  organization_name = organization_name
)

cat("✅ Email template created successfully!\n\n")

# Preview the email
cat("📋 Email Preview\n")
cat("================\n")
cat("From:", from_email, "\n")
cat("To: [Department Contacts]\n")
cat("Subject:", subject, "\n")
cat("Body preview (first 200 chars):", substr(email_body, 1, 200), "...\n\n")

# Ask for test email
cat("🧪 Testing\n")
cat("==========\n")
test_email <- readline("Enter a test email address (or press Enter to skip testing): ")

if (test_email != "") {
  cat("\n📧 Sending test email to:", test_email, "\n")
  
  tryCatch({
    send_dept_emails(
      contacts_df = dept_contacts,
      from_email = from_email,
      from_name = from_name,
      reply_to_email = reply_to_email,
      subject = subject,
      email_body = email_body,
      test_email = test_email
    )
    cat("✅ Test email sent successfully!\n\n")
  }, error = function(e) {
    cat("❌ Error sending test email:", e$message, "\n")
    cat("Please check your Gmail API configuration.\n")
    quit(status = 1)
  })
}

# Confirm before sending to all departments
cat("⚠️  Ready to send emails to all departments\n")
cat("============================================\n")
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

cat("\n📧 Sending emails to departments...\n")
cat("Starting from index:", start_index, "\n")
cat("Total departments:", nrow(dept_grouped), "\n\n")

# Send emails to all departments
tryCatch({
  send_dept_emails(
    contacts_df = dept_contacts,
    from_email = from_email,
    from_name = from_name,
    reply_to_email = reply_to_email,
    subject = subject,
    email_body = email_body,
    start_index = start_index
  )
  
  cat("\n✅ All emails sent successfully!\n")
  cat("📊 Emails sent to", nrow(dept_grouped), "departments\n")
  
}, error = function(e) {
  cat("\n❌ Error during email sending:", e$message, "\n")
  cat("You may need to check your Gmail API configuration or try again later.\n")
})

cat("\nScript completed.\n")
