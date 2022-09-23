library(rvest)
library(xml2)
library(RSelenium)
library(logger)


# system("taskkill /im java.exe /f", intern=FALSE, ignore.stdout=FALSE)

link <- "http://www.inci.org.br/acervodigital/livros.php"

# Automatically go the website

driver <- rsDriver(browser = c("firefox"))
remote_driver <- driver[["client"]]

remote_driver$navigate(link)


# Fill the nationality field and click on "Validate"

address_element <- remote_driver$findElement(using = "id", value = "nacionalidade")
address_element$sendKeysToElement(list("PORTUGUESA"))

button_element <- remote_driver$findElement(using = 'name', value = "Reset2")
button_element$clickElement()


# Wait 5 sec for the page to load and then click on the button to open the modal
Sys.sleep(5)

# find all modal buttons and highlight them one by one


log_appender(appender_file("data/modals/00_logfile"))
log_messages()

for (page_index in 1:2348) {

  message(paste("Start scraping of page", page_index))

  buttons <- remote_driver$
    findElements(using = 'id', value = "link_ver_detalhe")

  for (modal_index in seq_along(buttons)) {

    # open modal
    buttons[[modal_index]]$clickElement()

    Sys.sleep(1.5)

    # Get the HTML and save it
    tmp <- remote_driver$getPageSource()[[1]]
    write(tmp, file = paste0("data/modals/page-", page_index, "-modal-", modal_index, ".html"))

    # Leave the modal
    body <- remote_driver$findElement(using = "xpath", value = "/html/body")
    body$sendKeysToElement(list(key = "escape"))

    Sys.sleep(1.5)

    message(paste("  Scraped modal", modal_index))

  }

  # When we got all modals of one page, go to the next page (except if we're on
  # the last one)
  if (page_index != 2348) {
    remote_driver$
      findElement("css", "#paginacao > div.btn:nth-child(4)")$
      clickElement()

    Sys.sleep(5)
  }

  message(paste("Finished scraping of page", page_index))

}


