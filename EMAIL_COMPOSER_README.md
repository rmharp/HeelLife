# Email Composer GUI

The HeelLife package now includes a rich text email composer that provides a user-friendly interface for creating formatted emails without needing to write HTML code manually.

## Features

The email composer GUI includes:

- **Rich Text Formatting**: Bold, italic, and underline text
- **Font Options**: Multiple font families (Arial, Times New Roman, Courier New, Georgia, Verdana, Helvetica)
- **Font Sizes**: Range from 8pt to 28pt
- **Text Alignment**: Left, center, right, and justify alignment
- **Color Picker**: Choose custom text colors
- **Real-time Preview**: See how your email will look as you type
- **Markdown-style Shortcuts**: Use `**text**` for bold, `*text*` for italic, `_text_` for underline

## Usage

### Basic Usage

```r
# Load the package
library(HeelLife)

# Open the email composer
email_html <- compose_email_gui()

# Check if email was composed
if (!is.null(email_html)) {
  # Use the HTML content with your email functions
  send_dept_emails_heelmail(
    contacts_df = contacts,
    username = "your_onyen",
    password = "your_password",
    subject = "Important Announcement",
    email_body = email_html
  )
}
```

### Pre-populate with Text

```r
# Start with some initial text
email_html <- compose_email_gui(
  initial_text = "Hello,\n\nThis is a test email.\n\nBest regards,\nYour Name"
)
```

### Custom Window Title

```r
email_html <- compose_email_gui(
  initial_text = "Dear Department,\n\nWe would like to invite you to our event.",
  window_title = "Event Invitation Composer"
)
```

## How It Works

1. **Open the GUI**: Call `compose_email_gui()` to open a web-based interface in your browser
2. **Compose Your Email**: Type your message in the text area
3. **Apply Formatting**: Use the toolbar buttons or markdown shortcuts to format text
4. **Preview**: Switch to the Preview tab to see how your email will look
5. **Save Draft**: Click "Save Draft" to save your email and return the HTML content
6. **Use the Email**: The function returns an HTML string that can be used directly with your email functions

## Formatting Shortcuts

- **Bold**: Select text and click the **B** button, or use `**text**`
- **Italic**: Select text and click the **I** button, or use `*text*`
- **Underline**: Select text and click the **U** button, or use `_text_`
- **Clear Formatting**: Click the "Clear" button to remove all formatting

## Integration with Existing Functions

The composed email HTML can be used with all your existing HeelLife email functions:

- `send_dept_emails_heelmail()` - Send via UNC HeelMail
- `send_dept_emails()` - Send via Gmail API
- `create_dept_email_template()` - Use as custom message content

## Requirements

The email composer requires these additional packages:
- `shiny` - For the web interface
- `shinyjs` - For enhanced JavaScript functionality

These packages are automatically added to your HeelLife package dependencies.

## Example Workflow

```r
# 1. Scrape contacts
contacts <- get_unc_dept_contacts()

# 2. Compose email with GUI
email_html <- compose_email_gui(
  initial_text = "Dear Department,\n\nWe would like to invite you to our upcoming event."
)

# 3. Send emails if composition was successful
if (!is.null(email_html)) {
  send_dept_emails_heelmail(
    contacts_df = contacts,
    username = "your_onyen",
    password = "your_password",
    subject = "Event Invitation",
    email_body = email_html
  )
} else {
  cat("Email composition was cancelled.\n")
}
```

## Tips

- The GUI opens in your default web browser
- You can resize the browser window for better editing experience
- Use the Preview tab to check how your formatting looks
- The "Clear Formatting" button removes all markdown-style formatting
- If you close the browser window without saving, the function returns `NULL`
- The composed email maintains all your formatting when sent via email

## Troubleshooting

- **GUI doesn't open**: Make sure you have the `shiny` and `shinyjs` packages installed
- **Formatting not working**: Try selecting text first, then clicking the formatting buttons
- **Preview not updating**: Switch between Compose and Preview tabs to refresh the preview
- **Function returns NULL**: This usually means the composition was cancelled or the browser was closed without saving
