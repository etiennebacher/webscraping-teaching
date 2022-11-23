library(dplyr)
library(rvest)
library(xml2)
library(RSelenium)
library(logger)

# Create folder where HTML files will be stored if it doesn't already exist
if (!dir.exists("data")) {
  dir.create("data")
}
if (!dir.exists("data/modals")) {
  dir.create("data/modals")
}


# Initiate RSelenium
link <- "http://www.inci.org.br/acervodigital/livros.php"
driver <- rsDriver(browser = c("firefox"))
remote_driver <- driver[["client"]]

# Go the website
remote_driver$navigate(link)

# Wait for the website to load
Sys.sleep(3)


# Fill the nationality field and click on "Validate"
remote_driver$
  findElement(using = "id", value = "nacionalidade")$
  sendKeysToElement(list("PORTUGUESA"))

remote_driver$
  findElement(using = 'name', value = "Reset2")$
  clickElement()


# Wait for the first page to load
Sys.sleep(5)

# Save messages in a log file
log_appender(appender_file("data/modals/00_logfile"))
log_messages()


# Two loops: for all individuals on a page, and for all pages, open the modal
# and get the page source

for (page_index in 1:3) {

  message(paste("Start scraping of page", page_index))

  # Try to find the buttons "Ver Mais"
  all_buttons_loaded <- FALSE
  iterations <- 0
  while(!all_buttons_loaded & iterations < 20) {
    tryCatch(
      {
        test <- remote_driver$
          findElements(using = 'id', value = "link_ver_detalhe")

        if (inherits(test, "list") && length(test) > 0)  {
          all_buttons_loaded <<- TRUE
        }
      },
      error = function(e) {
        iterations <<- iterations + 1
        Sys.sleep(0.5)
      }
    )
  }

  if (!all_buttons_loaded & iterations == 20) {
    message(paste0("Couldn't find buttons on page ", page_index, ". Skipping."))
    next
  }

  buttons <- remote_driver$
    findElements(using = 'id', value = "link_ver_detalhe")

  for (modal_index in seq_along(buttons)) {

    tryCatch(
      {
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
      },
      error = function(e) {
        message(paste("  Failed to scrape modal", modal_index))
        message(paste("  The error was ", e))
        next
      }
    )

    Sys.sleep(1.5)

  }

  # When we got all modals of one page, go to the next page (except if
  # we're on the last one)
  if (page_index != 2348) {
    remote_driver$
      findElement("css", "#paginacao > div.btn:nth-child(4)")$
      clickElement()
  }

  message(paste("Finished scraping of page", page_index))

  # Wait a bit for page loading
  Sys.sleep(3)

}



# Function to clean the HTML for each individual

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


# Get the list of all HTML files
list_html <- list.files("data/modals", pattern = "page", full.names = TRUE)

# Apply the cleaning function to all files
list_out <- lapply(list_html, function(x) {
  read_html(x) |>
    extract_information()
})


# Merge all individuals
main <- data.table::rbindlist(purrr::map(list_out, 1)) |>
  as_tibble()

relations <- data.table::rbindlist(purrr::map(list_out, 2)) |>
  as_tibble()
