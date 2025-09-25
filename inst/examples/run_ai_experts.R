#!/usr/bin/env Rscript

# HeelLife Package - AI Experts Scraper
# This script scrapes contact information for UNC AI experts from the AI experts directory.

# Load required libraries
library(HeelLife)

cat("🤖 UNC AI Experts Scraper\n")
cat("==========================\n\n")

cat("This script will scrape contact information for:\n")
cat("• AI experts across various UNC departments\n")
cat("• Expert names, departments, and email addresses\n")
cat("from the UNC AI experts directory.\n\n")

# Confirm before proceeding
cat("Press Enter to continue or Ctrl+C to cancel...")
readline()

cat("\n📡 Starting to scrape AI experts...\n")
cat("This may take a few moments...\n\n")

# Run the scraping function
tryCatch({
  ai_experts <- get_unc_ai_experts(output_file = "ai_experts.csv")
  
  cat("\n✅ Scraping completed successfully!\n")
  cat("📊 Total AI experts scraped:", nrow(ai_experts), "\n")
  cat("📁 Data saved to: ai_experts.csv\n\n")
  
  # Show summary statistics
  cat("📋 Summary by Department:\n")
  dept_summary <- table(ai_experts$Department)
  for (dept in names(dept_summary)) {
    cat("  ", dept, ":", dept_summary[dept], "experts\n")
  }
  
  cat("\n📋 Total departments:", length(dept_summary), "\n")
  
  # Show sample of the data
  cat("\n📋 Sample of scraped data:\n")
  print(head(ai_experts, 10))
  
  cat("\n💡 Next steps:\n")
  cat("1. Review the data in 'ai_experts.csv'\n")
  cat("2. Use the data for AI-related outreach or research\n")
  cat("3. Customize the scraper if needed for specific use cases\n\n")
  
}, error = function(e) {
  cat("❌ Error during scraping:", e$message, "\n")
  cat("Please check your internet connection and try again.\n")
  cat("The AI experts directory structure may have changed.\n")
})

cat("Script completed.\n")
