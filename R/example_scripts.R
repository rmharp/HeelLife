#' Get Path to Example Scripts
#'
#' Returns the path to the example scripts included with the HeelLife package.
#' These scripts demonstrate how to use the package for scraping contacts
#' and sending emails.
#'
#' @return A list containing paths to example scripts
#' @export
#' @examples
#' # Get paths to example scripts
#' scripts <- heellife_examples()
#' print(scripts)
#'
#' # Run the scraper example
#' system(paste("Rscript", scripts$scraper))
#'
#' # Run the email sender example
#' system(paste("Rscript", scripts$email_sender))
heellife_examples <- function() {
  package_dir <- system.file(package = "HeelLife")
  examples_dir <- file.path(package_dir, "examples")
  
  list(
    scraper = file.path(examples_dir, "run_heellife.R"),
    email_sender = file.path(examples_dir, "send_emails.R"),
    readme = file.path(examples_dir, "README.md"),
    env_example = file.path(examples_dir, "env_example.txt"),
    examples_dir = examples_dir
  )
}

#' Show Example Scripts Information
#'
#' Displays information about the available example scripts and how to use them.
#'
#' @export
#' @examples
#' # Show information about example scripts
#' show_heellife_examples()
show_heellife_examples <- function() {
  scripts <- heellife_examples()
  
  cat("HeelLife Package Example Scripts\n")
  cat("=====================================\n\n")
  
  cat("Examples Directory:", scripts$examples_dir, "\n\n")
  
  cat("Available Scripts:\n")
  cat("  * Scraper:", scripts$scraper, "\n")
  cat("  * Email Sender:", scripts$email_sender, "\n")
  cat("  * Documentation:", scripts$readme, "\n")
  cat("  * Environment Template:", scripts$env_example, "\n\n")
  
  cat("Quick Start Commands:\n")
  cat("  # Scrape contacts\n")
  cat("  Rscript", scripts$scraper, "\n\n")
  
  cat("  # Send emails (test mode)\n")
  cat("  Rscript", scripts$email_sender, "\n\n")
  
  cat("  # Send emails (live mode)\n")
  cat("  Rscript", scripts$email_sender, "contacts.csv false\n\n")
  
  cat("For detailed instructions, see:\n")
  cat("  ", scripts$readme, "\n")
  
  cat("\nTip: Copy the environment template to set up your credentials:\n")
  cat("  cp", scripts$env_example, ".env\n")
}

#' Copy Example Scripts to Working Directory
#'
#' Copies the example scripts to your current working directory for easy access.
#'
#' @param overwrite Logical. Should existing files be overwritten?
#' @return Logical vector indicating which files were copied successfully
#' @export
#' @examples
#' # Copy example scripts to current directory
#' copy_heellife_examples()
#'
#' # Copy and overwrite existing files
#' copy_heellife_examples(overwrite = TRUE)
copy_heellife_examples <- function(overwrite = FALSE) {
  scripts <- heellife_examples()
  
  # Files to copy
  files_to_copy <- c(
    "run_heellife.R" = scripts$scraper,
    "send_emails.R" = scripts$email_sender,
    "env_example.txt" = scripts$env_example,
    "examples_README.md" = scripts$readme
  )
  
  results <- logical(length(files_to_copy))
  names(results) <- names(files_to_copy)
  
  for (i in seq_along(files_to_copy)) {
    source_file <- files_to_copy[i]
    dest_file <- names(files_to_copy)[i]
    
    if (file.exists(source_file)) {
      if (file.exists(dest_file) && !overwrite) {
        cat("Skipping", dest_file, "(already exists, use overwrite = TRUE)\n")
        results[i] <- FALSE
      } else {
        success <- file.copy(source_file, dest_file, overwrite = overwrite)
        if (success) {
          cat("Copied", dest_file, "\n")
          results[i] <- TRUE
        } else {
          cat("Failed to copy", dest_file, "\n")
          results[i] <- FALSE
        }
      }
    } else {
      cat("Source file not found:", source_file, "\n")
      results[i] <- FALSE
    }
  }
  
  cat("\nFiles copied to:", getwd(), "\n")
  cat("Make scripts executable: chmod +x *.R\n")
  
  invisible(results)
}
