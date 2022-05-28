library(rvest)
url <- 'https://cran.r-project.org/web/packages/available_packages_by_name.html'
xpath <- '/html/body/div/table//a'
dt <- read_html(url) %>% html_nodes(xpath= xpath)
head(dt)
dt <- dt %>% gsub(pattern= '<.(.[^>]*)>', replacement = '')
head(dt)
r_list <- available.packages()[,'Package']
setdiff(r_list, dt)
setdiff(dt, r_list)
