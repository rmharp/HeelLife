# HeelLife R Package

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/HeelLife)](https://CRAN.R-project.org/package=HeelLife)
[![R-CMD-check](https://github.com/rmharp/HeelLife/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rmharp/HeelLife/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`HeelLife` is an R package designed to scrape contact information for student organizations from the UNC Chapel Hill 'Heel Life' website. It automates the login process, navigates the organization directory, and extracts details such as organization name, member names, positions, and emails into a tidy data frame.

## Prerequisites

This package uses `RSelenium` with the Firefox browser. You must have **Mozilla Firefox** installed on your system for the package to work correctly.

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

The main function in this package is `get_unc_contacts()`. It requires your UNC ONYEN and password to log in. It is highly recommended to store your credentials securely using environment variables rather than hardcoding them in your script.

### Quick Start with Example Scripts

The package includes ready-to-use example scripts in `inst/examples/`:

1. **Scrape Contacts**: `inst/examples/run_heellife.R`
2. **Send Emails**: `inst/examples/send_emails.R`

See `inst/examples/README.md` for detailed usage instructions.

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

The function will return a data frame and also save the complete data set to the `output_file` you specify.

## Important Note on Usage

This package is intended for personal use and for individuals who are authorized to access the UNC Heel Life platform. Web scraping can be resource-intensive for the target server. Please use this tool responsibly. The user is responsible for adhering to the website's terms of service.

## Contributing

Contributions are welcome! Please note that this project is released with a [Contributor Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/code_of_conduct.md). By contributing to this project, you agree to abide by its terms. Please open an issue to discuss any changes.
