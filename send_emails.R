#!/usr/bin/env Rscript

# Email Sender Script for HeelLife Contacts
# This script reads the scraped contacts and sends emails

# Load required libraries
library(readr)
library(dplyr)

# Function to send emails (you'll need to customize this)
send_email <- function(to_email, to_name, organization, position, message_template) {
  # This is a template - you'll need to implement actual email sending
  # Options include: mailR, emayili, or system mail commands
  
  cat("📧 Would send email to:", to_email, "\n")
  cat("   Name:", to_name, "\n")
  cat("   Organization:", organization, "\n")
  cat("   Position:", position, "\n")
  cat("   Message:", substr(message_template, 1, 50), "...\n\n")
  
  # Example using system mail (uncomment if you have mail configured)
  # system(paste("echo '", message_template, "' | mail -s 'Your Subject' ", to_email))
  
  # Example using mailR package (uncomment and configure)
  # library(mailR)
  # send.mail(
  #   from = "your_email@unc.edu",
  #   to = to_email,
  #   subject = "Your Subject",
  #   body = message_template,
  #   smtp = list(host.name = "smtp.unc.edu", port = 587, user.name = "your_onyen", passwd = "your_password", ssl = TRUE),
  #   authenticate = TRUE,
  #   send = TRUE
  # )
}

# Main email sending function
send_emails_to_contacts <- function(csv_file = "heellife_contacts.csv", 
                                   message_template = NULL,
                                   dry_run = TRUE) {
  
  # Check if CSV file exists
  if (!file.exists(csv_file)) {
    cat("❌ CSV file not found:", csv_file, "\n")
    cat("Please run the HeelLife scraper first.\n")
    return()
  }
  
  # Read the contacts
  cat("📖 Reading contacts from:", csv_file, "\n")
  contacts <- read_csv(csv_file, show_col_types = FALSE)
  
  cat("📊 Found", nrow(contacts), "contacts\n\n")
  
  # Set default message template if none provided
  if (is.null(message_template)) {
    message_template <- "Dear [NAME],

I hope this email finds you well. I'm reaching out regarding your role as [POSITION] at [ORGANIZATION].

[YOUR MESSAGE HERE]

Best regards,
[YOUR NAME]"
  }
  
  # Show what we're about to do
  if (dry_run) {
    cat("🔍 DRY RUN MODE - No emails will actually be sent\n")
    cat("📝 Message template:\n")
    cat(message_template, "\n\n")
  } else {
    cat("⚠️  LIVE MODE - Emails will actually be sent!\n")
    cat("📝 Message template:\n")
    cat(message_template, "\n\n")
  }
  
  # Process each contact
  for (i in 1:nrow(contacts)) {
    contact <- contacts[i, ]
    
    # Personalize the message
    personalized_message <- message_template
    personalized_message <- gsub("\\[NAME\\]", contact$Name, personalized_message)
    personalized_message <- gsub("\\[POSITION\\]", contact$Position, personalized_message)
    personalized_message <- gsub("\\[ORGANIZATION\\]", contact$Organization, personalized_message)
    
    # Send email (or simulate it)
    send_email(
      to_email = contact$Email,
      to_name = contact$Name,
      organization = contact$Organization,
      position = contact$Position,
      message_template = personalized_message
    )
    
    # Progress indicator
    if (i %% 10 == 0) {
      cat("Progress:", i, "/", nrow(contacts), "\n")
    }
  }
  
  cat("\n✅ Email processing completed!\n")
  if (dry_run) {
    cat("💡 To actually send emails, run with dry_run = FALSE\n")
  }
}

# Command line interface
if (!interactive()) {
  # Parse command line arguments
  args <- commandArgs(trailingOnly = TRUE)
  
  if (length(args) == 0) {
    cat("📧 HeelLife Email Sender\n")
    cat("Usage: Rscript send_emails.R [csv_file] [dry_run]\n")
    cat("  csv_file: Path to CSV file (default: heellife_contacts.csv)\n")
    cat("  dry_run: true/false (default: true)\n\n")
    
    # Run in dry-run mode by default
    send_emails_to_contacts(dry_run = TRUE)
    
  } else if (length(args) == 1) {
    csv_file <- args[1]
    send_emails_to_contacts(csv_file = csv_file, dry_run = TRUE)
    
  } else if (length(args) == 2) {
    csv_file <- args[1]
    dry_run <- as.logical(args[2])
    send_emails_to_contacts(csv_file = csv_file, dry_run = dry_run)
  }
} else {
  # Interactive mode
  cat("📧 HeelLife Email Sender - Interactive Mode\n")
  cat("Run send_emails_to_contacts() to send emails\n")
  cat("Example: send_emails_to_contacts(dry_run = FALSE)\n")
}
