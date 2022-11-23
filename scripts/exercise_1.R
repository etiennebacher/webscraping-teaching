# if not already installed
# install.packages("RSelenium")
library(RSelenium)
library(rvest)

# Initiate the remote driver
driver <- rsDriver(browser = "firefox") # can also be chrome
remote_driver <- driver[["client"]]

# Go to a specific page
remote_driver$navigate("https://r-project.org")


# Find the button "Contributors" in the sidebar

remote_driver$
  findElement("link text", "Contributors")$
  highlightElement()

remote_driver$
  findElement("link text", "Contributors")$
  clickElement()


# Get the whole HTML that is displayed
remote_driver$getPageSource()

x <- remote_driver$getPageSource()[[1]]
rvest::read_html(x)


# Save this HTML in an external file
write(x, file = "contributors.html")

# Read with rvest
rvest::read_html("contributors.html")

# Close RSelenium
driver$server$close()



#----------------------------------------------------------------------

# Appendix: scrape the saved HTML to extract the list of contributors

html <- read_html("contributors.html")

bullet_points <- html %>%
  html_elements(css = "div.col-xs-12 > ul > li") %>%
  html_text()

blockquote <- html %>%
  html_elements(css = "div.col-xs-12.col-sm-7 > blockquote") %>%
  html_text() %>%
  strsplit(., split = ", ")

blockquote <- blockquote[[1]] %>%
  gsub("\\r|\\n|\\.|and", "", .)

others <- html %>%
  html_elements(xpath = "/html/body/div/div[1]/div[2]/p[5]") %>%
  html_text() %>%
  strsplit(., split = ", ")

others <- others[[1]] %>%
  gsub("\\r|\\n|\\.|and", "", .)

all_contributors <- c(bullet_points, blockquote, others)

all_contributors[1:136]
