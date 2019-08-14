library(tidyverse)
library(arules)  # has a big ecosystem of packages built around it
library(arulesViz)

df <- read.transactions("~/GitHub/STA380/data/groceries.txt", sep = ",")
df$sizes

# Now run the 'apriori' algorithm
# Look at rules with support > .005 & confidence >.1 & length (# artists) <= 5
basketrules = apriori(df, 
                     parameter=list(support=.005, confidence=.1, maxlen=5))

# Look at the output... so many rules!
inspect(basketrules)

# plot all the rules in (support, confidence) space
# notice that high lift rules tend to have low support
plot(basketrules)

# "two key" plot: coloring is by size (order) of item set
plot(basketrules, method='two-key plot')

# can now look at subsets driven by the plot
#inspect(subset(basketrules, support > 0.035))
inspect(subset(basketrules, confidence > 0.2 & lift > 3))


# graph-based visualization
sub1 = subset(basketrules, subset=confidence > 0.2 & lift > 3)
summary(sub1)
plot(sub1, method='graph')
?plot.rules

plot(head(sub1, 100, by='lift'), method='graph')

# export
saveAsGraph(head(basketrules, n = 1000, by = "lift"), file = "basketrules.graphml")




#enlarge the center nodes

#color edges

#color closed groups