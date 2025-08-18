# Test file for HeelMail functions

test_that("create_dept_email_template creates valid HTML", {
  # Test basic template creation
  email_html <- create_dept_email_template(
    from_name = "Dr. Jane Smith",
    reply_to_email = "jane.smith@unc.edu",
    custom_message = "Test message",
    signature_title = "Director",
    organization_name = "Test Org"
  )
  
  # Check that HTML is created
  expect_true(is.character(email_html))
  expect_true(nchar(email_html) > 0)
  
  # Check for required HTML elements
  expect_true(grepl("<html>", email_html))
  expect_true(grepl("</html>", email_html))
  expect_true(grepl("<body>", email_html))
  expect_true(grepl("</body>", email_html))
  
  # Check for content
  expect_true(grepl("Test message", email_html))
  # Signature fields are not auto-inserted; user's message should include any signature
  expect_false(grepl("class='signature'", email_html))
  # No auto-inserted name/email in custom message mode
  expect_false(grepl("Dr. Jane Smith", email_html))
  expect_false(grepl("jane.smith@unc.edu", email_html))
  
  # Check for basic HTML structure (no CSS styling in simplified version)
  expect_true(grepl("<html>", email_html))
  expect_true(grepl("<body>", email_html))
})

test_that("create_dept_email_template handles optional parameters", {
  # Test with minimal parameters
  email_html <- create_dept_email_template(
    from_name = "Test User",
    reply_to_email = "test@unc.edu"
  )
  
  expect_true(is.character(email_html))
  expect_true(grepl("Test User", email_html))
  expect_true(grepl("test@unc.edu", email_html))
  
  # Test with custom primary email
  email_html <- create_dept_email_template(
    from_name = "Test User",
    reply_to_email = "reply@unc.edu",
    primary_email = "primary@unc.edu"
  )
  
  # Primary email is not auto-inserted when no signature is appended
  expect_false(grepl("primary@unc.edu", email_html))
})

test_that("create_dept_email_template handles empty custom message", {
  email_html <- create_dept_email_template(
    from_name = "Test User",
    reply_to_email = "test@unc.edu",
    custom_message = ""
  )
  
  expect_true(is.character(email_html))
  # Should not contain empty paragraph tags
  expect_false(grepl("<p></p>", email_html))
})

test_that("send_dept_emails_unified validates method parameter", {
  # Test invalid method
  expect_error(
    send_dept_emails_unified(method = "invalid"),
    "method must be either 'gmail' or 'heelmail'"
  )
})

test_that("HeelMail functions are properly exported", {
  # Check that all HeelMail functions are exported
  exported_functions <- ls("package:HeelLife")
  
  expect_true("send_dept_emails_heelmail" %in% exported_functions)
  expect_true("send_dept_emails_unified" %in% exported_functions)
  expect_true("create_dept_email_template" %in% exported_functions)
})

test_that("create_dept_email_template handles special characters", {
  # Test with special characters in names and messages
  email_html <- create_dept_email_template(
    from_name = "Dr. O'Connor-Smith",
    reply_to_email = "test@unc.edu",
    custom_message = "Message with 'quotes' and \"double quotes\"",
    signature_title = "Director & Manager",
    organization_name = "Test & Associates, Inc."
  )
  
  expect_true(is.character(email_html))
  # Name is not auto-inserted in custom message mode
  expect_false(grepl("Dr. O'Connor-Smith", email_html))
  expect_true(grepl("Message with 'quotes' and \"double quotes\"", email_html))
  # Signature fields are no longer auto-appended
  expect_false(grepl("Director & Manager", email_html))
  expect_false(grepl("Test & Associates, Inc.", email_html))
})

test_that("create_dept_email_template does not auto-append signature", {
  email_html <- create_dept_email_template(
    from_name = "Test User",
    reply_to_email = "test@unc.edu"
  )
  expect_false(grepl("class='signature'", email_html))
})

test_that("create_dept_email_template handles long messages", {
  long_message <- paste(rep("This is a very long message. ", 50), collapse = "")
  
  email_html <- create_dept_email_template(
    from_name = "Test User",
    reply_to_email = "test@unc.edu",
    custom_message = long_message
  )
  
  expect_true(is.character(email_html))
  expect_true(grepl("This is a very long message", email_html))
  expect_true(nchar(email_html) > nchar(long_message))
})

test_that("create_dept_email_template creates accessible HTML", {
  email_html <- create_dept_email_template(
    from_name = "Test User",
    reply_to_email = "test@unc.edu"
  )
  
  # Check for proper HTML structure (simplified without styling)
  expect_true(grepl("<html>", email_html))
  expect_true(grepl("<body>", email_html))
  expect_true(grepl("</body>", email_html))
  
  # Check for proper paragraph structure (no automatic closing/signature lines)
  expect_true(grepl("<p>Good Evening,</p>", email_html))
  expect_false(grepl("<p>Best regards,</p>", email_html))
})
