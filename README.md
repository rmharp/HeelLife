# HeelLife R Package

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/HeelLife)](https://CRAN.R-project.org/package=HeelLife)
[![R-CMD-check](https://github.com/rmharp/HeelLife/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rmharp/HeelLife/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`HeelLife` is an R package designed to scrape contact information for student organizations from the UNC Chapel Hill 'Heel Life' website and for department contacts from the UNC curricula website. It automates the login process, navigates the organization directory, and extracts details such as organization name, member names, positions, and emails into a tidy data frame. Additionally, it can scrape contact information for Directors of Undergraduate Studies (DUS) and Student Services Managers (SSM) from UNC departments.

## Prerequisites

This package uses `RSelenium` with the Firefox browser for student organization scraping. You must have **Mozilla Firefox** installed on your system for the package to work correctly.

For department email functionality, you'll need to set up the Gmail API.

## Installation

Once the package is on CRAN, you can install it with:

```r
install.packages("HeelLife")
```

You can install the development version from GitHub with:

```r
# install.packages("devtools")
devtools::install_github("rmharp/HeelLife")
```

## Usage

The package provides two main functionalities:

### 1. Student Organization Contact Scraping

The main function for student organizations is `get_unc_contacts()`. It requires your UNC ONYEN and password to log in. It is highly recommended to store your credentials securely using environment variables rather than hardcoding them in your script.

### 2. Department Contact Scraping and Email Sending

For department contacts, use `get_unc_dept_contacts()` to scrape DUS and SSM contacts, and choose between:
- **Gmail API**: Use `send_dept_emails()` (requires Gmail API setup)
- **UNC HeelMail**: Use `send_dept_emails_heelmail()` (uses UNC credentials, no API setup)
- **Unified Interface**: Use `send_dept_emails_unified()` to choose your preferred method

### 3. Rich Text Email Composer

The package now includes a **Rich Text Email Composer GUI** (`compose_email_gui()`) that allows you to:
- Compose emails with a familiar interface similar to popular email clients
- Apply formatting (bold, italic, underline, fonts, sizes, colors, alignment)
- Preview your formatted email in real-time
- Save drafts as HTML content for use with your email functions

This eliminates the need to manually write HTML or provide plain text messages when sending emails.

### Quick Start with Example Scripts

The package includes ready-to-use example scripts in `inst/examples/`:

#### Student Organizations:
1. **Scrape Contacts**: `inst/examples/run_heellife.R`
2. **Send Emails**: `inst/examples/send_emails.R`

#### Department Contacts:
3. **Scrape Department Contacts**: `inst/examples/run_dept_contacts.R`
4. **Send Department Emails (Gmail)**: `inst/examples/send_dept_emails.R`
5. **Send Department Emails (HeelMail)**: `inst/examples/send_dept_emails_heelmail.R`

See `inst/examples/README.md` for detailed usage instructions.

### Student Organization Scraping

You can create a `.env` file in your project's root directory:

```
ONYEN_USERNAME="your_onyen"
ONYEN_PASSWORD="your_password"
```

Then, you can load these variables and run the function:

```r
library(HeelLife)
library(dotenv)

# Load credentials from .env file
load_dot_env()

my_username <- Sys.getenv("ONYEN_USERNAME")
my_password <- Sys.getenv("ONYEN_PASSWORD")

# The function will prompt you for your MFA code in the console
contacts_data <- get_unc_contacts(
  username = my_username,
  password = my_password,
  output_file = "my_unc_contacts.csv"
)

# View the first few rows of the scraped data
print(head(contacts_data))
```

### Department Contact Scraping

```r
library(HeelLife)

# Scrape department contacts (no credentials required)
dept_contacts <- get_unc_dept_contacts(output_file = "dept_contacts.csv")

# View the scraped data
print(head(dept_contacts))

### Composing Rich Text Emails

The package now includes a rich text email composer that makes it easy to create formatted emails:

```r
# Compose a rich text email using the GUI
email_html <- compose_email_gui(
  initial_text = "Dear Department,\n\nWe would like to invite you to our upcoming event."
)

# Send the formatted email if composition was successful
if (!is.null(email_html)) {
  send_dept_emails_heelmail(
    contacts_df = dept_contacts,
    username = "your_onyen",
    password = "your_password",
    subject = "Event Invitation",
    email_body = email_html
  )
}
```

The GUI provides formatting options like bold, italic, underline, fonts, sizes, colors, and alignment. See `EMAIL_COMPOSER_README.md` for detailed usage instructions.

### Sending Emails to Departments

#### Option 1: Via Gmail API
```r
library(HeelLife)

# First, set up Gmail API authentication
library(gmailr)
gm_auth_configure(path = "path/to/your/credentials.json")
gm_auth(email = TRUE, cache = ".secret")

# Create an email template
email_body <- create_dept_email_template(
  from_name = "Dr. Jane Smith",
  reply_to_email = "jane.smith@unc.edu",
  custom_message = "I'm reaching out to invite your department to participate in our upcoming event.",
  signature_title = "Director of Student Programs",
  organization_name = "Office of Student Life"
)

# Send emails to all departments
send_dept_emails(
  contacts_df = dept_contacts,
  from_email = "your_email@gmail.com",
  from_name = "Dr. Jane Smith",
  reply_to_email = "jane.smith@unc.edu",
  subject = "Invitation to Event",
  email_body = email_body
)
```

#### Option 2: Via UNC HeelMail
```r
library(HeelLife)

# Create an email template
email_body <- create_dept_email_template(
  from_name = "Dr. Jane Smith",
  reply_to_email = "jane.smith@unc.edu",
  custom_message = "I'm reaching out to invite your department to participate in our upcoming event.",
  signature_title = "Director of Student Programs",
  organization_name = "Office of Student Life"
)

# Send emails to all departments via HeelMail
send_dept_emails_heelmail(
  contacts_df = dept_contacts,
  username = "janesmith",  # Your UNC ONYEN
  password = "your_password",
  subject = "Invitation to Event",
  email_body = email_body,
  high_importance = TRUE,  # Optional: mark as high importance
  cc_emails = c("admin@unc.edu")  # Optional: CC additional emails
)
```

### 🧪 Testing Workflow - Always Test First!

**⚠️ IMPORTANT: Always test with yourself before sending to all departments!**

The HeelMail scripts now include a built-in testing workflow:

```r
# Test with just yourself first
send_dept_emails_heelmail(
  contacts_df = dept_contacts,
  username = "your_onyen",
  password = "your_password",
  subject = "TEST EMAIL - Please Review",
  email_body = email_html,
  test_email = "your_email@unc.edu"  # This sends ONLY to you
)
```

**Benefits of testing first:**
- ✅ Verify email formatting looks correct
- ✅ Check content and subject line
- ✅ Ensure HeelMail is working properly
- ✅ Avoid sending mistakes to all departments
- ✅ Build confidence before mass sending

**Testing workflow:**
1. **Compose your email** using the GUI composer
2. **Test with yourself** using the `test_email` parameter
3. **Review the test email** to ensure everything looks good
4. **Only then send to all departments**

#### Option 3: Unified Interface
```r
# Choose your preferred method
send_dept_emails_unified(
  contacts_df = dept_contacts,
  method = "heelmail",  # or "gmail"
  username = "janesmith",
  password = "your_password",
  subject = "Invitation to Event",
  email_body = email_body
)
```

The functions will return data frames and also save the complete data sets to the `output_file` you specify.

## Important Note on Usage

This package is intended for personal use and for individuals who are authorized to access the UNC Heel Life platform and UNC curricula website. Web scraping can be resource-intensive for the target server. Please use this tool responsibly. The user is responsible for adhering to the website's terms of service.

## Contributing

Contributions are welcome! Please note that this project is released with a [Contributor Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/code_of_conduct.md). By contributing to this project, you agree to abide by its terms. Please open an issue to discuss any changes.
