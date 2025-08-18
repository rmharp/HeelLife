#!/usr/bin/env Rscript

# Simple HeelLife Test Script
# Installs package, creates email, sends via HeelMail

cat("🚀 Simple HeelLife Test\n")
cat("======================\n\n")

# Install HeelLife from GitHub
cat("Installing HeelLife package...\n")
devtools::install_github("rmharp/HeelLife", dependencies = TRUE, force = TRUE)
cat("✅ Package installed!\n\n")

# Load the package
cat("Loading package...\n")
library(HeelLife)
cat("✅ Package loaded!\n\n")

# Get email details
cat("Enter email details:\n")
from_email <- readline("FROM email: ")
to_email <- readline("TO email: ")
subject <- readline("Subject: ")
message <- readline("Message: ")

# Create test contacts
test_contacts <- data.frame(
  Department = "TEST",
  Role = "TEST", 
  Email = to_email,
  stringsAsFactors = FALSE
)

# Create email template
email_body <- create_dept_email_template(
  from_name = from_email,
  reply_to_email = from_email,
  custom_message = message
)

# Get UNC credentials
cat("\nEnter UNC credentials:\n")
username <- readline("Username: ")
password <- readline("Password: ")

# Send email via HeelMail
cat("\nSending email...\n")
send_dept_emails_heelmail(
  contacts_df = test_contacts,
  username = username,
  password = password,
  subject = subject,
  email_body = email_body,
  test_email = to_email
)

cat("✅ Email sent to", to_email, "!\n")
