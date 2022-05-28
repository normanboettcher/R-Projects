setwd('/home/norman/Schreibtisch/R')
data <- read.csv('data.csv', header=TRUE)
View(head(data))

library(dplyr)
data %>% 
  group_by('InvoiceNo') %>%
  summarize(order.count = n_distinct(InvoiceNo))
data %>%
  group_by('Description') %>%
  summarize(prduct.count = n_distinct(Description))

#Association rule mining
library(arules)
transactions.obj <- read.transactions(file = 'data.csv', header = TRUE, format='single', sep = ",", cols = c("InvoiceNo", "Description"), rm.duplicates = FALSE,
                                      quote = "", skip = 0, encoding  ="unknown")
transactions.obj
top <- data.frame(head(sort(itemFrequency(transactions.obj, type = 'absolute'),
                     decreasing = TRUE), 10))
top

data.frame(head(sort(itemFrequency(transactions.obj, type = 'absolute'),
                     decreasing = FALSE), 10))

itemFrequencyPlot(transactions.obj, topN = 25)

#Interest Measures
support <- 0.01
confidence <- 0.4
#Frequent Item sets
parameters = list(support=support, minlen=2,maxlen =10, target='frequent itemsets')
freq.items <- apriori(transactions.obj, parameter = parameters)
freq.items.df <- data.frame(item_set=labels(freq.items), support = freq.items@quality)
head(freq.items.df)

parameters = list(support=support, confidence = confidence, minlen=2,maxlen =10, target='rules')
rules <- apriori(transactions.obj, parameter = parameters)
rules.df <- data.frame(rules = labels(rules), rules@quality)
head(rules.df)

###########################With different parameter levels####################################
get.txn <- function(data.path, columns) {
  transactions.obj <- read.transactions(file = data.path, header = TRUE, format='single', sep = ",", cols = columns, rm.duplicates = FALSE,
                                        quote = "", skip = 0, encoding  ="unknown")
  return(transactions.obj)
}

get.rules <- function(support, confidence, transactions) {
  parameters = list(support = support, confidence = confidence, minlen = 8, maxlen = 10, target = 'rules')
  rules <- apriori(transactions, parameter = parameters)
  return(rules)
  
}

explore.parameter <- function(transactions) {
  support.values <- seq(from = 0.001, to = 0.1, by = 0.001)
  confidence.values <- seq(from = 0.05, 0.1, by = 0.01)
  support.confidence <- expand.grid(support = support.values, confidence = confidence.values)
  rules.grid <- apply(support.confidence[,c('support', 'confidence')], 1, function(x) get.rules(x['support'], x['confidence'], transactions))
  no.rules <- sapply(seq_along(rules.grid), function(i) length(labels(rules.grid[[i]])))
  no.rules.df <- data.frame(support.confidence, no.rules) 
  return(no.rules.df)
}
library(ggplot2)
get.plots <- function(no.rules.df) {
  exp.plot <- function(confidence.value) {
    print(ggplot(no.rules.df[no.rules.df$confidence == confidence.value,], aes(support, no.rules), environment = environment()) + geom_line()
                 + ggtitle(paste("confidence = ", confidence.value)))
  }
  confidence.values <- c(0.07, 0.08, 0.09, 0.1)
  mapply(exp.plot, confidence.value = confidence.values)
  
}

columns = c('InvoiceNo','Description')
path = 'data.csv'
transactions.obj <- get.txn(path, columns)
df <- explore.parameter(transactions.obj)
head(df)
get.plots(df)
