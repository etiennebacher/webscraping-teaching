library(rvest)
library(xml2)
library(RSelenium)


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
