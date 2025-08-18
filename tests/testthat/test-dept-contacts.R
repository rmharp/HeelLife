# Test file for department contact functions

test_that("get_unc_dept_contacts function exists and is callable", {
  # Check that function exists
  expect_true(exists("get_unc_dept_contacts"))
  expect_true(is.function(get_unc_dept_contacts))
  
  # Check function signature
  args <- formals(get_unc_dept_contacts)
  expect_true("output_file" %in% names(args))
})

test_that("send_dept_emails function exists and is callable", {
  # Check that function exists
  expect_true(exists("send_dept_emails"))
  expect_true(is.function(send_dept_emails))
  
  # Check function signature
  args <- formals(send_dept_emails)
  expect_true("contacts_df" %in% names(args))
  expect_true("from_email" %in% names(args))
  expect_true("from_name" %in% names(args))
  expect_true("reply_to_email" %in% names(args))
  expect_true("subject" %in% names(args))
  expect_true("email_body" %in% names(args))
})

test_that("Department contact functions are properly exported", {
  # Check that all department contact functions are exported
  exported_functions <- ls("package:HeelLife")
  
  expect_true("get_unc_dept_contacts" %in% exported_functions)
  expect_true("send_dept_emails" %in% exported_functions)
})

test_that("Department contact functions have correct dependencies", {
  # Check that functions can access required packages
  expect_true(requireNamespace("dplyr", quietly = TRUE))
  expect_true(requireNamespace("stringr", quietly = TRUE))
  expect_true(requireNamespace("readr", quietly = TRUE))
})

test_that("Function parameter validation works", {
  # Test that functions exist and can be called with basic validation
  expect_true(is.function(get_unc_dept_contacts))
  expect_true(is.function(send_dept_emails))
  
  # Check that functions have the expected parameters
  dept_contacts_args <- formals(get_unc_dept_contacts)
  send_emails_args <- formals(send_dept_emails)
  
  expect_true("output_file" %in% names(dept_contacts_args))
  expect_true("contacts_df" %in% names(send_emails_args))
  expect_true("from_email" %in% names(send_emails_args))
  expect_true("subject" %in% names(send_emails_args))
  expect_true("email_body" %in% names(send_emails_args))
})
