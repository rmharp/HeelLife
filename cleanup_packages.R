#!/usr/bin/env Rscript

# Quick Cleanup Script for HeelLife Package Conflicts
# Run this if you just want to clean up without reinstalling

cat("🧹 Quick Cleanup Script\n")
cat("======================\n\n")

# Remove HeelLife package
if ("HeelLife" %in% installed.packages()[,"Package"]) {
  cat("📦 Removing HeelLife package...\n")
  remove.packages("HeelLife")
  cat("✅ HeelLife removed\n\n")
} else {
  cat("ℹ️  HeelLife not installed\n\n")
}

# Remove RSelenium package
if ("RSelenium" %in% installed.packages()[,"Package"]) {
  cat("🔧 Removing RSelenium package...\n")
  remove.packages("RSelenium")
  cat("✅ RSelenium removed\n\n")
} else {
  cat("ℹ️  RSelenium not installed\n\n")
}

# Clean webdriver cache directories
cat("🗑️  Cleaning webdriver cache...\n")
cache_dirs <- c(
  "~/.wdm",
  "~/.cache/selenium", 
  "~/.cache/webdriver",
  tempdir()
)

for (dir in cache_dirs) {
  expanded_dir <- path.expand(dir)
  if (dir.exists(expanded_dir)) {
    tryCatch({
      unlink(expanded_dir, recursive = TRUE, force = TRUE)
      cat("✅ Cleaned:", expanded_dir, "\n")
    }, error = function(e) {
      cat("⚠️  Could not clean:", expanded_dir, "\n")
    })
  }
}

cat("\n🎉 Cleanup completed!\n")
cat("You can now reinstall packages cleanly.\n")
