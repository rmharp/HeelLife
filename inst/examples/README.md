# HeelLife Package Examples

This directory contains example scripts demonstrating how to use the HeelLife package for scraping UNC student organization contacts and sending emails.

## 📁 Available Examples

### `run_heellife.R` - Contact Scraping Script
A complete script to run the HeelLife scraper from the command line.

**Features:**
- Loads credentials from environment variables or prompts user
- Handles errors gracefully
- Shows progress and results
- Saves output to CSV file

**Usage:**
```bash
# Make executable and run
chmod +x inst/examples/run_heellife.R
./inst/examples/run_heellife.R

# Or run with Rscript
Rscript inst/examples/run_heellife.R
```

### `send_emails.R` - Email Sending Script
A script to send personalized emails to scraped contacts.

**Features:**
- Reads contacts from CSV file
- Personalizes messages with contact information
- Supports dry-run mode for testing
- Configurable message templates
- Progress tracking

**Usage:**
```bash
# Test run (dry-run mode)
Rscript inst/examples/send_emails.R

# Actually send emails
Rscript inst/examples/send_emails.R contacts.csv false
```

## 🔐 Setting Up Credentials

### Option 1: Environment Variables (Recommended)
Create a `.env` file in your working directory:
```bash
# Copy the example file
cp inst/examples/env_example.txt .env

# Edit with your credentials
ONYEN_USERNAME="your_onyen"
ONYEN_PASSWORD="your_password"
```

### Option 2: Interactive Input
The scripts will prompt for credentials if environment variables are not set.

## 🚀 Complete Workflow

1. **Scrape Contacts:**
   ```bash
   Rscript inst/examples/run_heellife.R
   ```

2. **Send Emails:**
   ```bash
   # Test first
   Rscript inst/examples/send_emails.R
   
   # Send for real
   Rscript inst/examples/send_emails.R heellife_contacts.csv false
   ```

## ⚠️ Important Notes

- **Firefox Required**: The scraper needs Firefox browser
- **MFA Required**: You'll need to enter MFA codes during scraping
- **Rate Limiting**: Be respectful of UNC's servers
- **Email Configuration**: Customize email sending in `send_emails.R`

## 🔧 Customization

Both scripts are designed to be easily customizable:
- Modify message templates in `send_emails.R`
- Adjust scraping parameters in `run_heellife.R`
- Add additional error handling or logging
- Integrate with other tools or workflows

## 📚 Related Documentation

- Package vignette: `vignettes/using_heellife.Rmd`
- Function help: `?get_unc_contacts`
- Package README: `README.md`
