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
#' @param output_file A string specifying the path to save the resulting CSV file.
#'        Defaults to "unc_contacts.csv" in the current working directory.
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
get_unc_contacts <- function(username, password, output_file = "unc_contacts.csv") {
  
  # --- 1. Setup Selenium Server ---
  message("Starting Selenium server with Firefox...")
  rD <- rsDriver(browser = "firefox", chromever = NULL, port = netstat::free_port(), verbose = FALSE)
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