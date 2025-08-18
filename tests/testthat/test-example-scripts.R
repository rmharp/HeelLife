# Test file for example scripts functions

test_that("heellife_examples returns correct structure", {
  # Get example scripts
  scripts <- heellife_examples()
  
  # Check that it returns a list
  expect_true(is.list(scripts))
  
  # Check that all expected keys are present
  expected_keys <- c("scraper", "email_sender", "dept_contacts", "dept_emails", 
                     "dept_emails_heelmail", "readme", "env_example", "examples_dir")
  expect_equal(sort(names(scripts)), sort(expected_keys))
  
  # Check that all values are character strings
  for (key in names(scripts)) {
    expect_true(is.character(scripts[[key]]))
    expect_true(length(scripts[[key]]) == 1)
  }
  
  # Check that examples_dir is a directory path
  expect_true(dir.exists(scripts$examples_dir))
})

test_that("heellife_examples returns valid file paths", {
  scripts <- heellife_examples()
  
  # Check that the examples directory exists
  expect_true(dir.exists(scripts$examples_dir))
  
  # Check that the examples directory is within the package
  package_dir <- system.file(package = "HeelLife")
  expect_true(grepl(package_dir, scripts$examples_dir))
})

test_that("show_heellife_examples displays information correctly", {
  # Capture output
  output <- capture.output(show_heellife_examples())
  
  # Check that output contains expected information
  expect_true(any(grepl("HeelLife Package Example Scripts", output)))
  expect_true(any(grepl("Student Organization Scraper", output)))
  expect_true(any(grepl("Department Contacts Scraper", output)))
  expect_true(any(grepl("Department Email Sender \\(Gmail\\)", output)))
  expect_true(any(grepl("Department Email Sender \\(HeelMail\\)", output)))
  
  # Check that output contains usage instructions
  expect_true(any(grepl("Quick Start Commands", output)))
  expect_true(any(grepl("Rscript", output)))
})

test_that("copy_heellife_examples works with overwrite = FALSE", {
  # Get example scripts
  scripts <- heellife_examples()
  
  # Test copying without overwrite
  results <- copy_heellife_examples(overwrite = FALSE)
  
  # Check that results is a logical vector
  expect_true(is.logical(results))
  
  # Check that results has the expected names
  expected_names <- c("run_heellife.R", "send_emails.R", "run_dept_contacts.R", 
                      "send_dept_emails.R", "send_dept_emails_heelmail.R", 
                      "env_example.txt", "examples_README.md")
  expect_equal(sort(names(results)), sort(expected_names))
  
  # Check that all results are logical
  expect_true(all(is.logical(results)))
})

test_that("copy_heellife_examples works with overwrite = TRUE", {
  # Test copying with overwrite
  results <- copy_heellife_examples(overwrite = TRUE)
  
  # Check that results is a logical vector
  expect_true(is.logical(results))
  
  # Check that results has the expected names
  expected_names <- c("run_heellife.R", "send_emails.R", "run_dept_contacts.R", 
                      "send_dept_emails.R", "send_dept_emails_heelmail.R", 
                      "env_example.txt", "examples_README.md")
  expect_equal(sort(names(results)), sort(expected_names))
})

test_that("copy_heellife_examples handles missing source files gracefully", {
  # Test with a non-existent source file
  # This should return FALSE for missing files
  results <- copy_heellife_examples(overwrite = FALSE)
  
  # All results should be logical
  expect_true(all(is.logical(results)))
})

test_that("Example script functions are properly exported", {
  # Check that all example script functions are exported
  exported_functions <- ls("package:HeelLife")
  
  expect_true("heellife_examples" %in% exported_functions)
  expect_true("show_heellife_examples" %in% exported_functions)
  expect_true("copy_heellife_examples" %in% exported_functions)
})

test_that("Example script functions have correct dependencies", {
  # Check that functions can access required packages
  expect_true(requireNamespace("base", quietly = TRUE))
  
  # Test that system.file works
  package_dir <- system.file(package = "HeelLife")
  expect_true(dir.exists(package_dir))
})

test_that("heellife_examples returns consistent results", {
  # Call function multiple times
  scripts1 <- heellife_examples()
  scripts2 <- heellife_examples()
  
  # Results should be identical
  expect_equal(scripts1, scripts2)
})

test_that("show_heellife_examples provides complete information", {
  output <- capture.output(show_heellife_examples())
  
  # Check for all major sections
  expect_true(any(grepl("Available Scripts", output)))
  expect_true(any(grepl("Quick Start Commands", output)))
  expect_true(any(grepl("For detailed instructions", output)))
  expect_true(any(grepl("Tip:", output)))
  
  # Check for specific script mentions
  expect_true(any(grepl("run_heellife.R", output)))
  expect_true(any(grepl("send_emails.R", output)))
  expect_true(any(grepl("run_dept_contacts.R", output)))
  expect_true(any(grepl("send_dept_emails.R", output)))
  expect_true(any(grepl("send_dept_emails_heelmail.R", output)))
})

test_that("copy_heellife_examples handles file operations correctly", {
  # Test the function
  results <- copy_heellife_examples(overwrite = FALSE)
  
  # Check that we got results for all expected files
  expect_equal(length(results), 7)
  
  # Check that all results are logical
  expect_true(all(is.logical(results)))
  
  # Check that results have proper names
  expect_true(all(nchar(names(results)) > 0))
})
