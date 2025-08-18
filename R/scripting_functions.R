#' Scrape UNC Chapel Hill Student Organization Contacts
#'
#' This function orchestrates the web scraping process for the UNC 'Heel Life'
#' website. It requires user credentials and interactive MFA input. It automates
#' logging in, loading all organization pages, and then iterating through each
#' organization to scrape contact information for its members.
#'
#' @details
#' The function requires Firefox to be installed on the user's system as it uses
#' the 'firefox' driver for `RSelenium`. The process is interactive because it
#' prompts the user to enter a Multi-Factor Authentication (MFA) code sent via text.
#'
#' The scraping process involves:
#' 1.  Starting a Selenium server and Firefox browser.
#' 2.  Navigating to the Heel Life login page.
#' 3.  Submitting user credentials.
#' 4.  Prompting for and submitting the MFA code.
#' 5.  Navigating to the organizations page and loading all results.
#' 6.  Iterating through each organization's page to scrape member details.
#' 7.  Closing the browser and stopping the Selenium server upon completion.
#'
#' @param username Your UNC ONYEN (username).
#' @param password Your UNC password associated with the ONYEN.
#' @param output_file The path to save the output CSV file. Defaults to 
#'        "unc_contacts.csv" in the current working directory.
#' @return A data frame (`tibble`) containing the scraped contact information with
#'   columns: `Organization`, `Position`, `Name`, and `Email`. The function also
#'   writes this data frame to a CSV file specified by `output_file`.
#' @import RSelenium
#' @import dplyr
#' @import rvest
#' @import xml2
#' @import netstat
#' @importFrom readr write_csv
#' @importFrom purrr is_empty
#' @export
#' @examples
#' \dontrun{
#' # This example is not run automatically because it requires credentials
#' # and interactive MFA input.
#'
#' # Load environment variables from a .env file
#' # The .env file should contain:
#' # ONYEN_USERNAME="your_onyen"
#' # ONYEN_PASSWORD="your_password"
#' dotenv::load_dot_env()
#'
#' my_username <- Sys.getenv("ONYEN_USERNAME")
#' my_password <- Sys.getenv("ONYEN_PASSWORD")
#'
#' if (nzchar(my_username) && nzchar(my_password)) {
#'   contacts_df <- get_unc_contacts(
#'     username = my_username,
#'     password = my_password,
#'     output_file = "heellife_contacts.csv"
#'   )
#'   print(head(contacts_df))
#' } else {
#'   message("Please set ONYEN_USERNAME and ONYEN_PASSWORD in your environment.")
#' }
#' }

#' Safely start RSelenium with Firefox, avoiding PhantomJS dependencies
#' 
#' This function starts RSelenium with Firefox while explicitly avoiding
#' any PhantomJS driver downloads that can cause connection errors.
#' 
#' @param port The port to use for the Selenium server
#' @param verbose Whether to show verbose output
#' @return A list containing the server and client objects
#' @import RSelenium
#' @import netstat
# safe_start_selenium <- function(port = NULL, verbose = FALSE) {
#   # Set environment variables to disable driver downloads
#   Sys.setenv(WDM_LOG_LEVEL = "0")  # Disable webdriver manager logging
#   Sys.setenv(WDM_PRINT_FIRST_LINE = "false")  # Disable first line printing
#   Sys.setenv(WDM_LOCAL = "1")  # Use local drivers only
#   Sys.setenv(WDM_SSL_VERIFY = "0")  # Disable SSL verification for downloads
#   Sys.setenv(WDM_CACHE_PATH = tempdir())  # Use temporary directory for cache
#   
#   # Get port if not provided
#   if (is.null(port)) {
#     port <- netstat::free_port()
#   }
#   
#   # Explicitly set all driver versions to NULL to prevent downloads
#   rD <- rsDriver(
#     browser = "firefox",
#     chromever = NULL,
#     phantomver = NULL,
#     geckover = NULL,  # Explicitly set Firefox driver version to NULL
#     port = port,
#     verbose = verbose,
#     extraCapabilities = list(
#       "moz:firefoxOptions" = list(
#         args = c("--no-sandbox", "--disable-dev-shm-usage")
#       )
#     )
#   )
#   
#   return(rD)
# }

#' Alternative Selenium startup that completely bypasses driver downloads
#' 
#' This function uses a different approach to start Selenium without
#' triggering any driver download attempts.
#' 
#' @param port The port to use for the Selenium server
#' @param verbose Whether to show verbose output
#' @return A list containing the server and client objects
#' @import RSelenium
#' @import netstat
alternative_start_selenium <- function(port = NULL, verbose = FALSE) {
  # Get port if not provided
  if (is.null(port)) {
    port <- netstat::free_port()
  }
  
  # Try to use existing Firefox installation without downloading drivers
  tryCatch({
    # Method 1: Use existing Firefox without driver specification
    rD <- rsDriver(
      browser = "firefox",
      port = port,
      verbose = verbose
    )
    return(rD)
  }, error = function(e) {
    # Method 2: If that fails, try with explicit NULL values and environment variables
    message("First method failed, trying alternative approach...")
    
    # Set environment variables to disable webdriver manager
    Sys.setenv(WDM_LOG_LEVEL = "0")
    Sys.setenv(WDM_PRINT_FIRST_LINE = "false")
    Sys.setenv(WDM_LOCAL = "1")  # Use local drivers only
    
    rD <- rsDriver(
      browser = "firefox",
      chromever = NULL,
      phantomver = NULL,
      geckover = NULL,
      port = port,
      verbose = verbose
    )
    return(rD)
  })
}

get_unc_contacts <- function(username, password, output_file = "unc_contacts.csv") {
  
  # Input validation
  if (is.null(username) || !is.character(username) || nchar(trimws(username)) == 0) {
    stop("username must be a non-empty character string")
  }
  if (is.null(password) || !is.character(password) || nchar(trimws(password)) == 0) {
    stop("password must be a non-empty character string")
  }
  if (is.null(output_file) || !is.character(output_file) || nchar(trimws(output_file)) == 0) {
    stop("output_file must be a non-empty character string")
  }
  
  # Clean inputs
  username <- trimws(username)
  password <- trimws(password)
  output_file <- trimws(output_file)
  
  # --- 1. Setup Selenium Server ---
  message("Starting Selenium server with Firefox...")
  rD <- rsDriver(browser = "firefox", chromever = NULL, phantomver = NULL, port = netstat::free_port(), verbose = FALSE)
  remDr <- rD$client
  
  # Ensure the browser closes on exit
  on.exit({
    message("Closing browser and stopping server...")
    remDr$close()
    rD$server$stop()
    rm(rD)
    gc()
  })
  
  # --- 2. Login Process ---
  message("Navigating to Heel Life login page...")
  remDr$navigate("https://heellife.unc.edu/account/login?returnUrl=/organizations")
  Sys.sleep(2)
  
  message("Entering username...")
  login <- remDr$findElement(using = 'id', value = 'username')
  login$sendKeysToElement(list(username))
  remDr$findElement(using = "css", "button")$clickElement()
  Sys.sleep(2)
  
  message("Entering password...")
  pass <- remDr$findElement(using = 'id', value = 'password')
  pass$sendKeysToElement(list(password))
  remDr$findElement(using = "id", value = "submitBtn")$clickElement()
  Sys.sleep(5)
  
  # --- 3. Handle MFA ---
  message("Handling Multi-Factor Authentication...")
  tryCatch({
    remDr$findElement(using = 'xpath', value = "//a[contains(text(), 'Other options')]")$clickElement()
    Sys.sleep(1.5)
    remDr$findElement(using = 'xpath', value = "//div[contains(text(), 'Text')]")$clickElement()
    
    mfa_code <- readline(prompt = "Enter the MFA code sent to your device: ")
    codeloc <- remDr$findElement(using = 'id', value = 'passcode-input')
    codeloc$sendKeysToElement(list(mfa_code))
    remDr$findElement(using = 'css selector', value = 'button[type="submit"]')$clickElement()
    Sys.sleep(1.5)
    
    remDr$findElement(using = 'css selector', value = 'button[id="trust-browser-button"]')$clickElement()
    Sys.sleep(5)
    message("MFA successful.")
  }, error = function(e) {
    message("MFA prompt not detected or failed. Assuming login continued...")
  })
  
  # --- 4. Load All Organizations ---
  message("Loading all organizations... this may take a while.")
  div_element <- remDr$findElement(using = 'css selector', value = 'div[style="color: rgb(73, 73, 73); margin: 15px 0px 0px; font-style: italic; text-align: left;"]')
  div_text <- div_element$getElementText()
  num_results <- as.numeric(regmatches(div_text, gregexpr("\\d+", div_text))[[1]][1])
  num_presses <- ceiling((num_results - 10) / 10)
  
  for (k in 1:num_presses) {
    remDr$executeScript("window.scrollTo(0, document.body.scrollHeight);")
    tryCatch({
      load_more <- remDr$findElement(using = "css", "button")
      load_more$clickElement()
    }, error = function(e) {
      # Ignore error if button is not found (e.g., end of list)
    })
    Sys.sleep(0.2)
  }
  message(paste("Loaded all", num_results, "organizations."))
  
  # --- 5. Scrape Organization Links ---
  message("Extracting organization page links...")
  raw_page <- remDr$getPageSource()[[1]]
  html_page <- xml2::read_html(raw_page)
  org_links <- html_page %>%
    rvest::html_nodes("div[role='listitem'] a") %>%
    rvest::html_attr("href")
  
  all_org_info <- tibble()
  
  # --- 6. Iterate and Scrape Each Organization ---
  message(paste("Starting to scrape", length(org_links), "organizations..."))
  for (i in seq_along(org_links)) {
    org_url <- paste0("https://heellife.unc.edu", org_links[i])
    message(paste("Scraping", i, "/", length(org_links), ":", org_links[i]))
    remDr$navigate(org_url)
    Sys.sleep(0.5) # Wait for page to load
    
    page_raw <- remDr$getPageSource()[[1]]
    html_raw <- xml2::read_html(page_raw)
    
    organization_name <- html_raw %>%
      rvest::html_node("h1") %>%
      rvest::html_text(trim = TRUE)
    
    # Click on each position to reveal email
    position_nodes <- remDr$findElements(using = "xpath", "//div[contains(@style, 'font-size: 14px;') and contains(@style, 'font-weight: bold;')]")
    
    # Pre-scrape names and positions
    positions <- html_raw %>% 
      rvest::html_nodes(xpath = "//div[contains(@style, 'font-size: 14px;') and contains(@style, 'font-weight: bold;')]") %>%
      rvest::html_text(trim = TRUE)
    
    names <- html_raw %>%
      rvest::html_nodes(xpath = "//div[contains(@style, 'margin: 5px 0px;') and contains(@style, 'font-size: 17px;')]") %>%
      rvest::html_text(trim = TRUE)
    
    emails <- character(length(position_nodes))
    
    if (length(position_nodes) > 0) {
      for (j in seq_along(position_nodes)) {
        tryCatch({
          position_nodes[[j]]$clickElement()
          Sys.sleep(0.2)
          
          emails_raw <- remDr$getPageSource()[[1]]
          htmlemails_raw <- xml2::read_html(emails_raw)
          
          email_node <- htmlemails_raw %>% rvest::html_node(xpath = "//a[starts-with(@href, 'mailto:')]")
          
          if (!purrr::is_empty(email_node)) {
            emails[j] <- email_node %>% rvest::html_text(trim = TRUE)
          } else {
            emails[j] <- NA_character_
          }
          
          # Close the modal dialog
          remDr$findElement(using = "xpath", "//button[contains(@class, 'MuiButtonBase-root') and @aria-label='Close']")$clickElement()
          Sys.sleep(0.1)
          
        }, error = function(e) {
          emails[j] <- NA_character_
          # Try to close modal even if there's an error
          tryCatch(remDr$findElement(using = "xpath", "//button[contains(@class, 'MuiButtonBase-root') and @aria-label='Close']")$clickElement(), error = function(e2){})
        })
      }
    }
    
    # Ensure all vectors have the same length
    max_len <- max(length(positions), length(names), length(emails))
    length(positions) <- max_len
    length(names) <- max_len
    length(emails) <- max_len
    
    if(max_len > 0){
      new_org <- dplyr::tibble(
        Organization = organization_name,
        Position = positions,
        Name = names,
        Email = emails
      )
      all_org_info <- dplyr::bind_rows(all_org_info, new_org)
    }
  }
  
  # --- 7. Save and Return Data ---
  message(paste("Scraping complete. Saving data to", output_file))
  readr::write_csv(all_org_info, output_file)
  
  message("Process finished successfully.")
  return(all_org_info)
}

#' Scrape UNC Department Contacts
#'
#' This function scrapes contact information for Directors of Undergraduate Studies (DUS)
#' and Student Services Managers (SSM) from the UNC curricula website.
#'
#' @details
#' The function scrapes the UNC departmental contacts page to extract information about
#' Directors of Undergraduate Studies and Student Services Managers. It returns a data frame
#' with department names, roles, and email addresses.
#'
#' @param output_file Optional path to save the output CSV file. If NULL, no file is saved.
#' @return A data frame containing the scraped contact information with columns:
#'   `Department`, `Role`, and `Email`.
#' @import rvest
#' @import dplyr
#' @importFrom readr write_csv
#' @export
#' @examples
#' \dontrun{
#' # Scrape department contacts
#' dept_contacts <- get_unc_dept_contacts()
#' print(head(dept_contacts))
#' 
#' # Save to file
#' dept_contacts <- get_unc_dept_contacts(output_file = "dept_contacts.csv")
#' }
get_unc_dept_contacts <- function(output_file = NULL) {
  
  message("Scraping UNC departmental contacts...")
  
  # URL for UNC departmental contacts
  url <- "https://curricula.unc.edu/departmental-contacts/?wpv_aux_current_post_id=191&wpv_aux_parent_post_id=191&wpv_view_count=645"
  
  tryCatch({
    # Read the webpage
    page <- xml2::read_html(url)
    
    # Extract table rows
    rows <- page %>% rvest::html_nodes("table tr")
    
    # Process each row
    extracted_data <- lapply(rows, function(row) {
      # Initialize placeholders
      department <- NA
      role <- NA
      
      # Extract text from cells
      cells <- row %>% rvest::html_nodes("td") %>% rvest::html_text(trim = TRUE)
      if (length(cells) >= 1) {
        department <- cells[1]
      }
      if (length(cells) >= 2) {
        role <- cells[2]
      }
      
      # Extract email addresses
      email_links <- row %>% rvest::html_nodes("a[href^='mailto:']") %>% rvest::html_attr("href")
      emails <- if (length(email_links) > 0) {
        unlist(lapply(email_links, function(link) {
          # Remove 'mailto:' and split by ';'
          split_emails <- strsplit(gsub("mailto:", "", link), ";\\s*")
          unlist(split_emails)
        }))
      } else {
        character(0)
      }
      
      list(Department = department, Role = role, Emails = emails)
    })
    
    # Build final data frame
    final_table <- data.frame(
      Department = character(), 
      Role = character(), 
      Email = character(), 
      stringsAsFactors = FALSE
    )
    
    # Populate final_table, ensuring multiple emails result in duplicated rows
    for (row in extracted_data) {
      if (length(row$Emails) > 0) {
        for (email in row$Emails) {
          new_row <- data.frame(
            Department = row$Department, 
            Role = row$Role, 
            Email = email, 
            stringsAsFactors = FALSE
          )
          final_table <- rbind(final_table, new_row)
        }
      } else {
        # If no emails, add the row with NA for Email
        new_row <- data.frame(
          Department = row$Department, 
          Role = row$Role, 
          Email = NA, 
          stringsAsFactors = FALSE
        )
        final_table <- rbind(final_table, new_row)
      }
    }
    
    # Filter for DUS and SSM roles
    filtered_table <- final_table %>%
      dplyr::filter(
        stringr::str_detect(.data$Role, "DUS") | 
        stringr::str_detect(.data$Role, "SSM")
      )
    
    # Remove rows with missing emails
    filtered_table <- filtered_table %>%
      dplyr::filter(!is.na(.data$Email))
    
    message("Successfully scraped ", nrow(filtered_table), " department contacts")
    
    # Save to file if requested
    if (!is.null(output_file)) {
      readr::write_csv(filtered_table, output_file)
      message("Contacts saved to: ", output_file)
    }
    
    return(filtered_table)
    
  }, error = function(e) {
    stop("Error scraping department contacts: ", e$message)
  })
}

#' Send Emails to UNC Department Contacts
#'
#' This function sends emails to Directors of Undergraduate Studies (DUS) and 
#' Student Services Managers (SSM) at UNC departments.
#'
#' @details
#' The function requires Gmail API setup and authentication. It can send emails to
#' all department contacts or start from a specific index. It includes rate limiting
#' checks and supports HTML email content.
#'
#' @param contacts_df Data frame of department contacts (from get_unc_dept_contacts)
#' @param from_email Email address to send from
#' @param from_name Your name for the email signature
#' @param reply_to_email Email address for recipients to reply to
#' @param subject Email subject line
#' @param email_body HTML content of the email body
#' @param start_index Index to start sending from (useful for resuming)
#' @param test_email Optional email address for testing (sends only to this address)
#' @param attachment_paths Optional vector of file paths to attach
#' @return Invisible NULL. Function prints progress and results.
#' @import dplyr
#' @importFrom gmailr gm_auth_configure gm_auth gm_mime gm_to gm_from gm_subject gm_html_body gm_attach_file gm_send_message
#' @export
#' @examples
#' \dontrun{
#' # First, scrape contacts
#' contacts <- get_unc_dept_contacts()
#' 
#' # Send emails to all contacts
#' send_dept_emails(
#'   contacts_df = contacts,
#'   from_email = "your_email@gmail.com",
#'   from_name = "Your Name",
#'   reply_to_email = "your_email@gmail.com",
#'   subject = "Important Announcement",
#'   email_body = "<p>Hello,</p><p>This is a test email.</p>"
#' )
#' 
#' # Test with a single email first
#' send_dept_emails(
#'   contacts_df = contacts,
#'   from_email = "your_email@gmail.com",
#'   from_name = "Your Name",
#'   reply_to_email = "your_email@gmail.com",
#'   subject = "Test Email",
#'   email_body = "<p>Test email body</p>",
#'   test_email = "test@example.com"
#' )
#' }
send_dept_emails <- function(contacts_df, 
                            from_email, 
                            from_name, 
                            reply_to_email, 
                            subject, 
                            email_body, 
                            start_index = 1,
                            test_email = NULL,
                            attachment_paths = NULL) {
  
  # Input validation
  if (is.null(contacts_df) || nrow(contacts_df) == 0) {
    stop("contacts_df must be a non-empty data frame")
  }
  if (is.null(from_email) || !is.character(from_email) || nchar(trimws(from_email)) == 0) {
    stop("from_email must be a non-empty character string")
  }
  if (is.null(from_name) || !is.character(from_name) || nchar(trimws(from_name)) == 0) {
    stop("from_name must be a non-empty character string")
  }
  if (is.null(reply_to_email) || !is.character(reply_to_email) || nchar(trimws(reply_to_email)) == 0) {
    stop("reply_to_email must be a non-empty character string")
  }
  if (is.null(subject) || !is.character(subject) || nchar(trimws(subject)) == 0) {
    stop("subject must be a non-empty character string")
  }
  if (is.null(email_body) || !is.character(email_body) || nchar(trimws(email_body)) == 0) {
    stop("email_body must be a non-empty character string")
  }
  
  # Clean inputs
  from_email <- trimws(from_email)
  from_name <- trimws(from_name)
  reply_to_email <- trimws(reply_to_email)
  subject <- trimws(subject)
  email_body <- trimws(email_body)
  
  # Check if gmailr is available
  if (!requireNamespace("gmailr", quietly = TRUE)) {
    stop("gmailr package is required. Install with: install.packages('gmailr')")
  }
  
  # Group contacts by department (combine multiple emails per department)
  table_grouped <- contacts_df %>%
    dplyr::group_by(.data$Department) %>% 
    dplyr::summarise(Email = paste(.data$Email, collapse = ", "))
  
  message("Prepared to send emails to ", nrow(table_grouped), " departments")
  
  # Function to check for sending limit reached
  check_for_sending_limit_reached <- function() {
    tryCatch({
      my_messages <- gmailr::gm_threads(num_results = 1)
      for (msg_id in gmailr::gm_id(my_messages)) {
        message <- gmailr::gm_message(msg_id)
        if (any(grepl("You have reached a limit for sending mail. Your message was not sent.", 
                      gmailr::gm_body(message), fixed = TRUE))) {
          return(TRUE)
        }
      }
      return(FALSE)
    }, error = function(e) {
      return(FALSE)
    })
  }
  
  # If test email is specified, send only to that address
  if (!is.null(test_email)) {
    message("Sending test email to: ", test_email)
    
    email <- gmailr::gm_mime() %>%
      gmailr::gm_to(test_email) %>%
      gmailr::gm_from(from_email) %>%
      gmailr::gm_subject(paste0("[TEST] ", subject)) %>%
      gmailr::gm_html_body(email_body)
    
    # Add attachments if specified
    if (!is.null(attachment_paths)) {
      for (path in attachment_paths) {
        if (file.exists(path)) {
          email <- email %>% gmailr::gm_attach_file(path)
        }
      }
    }
    
    gmailr::gm_send_message(email)
    message("Test email sent successfully")
    return(invisible(NULL))
  }
  
  # Send emails to all departments
  message("Starting to send emails to departments...")
  last_index <- start_index - 1
  
  for (i in start_index:nrow(table_grouped)) {
    # Check for sending limit
    if (check_for_sending_limit_reached()) {
      message("Limit for sending mail has been reached. Halting email sending.")
      break
    }
    
    to <- table_grouped$Email[i]
    department <- table_grouped$Department[i]
    
    message("Sending email to ", department, " (", i, "/", nrow(table_grouped), ")")
    
    email <- gmailr::gm_mime() %>%
      gmailr::gm_to(to) %>%
      gmailr::gm_from(from_email) %>%
      gmailr::gm_subject(subject) %>%
      gmailr::gm_html_body(email_body)
    
    # Add attachments if specified
    if (!is.null(attachment_paths)) {
      for (path in attachment_paths) {
        if (file.exists(path)) {
          email <- email %>% gmailr::gm_attach_file(path)
        }
      }
    }
    
    gmailr::gm_send_message(email)
    last_index <- i
    
    # Small delay to avoid rate limiting
    Sys.sleep(1)
  }
  
  message("Email sending completed. Last emailed group index: ", last_index)
  return(invisible(NULL))
}

#' Create HTML Email Template for Department Contacts
#'
#' Creates a professional HTML email template for contacting UNC department
#' Directors of Undergraduate Studies and Student Services Managers.
#'
#' @param from_name Your name
#' @param reply_to_email Email address for recipients to reply to
#' @param custom_message Custom message content (will be inserted after greeting)
#' @param signature_title Your title/position
#' @param organization_name Your organization name
#' @param primary_email Your primary email address
#' @return HTML string for the email body
#' @export
#' @examples
#' # Create a basic email template
#' email_html <- create_dept_email_template(
#'   from_name = "Dr. Jane Smith",
#'   reply_to_email = "jane.smith@unc.edu",
#'   custom_message = "I'm reaching out to invite your department to participate in our upcoming event.",
#'   signature_title = "Director of Student Programs",
#'   organization_name = "Office of Student Life"
#' )
#' 
#' print(email_html)
create_dept_email_template <- function(from_name,
                                     reply_to_email,
                                     custom_message = "",
                                     signature_title = "",
                                     organization_name = "",
                                     primary_email = NULL) {
  
  # Use reply_to_email as primary if not specified
  if (is.null(primary_email)) {
    primary_email <- reply_to_email
  }
  
  # Build the HTML email
  if (nchar(custom_message) > 0) {
    # If custom message is provided, create minimal HTML structure around user's message
    # Split the custom message into lines and wrap each in <p> tags
    message_lines <- strsplit(custom_message, "\n")[[1]]
    message_paragraphs <- paste0("<p>", message_lines, "</p>", collapse = "\n      ")
    
    html_content <- paste0(
      "<html>
    <head>
    <style>
    body { 
      font-family: 'Times New Roman', Times, serif; 
      font-size: 12pt; 
      color: black; 
      line-height: 1.6;
    }
    .signature {
      margin-top: 20px;
      border-top: 1px solid #ccc;
      padding-top: 20px;
    }
    </style>
    </head>
    <body>
      ", message_paragraphs, "
      
      <div class='signature'>
        <strong>", from_name, "</strong><br>",
        if (nchar(signature_title) > 0) paste0(signature_title, "<br>") else "",
        if (nchar(organization_name) > 0) paste0(organization_name, "<br>") else "",
        "<strong>Primary Email:</strong> <a href='mailto:", primary_email, "'>", primary_email, "</a>
      </div>
    </body>
    </html>"
    )
  } else {
    # Use the original template when no custom message is provided
    html_content <- paste0(
      "<html>
    <head>
    <style>
    body { 
      font-family: 'Times New Roman', Times, serif; 
      font-size: 12pt; 
      color: black; 
      line-height: 1.6;
    }
    .signature {
      margin-top: 20px;
      border-top: 1px solid #ccc;
      padding-top: 20px;
    }
    </style>
    </head>
    <body>
      <p>Good Evening,</p>
      
      <p>My name is ", from_name, ", and I am reaching out to you in your capacity as a Director of Undergraduate Studies or Student Services Manager.</p>
      
      <p>If you have any questions or would like further information, please feel free to contact me at ", reply_to_email, ". We appreciate your support and look forward to working with you.</p>
      
      <p>Best regards,</p>
      
      <div class='signature'>
        <strong>", from_name, "</strong><br>",
        if (nchar(signature_title) > 0) paste0(signature_title, "<br>") else "",
        if (nchar(organization_name) > 0) paste0(organization_name, "<br>") else "",
        "<strong>Primary Email:</strong> <a href='mailto:", primary_email, "'>", primary_email, "</a>
      </div>
    </body>
    </html>"
    )
  }
  
  return(html_content)
}

#' Send Emails to UNC Department Contacts via HeelMail
#'
#' This function sends emails to Directors of Undergraduate Studies (DUS) and 
#' Student Services Managers (SSM) at UNC departments using the UNC HeelMail web interface.
#'
#' @details
#' The function uses RSelenium to automate the UNC HeelMail web interface. It requires
#' your UNC credentials and handles MFA authentication. This provides an alternative to
#' Gmail API for users who prefer to use UNC's official email system.
#'
#' @param contacts_df Data frame of department contacts (from get_unc_dept_contacts)
#' @param username Your UNC ONYEN username
#' @param password Your UNC password
#' @param subject Email subject line
#' @param email_body HTML content of the email body
#' @param start_index Index to start sending from (useful for resuming)
#' @param test_email Optional email address for testing (sends only to this address)
#' @param cc_emails Optional vector of email addresses to CC
#' @param high_importance Logical. Should emails be marked as high importance?
#' @param attachment_paths Optional vector of file paths to attach
#' @return Invisible NULL. Function prints progress and results.
#' @import RSelenium
#' @import dplyr
#' @import netstat
#' @export
#' @examples
#' \dontrun{
#' # First, scrape contacts
#' contacts <- get_unc_dept_contacts()
#' 
#' # Send emails via HeelMail
#' send_dept_emails_heelmail(
#'   contacts_df = contacts,
#'   username = "your_onyen",
#'   password = "your_password",
#'   subject = "Important Announcement",
#'   email_body = "<p>Hello,</p><p>This is a test email.</p>"
#' )
#' 
#' # Test with a single email first
#' send_dept_emails_heelmail(
#'   contacts_df = contacts,
#'   username = "your_onyen",
#'   password = "your_password",
#'   subject = "Test Email",
#'   email_body = "<p>Test email body</p>",
#'   test_email = "test@example.com"
#' )
#' }
send_dept_emails_heelmail <- function(contacts_df, 
                                     username, 
                                     password, 
                                     subject, 
                                     email_body, 
                                     start_index = 1,
                                     test_email = NULL,
                                     cc_emails = NULL,
                                     high_importance = FALSE,
                                     attachment_paths = NULL) {
  
  # Input validation
  if (is.null(contacts_df) || nrow(contacts_df) == 0) {
    stop("contacts_df must be a non-empty data frame")
  }
  if (is.null(username) || !is.character(username) || nchar(trimws(username)) == 0) {
    stop("username must be a non-empty character string")
  }
  if (is.null(password) || !is.character(password) || nchar(trimws(password)) == 0) {
    stop("password must be a non-empty character string")
  }
  if (is.null(subject) || !is.character(subject) || nchar(trimws(subject)) == 0) {
    stop("subject must be a non-empty character string")
  }
  if (is.null(email_body) || !is.character(email_body) || nchar(trimws(email_body)) == 0) {
    stop("email_body must be a non-empty character string")
  }
  
  # Clean inputs
  username <- trimws(username)
  password <- trimws(password)
  subject <- trimws(subject)
  email_body <- trimws(email_body)
  
  # Check if RSelenium is available
  if (!requireNamespace("RSelenium", quietly = TRUE)) {
    stop("RSelenium package is required. Install with: install.packages('RSelenium')")
  }
  
  # Group contacts by department (combine multiple emails per department)
  table_grouped <- contacts_df %>%
    dplyr::group_by(.data$Department) %>% 
    dplyr::summarise(Email = paste(.data$Email, collapse = ", "))
  
  message("Prepared to send emails to ", nrow(table_grouped), " departments via HeelMail")
  
  # Determine number of emails to send
  if (!is.null(test_email)) {
    num_emails_to_send <- 1
    message("Test mode: sending to ", test_email)
  } else {
    num_emails_to_send <- nrow(table_grouped)
  }
  
  # Start Selenium server
  message("Starting Selenium server with Firefox...")
  rD <- rsDriver(browser = "firefox", chromever = NULL, phantomver = NULL, port = netstat::free_port(), verbose = FALSE)
  remDr <- rD$client
  
  # Ensure the browser closes on exit
  on.exit({
    message("Closing browser and stopping server...")
    remDr$close()
    rD$server$stop()
    rm(rD)
    gc()
  })
  
  tryCatch({
    # Navigate to HeelMail
    message("Navigating to HeelMail...")
    remDr$navigate("http://heelmail.unc.edu/")
    Sys.sleep(1.5)
    
    # Login process
    message("Logging into HeelMail...")
    
    # Enter username (ensure it's in email format)
    if (!grepl("@", username)) {
      username <- paste0(username, "@ad.unc.edu")
    }
    message("Using username: ", username)
    
    # Try to find the email input field with multiple selectors
    message("Looking for email input field...")
    login <- NULL
    email_selectors <- c(
      'input[type="email"]',
      'input[name="email"]',
      'input[id*="email"]',
      'input[placeholder*="email"]',
      'input[placeholder*="Email"]',
      'input[placeholder*="username"]',
      'input[placeholder*="Username"]'
    )
    
    for (selector in email_selectors) {
      tryCatch({
        login <- remDr$findElement(using = 'css selector', value = selector)
        message("Found email input with selector: ", selector)
        break
      }, error = function(e) {
        # Continue to next selector
      })
    }
    
    if (is.null(login)) {
      message("Could not find email input field. The HeelMail interface may have changed.")
      message("Current page source preview:")
      page_source <- remDr$getPageSource()[[1]]
      message(substr(page_source, 1, 500))
      stop("Email input field not found")
    }
    
    login$sendKeysToElement(list(username))
    
    # Click next
    next_button <- remDr$findElement(using = 'css selector', value = 'input[type="submit"]')
    next_button$clickElement()
    Sys.sleep(2)
    
    # Wait for password field to appear and enter password
    message("Waiting for password field...")
    Sys.sleep(1)
    pass <- remDr$findElement(using = 'css selector', value = 'input[type="password"]')
    pass$sendKeysToElement(list(password))
    
    # Click sign in
    signin_button <- remDr$findElement(using = 'css selector', value = 'input[type="submit"]')
    signin_button$clickElement()
    Sys.sleep(1.5)
    
    # Handle MFA - try to find and click text option
    message("Looking for MFA text option...")
    textbutton <- NULL
    
    # Try different selectors for the MFA text option
    text_selectors <- c(
      "//div[contains(text(), 'Text')]",
      "//div[contains(text(), 'text')]",
      "//div[contains(text(), 'SMS')]",
      "//div[contains(text(), 'sms')]",
      "//button[contains(text(), 'Text')]",
      "//button[contains(text(), 'SMS')]",
      "//span[contains(text(), 'Text')]",
      "//span[contains(text(), 'SMS')]"
    )
    
    for (selector in text_selectors) {
      tryCatch({
        textbutton <- remDr$findElement(using = 'xpath', value = selector)
        message("Found MFA text option with selector: ", selector)
        break
      }, error = function(e) {
        # Continue to next selector
      })
    }
    
    if (is.null(textbutton)) {
      message("Could not find MFA text option. The interface may have changed.")
      message("Please manually select the text/SMS option for MFA when prompted.")
      Sys.sleep(5)  # Give user time to manually select
    } else {
      textbutton$clickElement()
      Sys.sleep(2)
    }
    
    # Prompt for MFA code and wait for user input
    message("Please check your phone for the MFA text message...")
    message("Waiting for MFA code input...")
    
    # Wait for user to provide MFA code
    message("Please enter your MFA code when prompted...")
    code <- readline(prompt = "Enter the MFA code sent to your phone: ")
    
    # Validate the code
    if (is.null(code) || code == "" || length(code) == 0) {
      message("No MFA code provided. Please run the function again and enter the code when prompted.")
      stop("MFA code required for HeelMail authentication")
    }
    
    # Enter the MFA code
    message("Entering MFA code...")
    codeloc <- remDr$findElement(using = 'css selector', value = 'input[type="tel"]')
    codeloc$sendKeysToElement(list(code))
    
    # Verify code
    verify_button <- remDr$findElement(using = 'css selector', value = 'input[type="submit"]')
    verify_button$clickElement()
    Sys.sleep(3)
    
    # Handle "Stay signed in" checkbox if it appears
    tryCatch({
      message("Handling 'Stay signed in' option...")
      check_button <- remDr$findElement(using = 'css selector', value = 'input[type="checkbox"]')
      check_button$clickElement()
      
      # Click yes
      yes_button <- remDr$findElement(using = 'css selector', value = 'input[type="submit"]')
      yes_button$clickElement()
      Sys.sleep(2)
    }, error = function(e) {
      message("'Stay signed in' option not found, continuing...")
    })
    
    message("Successfully logged into HeelMail. Starting to send emails...")
    
    # Wait for the page to fully load after login
    message("Waiting for HeelMail page to fully load...")
    Sys.sleep(5)
    
    # Send emails
    last_index <- start_index - 1
    
    for (i in start_index:min(start_index + num_emails_to_send - 1, nrow(table_grouped))) {
      # Click new mail button - try multiple selectors
      message("Looking for New Mail button...")
      new_mail_button <- NULL
      
      # Try different selectors for the New Mail button
      selectors <- c(
        'button[aria-label="New mail"]',
        'button[aria-label="New message"]',
        'button[title="New mail"]',
        'button[title="New message"]',
        'button:contains("New")',
        'button:contains("Compose")',
        'button:contains("Write")'
      )
      
      for (selector in selectors) {
        tryCatch({
          new_mail_button <- remDr$findElement(using = 'css selector', value = selector)
          message("Found New Mail button with selector: ", selector)
          break
        }, error = function(e) {
          # Continue to next selector
        })
      }
      
      if (is.null(new_mail_button)) {
        stop("Could not find New Mail button. The HeelMail interface may have changed.")
      }
      
      new_mail_button$clickElement()
      Sys.sleep(1.5)
      
      # Handle high importance if requested
      if (high_importance) {
        message("Setting high importance for email ", i)
        tryCatch({
          message_button <- remDr$findElement(using = 'xpath', value = "//button[.//span[text()='Message']]")
          message_button$highlightElement()
          message_button$clickElement()
          Sys.sleep(0.5)
          
          # Find and click the second "More options" button
          more_options_buttons <- remDr$findElements(using = 'css selector', value = 'button[aria-label="More options"]')
          if (length(more_options_buttons) >= 2) {
            more_options_button <- more_options_buttons[[2]]
            more_options_button$highlightElement()
            more_options_button$clickElement()
            Sys.sleep(1.5)
            
            # Click "High importance" button
            high_importance_button <- remDr$findElement(using = 'css selector', value = 'button[aria-label="High importance"]')
            high_importance_button$highlightElement()
            high_importance_button$clickElement()
          }
        }, error = function(e) {
          message("Warning: Could not set high importance: ", e$message)
        })
      }
      
      # Determine recipient emails
      if (!is.null(test_email)) {
        email_addresses <- test_email
        department <- "TEST"
      } else {
        email_addresses <- table_grouped$Email[i]
        department <- table_grouped$Department[i]
      }
      
      # Split multiple emails and enter them
      email_addresses <- strsplit(email_addresses, ", ")[[1]]
      email_input_div <- remDr$findElement(using = 'css selector', value = 'div[aria-label="To"]')
      
      for (email in email_addresses) {
        email_input_div$sendKeysToElement(list(email))
        Sys.sleep(2.75)
        email_input_div$sendKeysToElement(list(key = "enter"))
      }
      
      # Handle CC emails if specified
      if (!is.null(cc_emails) && length(cc_emails) > 0) {
        cc_input_div <- remDr$findElement(using = 'css selector', value = 'div[aria-label="Cc"]')
        for (email in cc_emails) {
          cc_input_div$sendKeysToElement(list(email))
          Sys.sleep(2.5)
          cc_input_div$sendKeysToElement(list(key = "enter"))
        }
      }
      
      # Enter subject
      subject_elem <- remDr$findElement(using = 'css selector', value = 'input[aria-label="Subject"]')
      subject_elem$sendKeysToElement(list(subject))
      
      # Enter email body using JavaScript - using the working approach from UNC Departments HeelMail.R
      body_escaped <- gsub("'", "\\\\'", email_body)
      body_escaped <- gsub("\n", "<br>", body_escaped)
      
      # Wait a bit for the editor to be fully ready
      Sys.sleep(2)
      
      # First, check if editor exists and log it
      cat("Checking if editor exists...\n")
      check_script <- "var editor = document.querySelector('div[contenteditable=\"true\"][aria-label=\"Message body\"]');
      if (editor) {
          console.log('Editor found:', editor);
          console.log('Editor content before:', editor.innerHTML);
          return 'Found - Content length: ' + editor.innerHTML.length;
      } else {
          console.log('Editor not found');
          return 'Not found';
      }"
      
      editor_status <- remDr$executeScript(check_script, args = list(list()))
      cat("Editor status:", ifelse(is.list(editor_status), paste(unlist(editor_status), collapse=" "), editor_status), "\n")
      
      # Now insert the content
      cat("Attempting to insert message content...\n")
      script <- sprintf("var editor = document.querySelector('div[contenteditable=\"true\"][aria-label=\"Message body\"]');
      if (editor) {
          console.log('Editor found, inserting content...');
          var newElement = document.createElement('div');
          newElement.className = 'elementToProof';
          newElement.style.fontFamily = 'Times New Roman, Times, serif';
          newElement.style.fontSize = '12pt';
          newElement.style.color = 'rgb(0, 0, 0)';
          newElement.innerHTML = '%s<br>';
      
          if (editor.firstChild) {
              editor.insertBefore(newElement, editor.firstChild);
          } else {
              editor.appendChild(newElement);
          }
          console.log('Content inserted. Editor content after:', editor.innerHTML);
          return 'Content inserted successfully - New length: ' + editor.innerHTML.length;
      } else {
          console.log('Editor not found during insertion');
          return 'Editor not found during insertion';
      }", body_escaped)
      
      result <- remDr$executeScript(script, args = list(list()))
      cat("JavaScript execution result:", ifelse(is.list(result), paste(unlist(result), collapse=" "), result), "\n")
      
      # Verify the content was actually inserted
      cat("Verifying content insertion...\n")
      verify_script <- "var editor = document.querySelector('div[contenteditable=\"true\"][aria-label=\"Message body\"]');
      if (editor) {
          var content = editor.innerHTML;
          console.log('Final editor content:', content);
          return content;
      } else {
          return 'Editor not found during verification';
      }"
      
      final_content <- remDr$executeScript(verify_script, args = list(list()))
      cat("Final editor content length:", nchar(ifelse(is.list(final_content), paste(unlist(final_content), collapse=" "), final_content)), "characters\n")
      cat("Content preview:", substr(ifelse(is.list(final_content), paste(unlist(final_content), collapse=" "), final_content), 1, 200), "...\n")
      
      # Handle file attachments if specified
      if (!is.null(attachment_paths)) {
        message("Please drag and drop the following files into the email:")
        for (path in attachment_paths) {
          if (file.exists(path)) {
            message("  - ", path)
          }
        }
        readline(prompt = "Press Enter when you have finished attaching files...")
      }
      
      Sys.sleep(1.5)
      
      # Send the email
      send_button <- remDr$findElement(using = 'css selector', value = 'button[aria-label="Send"]')
      send_button$clickElement()
      Sys.sleep(1.5)
      
      # Handle attachment reminder if it appears
      tryCatch({
        ar_send_button <- remDr$findElement(using = 'css selector', value = 'button#ok-1')
        ar_send_button$highlightElement()
        ar_send_button$clickElement()
        Sys.sleep(1.5)
      }, error = function(e) {
        # Attachment reminder not found, continue
      })
      
      last_index <- i
      message("Email sent to ", department, " (", i, "/", min(start_index + num_emails_to_send - 1, nrow(table_grouped)), ")")
      
      Sys.sleep(1.5)
    }
    
    message("Email sending completed. Last emailed group index: ", last_index)
    
  }, error = function(e) {
    stop("Error during HeelMail email sending: ", e$message)
  })
  
  return(invisible(NULL))
}

#' Send Emails to UNC Department Contacts (Multi-Provider)
#'
#' This function sends emails to Directors of Undergraduate Studies (DUS) and 
#' Student Services Managers (SSM) at UNC departments using either Gmail API or HeelMail.
#'
#' @details
#' This function provides a unified interface for sending emails to department contacts.
#' Users can choose between Gmail API (requires Gmail API setup) and HeelMail (requires
#' UNC credentials and handles MFA).
#'
#' @param contacts_df Data frame of department contacts (from get_unc_dept_contacts)
#' @param method Email sending method: "gmail" or "heelmail"
#' @param ... Additional arguments passed to the specific email sending function
#' @return Invisible NULL. Function prints progress and results.
#' @export
#' @examples
#' \dontrun{
#' # First, scrape contacts
#' contacts <- get_unc_dept_contacts()
#' 
#' # Send via Gmail API
#' send_dept_emails_unified(
#'   contacts_df = contacts,
#'   method = "gmail",
#'   from_email = "your_email@gmail.com",
#'   from_name = "Your Name",
#'   reply_to_email = "your_email@gmail.com",
#'   subject = "Important Announcement",
#'   email_body = "<p>Hello,</p><p>This is a test email.</p>"
#' )
#' 
#' # Send via HeelMail
#' send_dept_emails_unified(
#'   contacts_df = contacts,
#'   method = "heelmail",
#'   username = "your_onyen",
#'   password = "your_password",
#'   subject = "Important Announcement",
#'   email_body = "<p>Hello,</p><p>This is a test email.</p>"
#' )
#' }
send_dept_emails_unified <- function(contacts_df, method = "gmail", ...) {
  
  if (!method %in% c("gmail", "heelmail")) {
    stop("method must be either 'gmail' or 'heelmail'")
  }
  
  if (method == "gmail") {
    send_dept_emails(contacts_df = contacts_df, ...)
  } else if (method == "heelmail") {
    send_dept_emails_heelmail(contacts_df = contacts_df, ...)
  }
}