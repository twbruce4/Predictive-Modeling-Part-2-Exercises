library(tidyverse)
library(arules)  # has a big ecosystem of packages built around it
library(arulesViz)


#grocery_data=read.csv('groceries.txt',header=FALSE,col.names = paste0("V",seq_len(32)))

grocery_data=read.transactions('groceries.txt',sep=',')
summary(grocery_data)

grocery_trans= as(grocery_data, "transactions")
summary(grocery_trans)

grocery_rules = apriori(grocery_trans, 
                     parameter=list(support=.005, confidence=.1, maxlen=5))

inspect(subset(grocery_rules, subset=lift > 3))
inspect(subset(grocery_rules, subset=confidence > 0.3))

grocery_rules

