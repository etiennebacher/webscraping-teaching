library(dplyr)
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
# Sys.sleep(5)

# find all modal buttons and highlight them one by one


log_appender(appender_file("data/modals/00_logfile"))
log_messages()

for (page_index in 1:2348) {

  message(paste("Start scraping of page", page_index))

  # Try to find the buttons "Ver Mais"
  all_buttons_loaded <- FALSE
  while(!all_buttons_loaded) {
    tryCatch(
      {
        test <- remote_driver$
          findElements(using = 'id', value = "link_ver_detalhe")

        if (inherits(test, "list") && length(test) > 0)  {
          all_buttons_loaded <<- TRUE
        }
      },
      error = function(e) {
        all_buttons_loaded <<- FALSE
        Sys.sleep(0.5)
      }
    )
  }

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

    message(paste("  Scraped modal", modal_index))

    Sys.sleep(1.5)

  }

  # When we got all modals of one page, go to the next page (except if we're on
  # the last one)
  if (page_index != 2348) {
    remote_driver$
      findElement("css", "#paginacao > div.btn:nth-child(4)")$
      clickElement()
  }

  message(paste("Finished scraping of page", page_index))

}




extract_information <- function(raw_html) {

  # Extract the table "Registros relacionados"

  content <- raw_html %>%
    html_nodes("#detalhe_conteudo") %>%
    html_table() %>%
    purrr::pluck(1)

  relacionados <- content[16:nrow(content),] %>%
    mutate(
      across(
        .cols = everything(),
        .fns = ~ {ifelse(.x == "", NA, .x)}
      )
    )

  colnames(relacionados) <- c("Livro", "Pagina", "Familia", "Chegada",
                              "Sobrenome", "Nome", "Idade", "Sexo",
                              "Parentesco", "Nacionalidade",
                              "Vapor", "Est.Civil", "Religiao")


  # Extract text information from "registro de matricula" and create a
  # dataframe from it
  name_items <- raw_html %>%
    html_elements(xpath = '//*[@id="detalhe_conteudo"]/table[1]/tbody/tr/td/strong') %>%
    html_text2() %>%
    gsub("\\n", "", .) %>%
    strsplit(split = "\\t") %>%
    unlist()

  value_items <- raw_html %>%
    html_elements(xpath = '//*[@id="detalhe_conteudo"]/table[1]/tbody/tr/td/div') %>%
    html_text2()

  registro <- data.frame() %>%
    rbind(value_items) %>%
    as_tibble()

  colnames(registro) <- name_items

  return(
    list(
      main = registro,
      related = relacionados
    )
  )

}


list_html <- list.files("data/modals", pattern = "page", full.names = TRUE)


list_out <- lapply(list_html, function(x) {
  read_html(x) |>
    extract_information()
})

main <- data.table::rbindlist(purrr::map(list_out, 1)) |>
  as_tibble()

relations <- data.table::rbindlist(purrr::map(list_out, 2)) |>
  as_tibble()
