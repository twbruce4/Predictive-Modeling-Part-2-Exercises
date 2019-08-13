data=read.csv('social_marketing.csv')

attach(data)


set.seed(357)
artsy_data=data.frame(beauty, fashion)
artsy_scaled=scale(artsy_data)
artsy_distance_matrix = dist(artsy_scaled, method='euclidean')

hier_artsy = hclust(artsy_distance_matrix, method='average')
cluster1 = cutree(hier_artsy, k=3)
summary(factor(cluster1))


D = data.frame(beauty, fashion, z = cluster1)
ggplot(D) + geom_point(aes(x=beauty, y=fashion, col=factor(z)))
#This shows us that fashion and beauty may be clustered in some way, but from this information,
#we don't know enough yet.  Let's try PCA.

set.seed(357)

Z = data[,c(2:length(data))]/rowSums(data[,c(2:length(data))])

# PCA
pc2 = prcomp(Z, scale=TRUE, rank=5)
loadings = pc2$rotation
scores = pc2$x

data$beauty_fashion=c()
data$beauty_or_fashion=c()

#Label each point based on who tweeted about beauty and/or fashion 4 or more times
for(row in 1:7882){
    if(data[row,29]>=4 & data[row,34]>=4){
      data$beauty_fashion[row]='Beauty and Fashion'
      data$beauty_or_fashion[row]='Beauty or Fashion'
      
    }
    else if(data[row,29]>=4){
      data$beauty_fashion[row]='Beauty'
      data$beauty_or_fashion[row]='Beauty or Fashion'
    }
    else if(data[row,34]>=4){
      data$beauty_fashion[row]='Fashion'
      data$beauty_or_fashion[row]='Beauty or Fashion'
    }
    else{
      data$beauty_fashion[row]='None'
      data$beauty_or_fashion[row]='None'
    }
    
  
    
}

#qplot(scores[,1], scores[,2],col=data$beauty_or_fashion, xlab='Component 1', ylab='Component 2')

qplot(scores[,2], scores[,5],col=data$beauty_or_fashion, xlab='Component 2', ylab='Component 5')+ scale_color_manual(values=c("dark green", "blue"))

#qplot(scores[,4], scores[,5],col=data$beauty_or_fashion, xlab='Component 4', ylab='Component 5')

#qplot(scores[,1], scores[,3],col=data$beauty_or_fashion, xlab='Component 1', ylab='Component 3')

#qplot(scores[,2], scores[,3],col=data$beauty_or_fashion, xlab='Component 2', ylab='Component 3')

set.seed(357)
D_SM = dist(scores[,1:5])
hclust_SM = hclust(D_SM, method='average')
#plot(hclust_SM)
c3 = cutree(hclust_SM, 6)
D3 = data.frame(data, z = c3)




table(D3$beauty_or_fashion)
table(D3[D3$z==6,]$beauty_or_fashion)
table(D3[D3$beauty_or_fashion=='Beauty or Fashion',]$z)

#Fraction of each cluster explained by the beauty or fashion label: 
#Over 70% of cluster 6 is explained by it!  This means that we have potentially identified
#cluster 6 as an important market segment of customers who enjoy beauty/fashion.
(table(D3[D3$beauty_or_fashion=='Beauty or Fashion',]$z))/(table(D3$z))


detach(data)