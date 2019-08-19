library(mosaic)
library(tidyverse)
library(ggplot2)

set.seed(357)
twitter = read.csv('social_marketing.csv')
twitter = twitter[,c(2:37)]

# change our counts to frequencies
Z = twitter/rowSums(twitter)

# PCA
pc1 = prcomp(Z, scale=TRUE, rank=5)
loadings = pc1$rotation
scores = pc1$x

# create a category column regarding our features of interest: outdoors and travel
rowcount = nrow(twitter)
twitter$category = c()
for(i in 1:rowcount)
{
  if(twitter[i,23] >= 4 || twitter[,3] >= 4) {twitter$category[i] = 'outdoors or travel'}
  else {twitter$category[i]= 'none'}
}

# plot our users to their respective components
qplot(scores[,2], scores[,5], col=twitter$category, xlab='Component 2', ylab='Component 5') + scale_color_manual(values=c("blue", "red"))
# cluster based off our components using a distance matrix
D_twitter = dist(scores[,1:5])
set.seed(357)
# hierarchical clustering
hclust_twitter = hclust(D_twitter, method='average')
set.seed(357)
c3 = cutree(hclust_twitter, 6)
D3 = data.frame(twitter, z = c3)

# whats the percent of our cluster in the total sample
count(D3$category == 'outdoors or travel')/nrow(twitter)

# how do the clusters break down by number of observations
table(D3$z)
# how do features of interest break down among clusters
table(D3[D3$category=='outdoors or travel',]$z)
# how do features of interest break down among clusters in percentage
table(D3[D3$category=='outdoors or travel',]$z)/table(D3$z)
