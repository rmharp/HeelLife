#!/usr/bin/env Rscript

# HeelLife Package - Department Contacts Scraper
# This script scrapes contact information for UNC Directors of Undergraduate Studies
# and Student Services Managers from the UNC curricula website.

# Load required libraries
library(HeelLife)

cat("🔍 UNC Department Contacts Scraper\n")
cat("=====================================\n\n")

cat("This script will scrape contact information for:\n")
cat("• Directors of Undergraduate Studies (DUS)\n")
cat("• Student Services Managers (SSM)\n")
cat("from the UNC curricula website.\n\n")

# Confirm before proceeding
cat("Press Enter to continue or Ctrl+C to cancel...")
readline()

cat("\n📡 Starting to scrape department contacts...\n")
cat("This may take a few moments...\n\n")

# Run the scraping function
tryCatch({
  dept_contacts <- get_unc_dept_contacts(output_file = "dept_contacts.csv")
  
  cat("\n✅ Scraping completed successfully!\n")
  cat("📊 Total department contacts scraped:", nrow(dept_contacts), "\n")
  cat("📁 Data saved to: dept_contacts.csv\n\n")
  
  # Show summary statistics
  cat("📋 Summary by Role:\n")
  role_summary <- table(dept_contacts$Role)
  for (role in names(role_summary)) {
    cat("  ", role, ":", role_summary[role], "contacts\n")
  }
  
  cat("\n📋 Summary by Department:\n")
  dept_summary <- table(dept_contacts$Department)
  cat("  Total departments:", length(dept_summary), "\n")
  
  # Show sample of the data
  cat("\n📋 Sample of scraped data:\n")
  print(head(dept_contacts, 10))
  
  cat("\n💡 Next steps:\n")
  cat("1. Review the data in 'dept_contacts.csv'\n")
  cat("2. Use 'send_dept_emails.R' to send emails to these contacts\n")
  cat("3. Customize your email template as needed\n\n")
  
}, error = function(e) {
  cat("❌ Error during scraping:", e$message, "\n")
  cat("Please check your internet connection and try again.\n")
})

cat("Script completed.\n")
