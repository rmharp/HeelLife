#!/usr/bin/env Rscript

# HeelLife Package - Department Email Sender via HeelMail (CLI Version)
# This script sends emails to UNC Directors of Undergraduate Studies and
# Student Services Managers using the UNC HeelMail web interface.
# 
# Usage: Rscript send_dept_emails_heelmail_cli.R [options]
# 
# Options:
#   --username USERNAME     UNC ONYEN username (required)
#   --password PASSWORD     UNC password (required)
#   --subject SUBJECT       Email subject line (required)
#   --test-email EMAIL      Test email address (required)
#   --cc-emails EMAILS      CC email addresses (comma-separated, optional)
#   --high-importance       Mark emails as high importance (optional)
#   --gui                   Use GUI email composer (default)
#   --console               Use console input for email content
#   --template              Use default template
#   --message MESSAGE       Custom message for console/template mode
#   --start-index INDEX     Starting department index (default: 1)
#   --help                  Show this help message

# Load required libraries
library(HeelLife)
library(readr)
library(dplyr)

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Help function
show_help <- function() {
  cat("HeelLife Department Email Sender (CLI Version)\n")
  cat("==============================================\n\n")
  cat("Usage: Rscript send_dept_emails_heelmail_cli.R [options]\n\n")
  cat("Required Options:\n")
  cat("  --username USERNAME     UNC ONYEN username\n")
  cat("  --password PASSWORD     UNC password\n")
  cat("  --subject SUBJECT       Email subject line\n")
  cat("  --test-email EMAIL      Test email address\n\n")
  cat("Optional Options:\n")
  cat("  --cc-emails EMAILS      CC email addresses (comma-separated)\n")
  cat("  --high-importance       Mark emails as high importance\n")
  cat("  --gui                   Use GUI email composer (default)\n")
  cat("  --console               Use console input for email content\n")
  cat("  --template              Use default template\n")
  cat("  --message MESSAGE       Custom message for console/template mode\n")
  cat("  --mfa-code CODE         MFA code (if not provided, will prompt during execution)\n")
  cat("  --start-index INDEX     Starting department index (default: 1)\n")
  cat("  --help                  Show this help message\n\n")
  cat("Examples:\n")
  cat("  # Use GUI composer\n")
  cat("  Rscript send_dept_emails_heelmail_cli.R --username myonyen --password mypass --subject 'Test' --test-email me@unc.edu\n\n")
  cat("  # Use console input\n")
  cat("  Rscript send_dept_emails_heelmail_cli.R --username myonyen --password mypass --subject 'Test' --test-email me@unc.edu --console --message 'Hello world'\n\n")
  cat("  # Use template with CC and high importance\n")
  cat("  Rscript send_dept_emails_heelmail_cli.R --username myonyen --password mypass --subject 'Test' --test-email me@unc.edu --template --cc-emails 'admin@unc.edu' --high-importance\n")
}

# Check for help
if ("--help" %in% args || length(args) == 0) {
  show_help()
  quit(status = 0)
}

# Parse arguments
parse_args <- function(args) {
  result <- list()
  i <- 1
  while (i <= length(args)) {
    if (args[i] == "--username" && i + 1 <= length(args)) {
      result$username <- args[i + 1]
      i <- i + 2
    } else if (args[i] == "--password" && i + 1 <= length(args)) {
      result$password <- args[i + 1]
      i <- i + 2
    } else if (args[i] == "--subject" && i + 1 <= length(args)) {
      result$subject <- args[i + 1]
      i <- i + 2
    } else if (args[i] == "--test-email" && i + 1 <= length(args)) {
      result$test_email <- args[i + 1]
      i <- i + 2
    } else if (args[i] == "--cc-emails" && i + 1 <= length(args)) {
      result$cc_emails <- strsplit(args[i + 1], ",")[[1]] %>% trimws()
      i <- i + 2
    } else if (args[i] == "--message" && i + 1 <= length(args)) {
      result$message <- args[i + 1]
      i <- i + 2
    } else if (args[i] == "--mfa-code" && i + 1 <= length(args)) {
      result$mfa_code <- args[i + 1]
      i <- i + 2
    } else if (args[i] == "--start-index" && i + 1 <= length(args)) {
      result$start_index <- as.numeric(args[i + 1])
      i <- i + 2
    } else if (args[i] == "--high-importance") {
      result$high_importance <- TRUE
      i <- i + 1
    } else if (args[i] == "--gui") {
      result$email_mode <- "gui"
      i <- i + 1
    } else if (args[i] == "--console") {
      result$email_mode <- "console"
      i <- i + 1
    } else if (args[i] == "--template") {
      result$email_mode <- "template"
      i <- i + 1
    } else {
      cat("Unknown option:", args[i], "\n")
      show_help()
      quit(status = 1)
    }
  }
  return(result)
}

# Parse command line arguments
parsed_args <- parse_args(args)

# Set defaults
if (is.null(parsed_args$email_mode)) parsed_args$email_mode <- "gui"
if (is.null(parsed_args$high_importance)) parsed_args$high_importance <- FALSE
if (is.null(parsed_args$start_index)) parsed_args$start_index <- 1
if (is.null(parsed_args$cc_emails)) parsed_args$cc_emails <- NULL

# Validate required arguments
required_args <- c("username", "password", "subject", "test_email")
missing_args <- required_args[!required_args %in% names(parsed_args)]

if (length(missing_args) > 0) {
  cat("❌ Missing required arguments:", paste(missing_args, collapse = ", "), "\n\n")
  show_help()
  quit(status = 1)
}

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

# Create email body based on mode
cat("📝 Creating email content...\n")

if (parsed_args$email_mode == "gui") {
  # Use GUI composer
  cat("🎨 Opening GUI email composer...\n")
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
      from_name = parsed_args$username,
      reply_to_email = paste0(parsed_args$username, "@unc.edu"),
      custom_message = "I'm reaching out to you regarding an important matter.",
      signature_title = "",
      organization_name = ""
    )
  }
  
} else if (parsed_args$email_mode == "console") {
  # Use console input
  if (is.null(parsed_args$message)) {
    cat("❌ --message is required when using --console mode\n")
    quit(status = 1)
  }
  
  email_body <- create_dept_email_template(
    from_name = parsed_args$username,
    reply_to_email = paste0(parsed_args$username, "@unc.edu"),
    custom_message = parsed_args$message,
    signature_title = "",
    organization_name = ""
  )
  
} else if (parsed_args$email_mode == "template") {
  # Use default template
  custom_message <- if (!is.null(parsed_args$message)) {
    parsed_args$message
  } else {
    "I'm reaching out to you regarding an important matter."
  }
  
  email_body <- create_dept_email_template(
    from_name = parsed_args$username,
    reply_to_email = paste0(parsed_args$username, "@unc.edu"),
    custom_message = custom_message,
    signature_title = "",
    organization_name = ""
  )
}

cat("✅ Email template created successfully!\n\n")

# Ensure CLI prompts are used for MFA during this run
Sys.setenv(HEELIFE_FORCE_CLI = "1")

# Preview the email
cat("📋 Email Preview\n")
cat("================\n")
cat("From:", parsed_args$username, "@unc.edu\n")
cat("To: [Department Contacts]\n")
if (!is.null(parsed_args$cc_emails)) {
  cat("CC:", paste(parsed_args$cc_emails, collapse = ", "), "\n")
}
cat("Subject:", parsed_args$subject, "\n")
cat("High Importance:", if (parsed_args$high_importance) "Yes" else "No", "\n")
cat("Body preview (first 200 chars):", substr(email_body, 1, 200), "...\n\n")

# Send test email
cat("🧪 Sending test email to:", parsed_args$test_email, "\n")
cat("This will send ONLY to you - no other emails will be sent yet.\n\n")

tryCatch({
  send_dept_emails_heelmail(
    contacts_df = dept_contacts,
    username = parsed_args$username,
    password = parsed_args$password,
    subject = parsed_args$subject,
    email_body = email_body,
    test_email = parsed_args$test_email,
    cc_emails = parsed_args$cc_emails,
    high_importance = parsed_args$high_importance,
    mfa_code = parsed_args$mfa_code
  )
  cat("✅ Test email sent successfully!\n\n")
  
  # Ask if user wants to proceed
  cat("📋 Test Email Review\n")
  cat("====================\n")
  cat("Please check your email to ensure it looks correct.\n")
  cat("If the test email looks good, run the script again with --send-all to send to all departments.\n\n")
  
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

cat("Script completed.\n")
cat("To send to all departments, run with --send-all flag.\n")
