### Bonus: get the data from each modal on the museum website by performing the
### POST request yourself.


library(httr)
library(xml2)
library(jsonlite)

# library(httr2)
#
# x <- request("http://www.arquivoestado.sp.gov.br/site/acervo/memoria_do_imigrante/getHospDetalheRela") |>
#   req_body_multipart(
#     livro = "010",
#     pagina = "222",
#     familia = "01381"
#   ) |>
#   req_perform()


x <- POST(
  "http://www.arquivoestado.sp.gov.br/site/acervo/memoria_do_imigrante/getHospedariaDetalhe",
  body = list(
    id = "92276"
  ),
  encode = "multipart"
)

# convert output to a list
out <- as_list(content(x))

# convert output to a dataframe
fromJSON(unlist(out))$dados



x2 <- POST(
  "http://www.arquivoestado.sp.gov.br/site/acervo/memoria_do_imigrante/getHospDetalheRela",
  body = list(
    livro = "010",
    pagina = "222",
    familia = "01381"
  ),
  encode = "multipart"
)

# convert output to a list
out2 <- as_list(content(x2))

# convert output to a dataframe
fromJSON(unlist(out2))$dados
