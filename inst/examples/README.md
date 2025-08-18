# HeelLife Package Examples

This directory contains example scripts demonstrating how to use the HeelLife package for scraping UNC student organization contacts, department contacts, and sending emails.

## 📁 Available Examples

### `run_heellife.R` - Student Organization Contact Scraping Script
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

### `send_emails.R` - Student Organization Email Sending Script
A script to send personalized emails to scraped student organization contacts.

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

### `run_dept_contacts.R` - Department Contacts Scraper
A script to scrape contact information for UNC Directors of Undergraduate Studies (DUS) and Student Services Managers (SSM).

**Features:**
- Scrapes UNC curricula website for department contacts
- Filters for DUS and SSM roles
- Saves output to CSV file
- Shows summary statistics
- No credentials required

**Usage:**
```bash
# Make executable and run
chmod +x inst/examples/run_dept_contacts.R
./inst/examples/run_dept_contacts.R

# Or run with Rscript
Rscript inst/examples/run_dept_contacts.R
```

### `send_dept_emails.R` - Department Email Sender
A script to send emails to UNC department contacts using Gmail API.

**Features:**
- Reads department contacts from CSV file
- Interactive email composition
- Professional HTML email templates
- Test email functionality
- Gmail API integration
- Rate limiting protection
- Resume capability

**Usage:**
```bash
# Make executable and run
chmod +x inst/examples/send_dept_emails.R
./inst/examples/send_dept_emails.R

# Or run with Rscript
Rscript inst/examples/send_dept_emails.R
```

## 🔐 Setting Up Credentials

### Option 1: Environment Variables (Recommended for Student Organizations)
Create a `.env` file in your working directory:
```bash
# Copy the example file
cp inst/examples/env_example.txt .env

# Edit with your credentials
ONYEN_USERNAME="your_onyen"
ONYEN_PASSWORD="your_password"
```

### Option 2: Gmail API Setup (Required for Department Emails)
For sending emails to departments, you'll need to set up Gmail API:

1. Visit [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Gmail API for your project
3. Create OAuth 2.0 credentials
4. Download the JSON credentials file
5. Configure gmailr in your R session:
```r
library(gmailr)
gm_auth_configure(path = "path/to/your/credentials.json")
gm_auth(email = TRUE, cache = ".secret")
```

### Option 3: Interactive Input
The scripts will prompt for credentials if environment variables are not set.

## 🚀 Complete Workflows

### Student Organization Workflow
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

### Department Contacts Workflow
1. **Scrape Department Contacts:**
   ```bash
   Rscript inst/examples/run_dept_contacts.R
   ```

2. **Send Emails to Departments:**
   ```bash
   Rscript inst/examples/send_dept_emails.R
   ```

## ⚠️ Important Notes

- **Firefox Required**: The student organization scraper needs Firefox browser
- **MFA Required**: Student organization scraping requires MFA codes during login
- **Gmail API Required**: Department email sending requires Gmail API setup
- **Rate Limiting**: Be respectful of UNC's servers and Gmail's sending limits
- **Email Configuration**: Customize email sending in the respective scripts

## 🔧 Customization

All scripts are designed to be easily customizable:
- Modify message templates in email scripts
- Adjust scraping parameters in scraper scripts
- Add additional error handling or logging
- Integrate with other tools or workflows

## 📚 Related Documentation

- Package vignette: `vignettes/using_heellife.Rmd`
- Function help: `?get_unc_contacts`, `?get_unc_dept_contacts`
- Package README: `README.md`

## 🆕 New Features in v0.1.2

- **Department Contact Scraping**: Scrape DUS and SSM contacts from UNC curricula website
- **Department Email Sending**: Send professional emails to department contacts
- **HTML Email Templates**: Professional email templates with customizable signatures
- **Gmail API Integration**: Secure email sending through Gmail API
- **Rate Limiting Protection**: Built-in protection against email sending limits
