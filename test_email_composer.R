#!/usr/bin/env Rscript

# Test script for the new email composer GUI function
# This script tests that the function can be loaded and called

cat("Testing HeelLife package email composer functionality...\n\n")

# Test 1: Check if package can be loaded
cat("Test 1: Loading HeelLife package...\n")
tryCatch({
  library(HeelLife)
  cat("✅ Package loaded successfully\n")
}, error = function(e) {
  cat("❌ Failed to load package:", e$message, "\n")
  stop("Package loading failed")
})

# Test 2: Check if the new function exists
cat("\nTest 2: Checking if compose_email_gui function exists...\n")
if (exists("compose_email_gui")) {
  cat("✅ Function exists\n")
} else {
  cat("❌ Function not found\n")
  stop("Function not found")
}

# Test 3: Check function arguments
cat("\nTest 3: Checking function arguments...\n")
args_info <- args(compose_email_gui)
if (!is.null(args_info)) {
  cat("✅ Function arguments:", paste(names(formals(compose_email_gui)), collapse = ", "), "\n")
} else {
  cat("❌ Could not retrieve function arguments\n")
}

# Test 4: Check if required packages are available
cat("\nTest 4: Checking required packages...\n")
required_packages <- c("shiny", "shinyjs")
for (pkg in required_packages) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    cat("✅", pkg, "package available\n")
  } else {
    cat("❌", pkg, "package not available\n")
    cat("   Install with: install.packages('", pkg, "')\n")
  }
}

# Test 5: Function documentation
cat("\nTest 5: Checking function documentation...\n")
help_text <- capture.output(help(compose_email_gui))
if (length(help_text) > 0) {
  cat("✅ Function documentation available\n")
} else {
  cat("❌ Function documentation not found\n")
}

cat("\n" %+% "=" %+% 50 %+% "\n")
cat("Email composer function testing complete!\n")
cat("\nTo test the actual GUI:\n")
cat("1. Make sure all required packages are installed\n")
cat("2. Run: email_html <- compose_email_gui()\n")
cat("3. The GUI will open in your web browser\n")
cat("4. Compose an email and click 'Save Draft'\n")
cat("5. The function will return the HTML content\n")
cat("\nSee EMAIL_COMPOSER_README.md for detailed usage instructions.\n")
