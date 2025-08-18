# Resubmission
This is a resubmission of HeelLife 0.1.2 with comprehensive improvements.

## Test environments
- local macOS install, R 4.4.0
- win-builder (devel and release)
- R-hub (all platforms)

## R CMD check results
There were no ERRORs or WARNINGs.
All previous NOTEs have been addressed as follows:
- Corrected placeholder URLs in the DESCRIPTION file to point to the active GitHub repository.
- Replaced the placeholder ORCID iD in the DESCRIPTION file.
- Added a `inst/WORDLIST` file to address the spell-check NOTE for "UNC" and "toolset".
- Fixed global variable bindings using `.data$` syntax within dplyr pipes.
- Resolved dependency issues by moving `stringr` to Imports and adding `tibble` to Suggests.
- Fixed build configuration to properly include R source files.

## New Features
- Added department contact scraping functionality for UNC DUS and SSM contacts.
- Implemented email sending via both Gmail API and UNC HeelMail.
- Added comprehensive unit testing for all new functionalities.
- Fixed RSelenium PhantomJS issues for improved HeelMail automation.

Thank you for considering this submission.