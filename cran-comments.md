# Test environments
- local macOS install, R 4.3.1  
- win-builder (devel and release)  
- R-hub (all platforms)  

# R CMD check results
There were no ERRORs or WARNINGs.  
There is one NOTE:  
- New submission
This is a new submission to CRAN.  

# Notes on the package
This package is designed to scrape a website that requires user authentication (UNC Chapel Hill’s ‘Heel Life’ portal). As such:  
- The core function `get_unc_contacts()` cannot be run in non-interactive examples, as it requires the user to interactively provide an MFA code in the console. The examples are wrapped in `\dontrun{}`.  
- The package requires the user to have Firefox installed. This is documented in the DESCRIPTION file’s Description field and in the vignette.  

Thank you for considering this submission.
