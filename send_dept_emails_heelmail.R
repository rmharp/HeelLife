#!/usr/bin/env Rscript

# HeelLife Package - Department Email Sender via HeelMail
# This script sends emails to UNC Directors of Undergraduate Studies and
# Student Services Managers using the UNC HeelMail web interface.

# Load required libraries
library(HeelLife)
library(readr)

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

# Ask for test email
cat("🧪 Testing\n")
cat("==========\n")
test_email <- readline("Enter a test email address (or press Enter to skip testing): ")

if (test_email != "") {
  cat("\n📧 Sending test email to:", test_email, "\n")
  
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
  }, error = function(e) {
    cat("❌ Error sending test email:", e$message, "\n")
    cat("Please check your UNC credentials and internet connection.\n")
    quit(status = 1)
  })
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
