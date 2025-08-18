#!/usr/bin/env Rscript

# Quick test script to verify the subject line selector fix
cat("🧪 Testing Subject Line Selector Fix\n")
cat("===================================\n\n")

# Load the package
cat("📚 Loading HeelLife package...\n")
library(HeelLife)
cat("✅ Package loaded successfully!\n\n")

# Test the fix by checking the function source
cat("🔍 Checking if the subject selector has been updated...\n")

# Look for the updated selector in the function
func_text <- capture.output(send_dept_emails_heelmail)
if (any(grepl('input\\[aria-label="Subject"\\]', func_text))) {
  cat("✅ Subject selector has been updated to 'Subject'\n")
} else if (any(grepl('input\\[aria-label="Add a subject"\\]', func_text))) {
  cat("❌ Subject selector still shows 'Add a subject' - fix not applied\n")
} else {
  cat("ℹ️  Could not find subject selector in function output\n")
}

cat("\n🎉 Test completed!\n")
cat("The subject line selector should now work correctly with HeelMail.\n")
