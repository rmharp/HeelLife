# Test setup file
# This file runs before tests and sets up test environment

# Create mock data for testing
mock_org_data <- tibble::tibble(
  Organization = c("Test Org 1", "Test Org 2", "Test Org 3"),
  Position = c("President", "Vice President", "Treasurer"),
  Name = c("John Doe", "Jane Smith", "Bob Johnson"),
  Email = c("john.doe@unc.edu", "jane.smith@unc.edu", "bob.johnson@unc.edu")
)

# Mock HTML content for testing
mock_html_content <- '
<div role="listitem">
  <a href="/organizations/test-org-1">Test Organization 1</a>
</div>
<div role="listitem">
  <a href="/organizations/test-org-2">Test Organization 2</a>
</div>
'

# Mock organization page HTML
mock_org_page_html <- '
<h1>Test Organization</h1>
<div style="font-size: 14px; font-weight: bold;">President</div>
<div style="margin: 5px 0px; font-size: 17px;">John Doe</div>
<div style="font-size: 14px; font-weight: bold;">Vice President</div>
<div style="margin: 5px 0px; font-size: 17px;">Jane Smith</div>
'

# Mock email modal HTML
mock_email_modal_html <- '
<a href="mailto:john.doe@unc.edu">john.doe@unc.edu</a>
'
