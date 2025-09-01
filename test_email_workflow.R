#!/usr/bin/env Rscript

# Example: Test Email Workflow with HeelLife
# This demonstrates the recommended workflow: test with yourself first!

library(HeelLife)

cat("🧪 HeelLife Email Testing Workflow Example\n")
cat("==========================================\n\n")

cat("This example shows the recommended workflow:\n")
cat("1. Compose your email (using GUI or console)\n")
cat("2. Test with yourself first\n")
cat("3. Review the test email\n")
cat("4. Only then send to all departments\n\n")

# Step 1: Compose email using GUI
cat("Step 1: Compose Email Using GUI\n")
cat("================================\n")
cat("Opening the rich text email composer...\n")
cat("Compose your email, then click 'Save Draft' when done.\n\n")

email_html <- compose_email_gui(
  initial_text = "Dear Department,\n\nThis is a test email to verify formatting.\n\nBest regards,\nYour Name",
  window_title = "Test Email Composer"
)

if (is.null(email_html)) {
  cat("❌ Email composition was cancelled. Exiting.\n")
  quit(status = 0)
}

cat("✅ Email composed successfully!\n\n")

# Step 2: Test with yourself first
cat("Step 2: Test with Yourself First\n")
cat("=================================\n")
cat("⚠️  IMPORTANT: Always test with yourself before sending to all departments!\n\n")

# Get test email address
test_email <- readline("Enter YOUR email address for testing (e.g., your_onyen@unc.edu): ")

if (test_email == "") {
  cat("❌ No test email provided. Exiting.\n")
  quit(status = 0)
}

cat("\n📧 Sending test email to:", test_email, "\n")
cat("This will send ONLY to you - no other emails will be sent.\n\n")

# Create test contacts (just for demonstration)
test_contacts <- data.frame(
  Department = "TEST",
  Role = "TEST",
  Email = test_email,
  stringsAsFactors = FALSE
)

# Send test email
cat("Sending test email...\n")
cat("Note: This will open Firefox and require your UNC credentials + MFA.\n\n")

# Get UNC credentials for testing
username <- readline("Enter your UNC ONYEN username: ")
password <- readline("Enter your UNC password: ")

cat("\n📧 Sending test email via HeelMail...\n")

tryCatch({
  send_dept_emails_heelmail(
    contacts_df = test_contacts,
    username = username,
    password = password,
    subject = "TEST EMAIL - Please Review",
    email_body = email_html,
    test_email = test_email  # This ensures ONLY you get the email
  )
  
  cat("✅ Test email sent successfully!\n\n")
  
  # Step 3: Review process
  cat("Step 3: Review Your Test Email\n")
  cat("==============================\n")
  cat("Please check your email to ensure:\n")
  cat("• Content looks correct\n")
  cat("• Formatting is as expected\n")
  cat("• Subject line is appropriate\n")
  cat("• No typos or errors\n\n")
  
  review_ok <- readline("Does the test email look good? (y/N): ")
  
  if (tolower(review_ok) == "y") {
    cat("\n🎉 Perfect! Your email is ready.\n")
    cat("\nNext steps:\n")
    cat("1. Run the full HeelMail script: Rscript send_dept_emails_heelmail.R\n")
    cat("2. Choose option 1 (GUI composer) and recreate your email\n")
    cat("3. Test with yourself again\n")
    cat("4. Send to all departments\n\n")
    
    cat("💡 Pro tip: You can copy the HTML content from this test and reuse it!\n")
    cat("HTML content preview:\n")
    cat(substr(email_html, 1, 200), "...\n")
    
  } else {
    cat("\n❌ Test email needs work. Please fix any issues and run this script again.\n")
  }
  
}, error = function(e) {
  cat("❌ Error sending test email:", e$message, "\n")
  cat("\nCommon issues:\n")
  cat("• Firefox browser not installed\n")
  cat("• UNC credentials incorrect\n")
  cat("• MFA code not entered\n")
  cat("• Network connectivity issues\n\n")
  cat("Please check these and try again.\n")
})

cat("\n✅ Test workflow completed!\n")
