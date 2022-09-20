## ----setup, echo=FALSE----------------------------------------------------------------------------------------------------
knitr::opts_chunk$set(
  eval = FALSE
)


## ----xaringanExtra-clipboard, echo=FALSE, eval=TRUE-----------------------------------------------------------------------
htmltools::tagList(
  xaringanExtra::use_clipboard(
    button_text = "<i class=\"fa fa-clipboard\"></i>",
    success_text = "<i class=\"fa fa-check\" style=\"color: #90BE6D\"></i>",
    error_text = "<i class=\"fa fa-times-circle\" style=\"color: #F94144\"></i>"
  ),
  rmarkdown::html_dependency_font_awesome()
)


## -------------------------------------------------------------------------------------------------------------------------
remote_driver$
  findElement(using = "css", value = ".my-button")$
  clickElement()


## -------------------------------------------------------------------------------------------------------------------------
remote_driver$
  findElement(using = "id", value = "password")$
  sendKeysToElement(list("my_super_secret_password"))


## -------------------------------------------------------------------------------------------------------------------------
# if not already installed
# install.packages("RSelenium")
library(RSelenium)

driver <- rsDriver(browser = "firefox") # can also be chrome
remote_driver <- driver[["client"]]


## -------------------------------------------------------------------------------------------------------------------------
remote_driver$navigate("https://r-project.org")


## -------------------------------------------------------------------------------------------------------------------------
?RSelenium::remoteDriver


## -------------------------------------------------------------------------------------------------------------------------
remote_driver$
  findElement("link text", "Contributors")$
  clickElement()

remote_driver$
  findElement("partial link text", "Contributors")$
  clickElement()

remote_driver$
  findElement("xpath", "/html/body/div/div[1]/div[1]/div/div[1]/ul/li[3]/a")$
  clickElement()

remote_driver$
  findElement("css selector", "div.col-xs-6:nth-child(1) > ul:nth-child(6) > li:nth-child(3) > a:nth-child(1)")$
  clickElement()


## -------------------------------------------------------------------------------------------------------------------------
remote_driver$getPageSource()


## -------------------------------------------------------------------------------------------------------------------------
x <- remote_driver$getPageSource()[[1]]
rvest::read_html(x)


## -------------------------------------------------------------------------------------------------------------------------
write(x, file = "contributors.html")
# Later and in another script
rvest::read_html("contributors.html")


## -------------------------------------------------------------------------------------------------------------------------
rvest::read_html("https://www.r-project.org/contributors.html")


## ----appendix, eval=TRUE--------------------------------------------------------------------------------------------------
library(rvest)

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


## ----appendix, eval=TRUE, echo = FALSE------------------------------------------------------------------------------------
library(rvest)

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


## ----eval=TRUE, echo = FALSE----------------------------------------------------------------------------------------------
all_contributors[1:136] 

