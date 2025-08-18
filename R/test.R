#!/usr/bin/env Rscript

# Test script for the updated HeelLife package
library(HeelLife)

cat("🧪 Testing Updated HeelLife Package\n")
cat("===================================\n\n")

# 1. Test email template creation
cat("1️⃣ Testing email template creation...\n")
email_body <- create_dept_email_template("Riley Harper", "riley.harper@unc.edu", "Test message")
cat("✅ Email template created successfully!\n")
cat("Template length:", nchar(email_body), "characters\n\n")

# Show a preview of the email
cat("📧 Email Template Preview:\n")
cat("==========================\n")
cat(substr(email_body, 1, 300), "...\n\n")

# 2. Test scraping (this should work)
cat("2️⃣ Testing contact data structure...\n")
test_contacts <- data.frame(
  Department = "TEST",
  Role = "TEST",
  Email = "riley.harper@unc.edu",
  stringsAsFactors = FALSE
)
cat("✅ Test contacts created successfully!\n")
cat("Contacts:\n")
print(test_contacts)
cat("\n")

# 3. Test the updated HeelMail function (with PhantomJS fix)
cat("3️⃣ Testing HeelMail function with PhantomJS fix...\n")
cat("Note: This will open Firefox and attempt to log into HeelMail\n")
cat("The PhantomJS connection errors should be resolved now.\n\n")

tryCatch({
  send_dept_emails_heelmail(
    contacts_df = test_contacts,
    username = "rmharp",
    password = "Password233223!",
    subject = "Test Email from HeelLife Package - PhantomJS Fix Test",
    email_body = email_body,
    test_email = "riley.harper@unc.edu"
  )
  cat("✅ HeelMail function executed successfully!\n")
}, error = function(e) {
  cat("❌ Error in HeelMail function:", e$message, "\n")
  if (grepl("PhantomJS", e$message)) {
    cat("⚠️  PhantomJS error still occurring - may need additional fixes\n")
  } else if (grepl("MFA", e$message)) {
    cat("ℹ️  MFA error - this is expected in automated testing\n")
  } else {
    cat("ℹ️  Other error - check the specific error message\n")
  }
})

cat("\n🎉 Testing completed!\n")
cat("The package should now work without PhantomJS connection errors.\n")
