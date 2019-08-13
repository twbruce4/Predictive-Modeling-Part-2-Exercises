
data <- read.csv("C:/Users/Chris/OneDrive/Documents/GitHub/STA380/data/social_marketing.csv")
# PCA
data <- data[,-38]
data$Label <- NULL
for (i in 1:nrow(data)){
  if (data[i,33] > 6 || data[i,17] > 5){
    data$Label[i] <- 'Fit_Food' #'PF_HN'
  }else{
    data$Label[i] <- 'Other'
  }
}    


data.pca <- data[,-c(1,38)]


Z = data.pca/rowSums(data.pca)

# PCA
set.seed(357)
pc2 = prcomp(Z, scale=TRUE, rank=5)
loadings = pc2$rotation
scores = pc2$x

qplot(scores[,2], scores[,3],  color = data$Label, xlab='Component 2', ylab='Component 3')
qplot(scores[,2], scores[,5],  color = data$Label, xlab='Component 2', ylab='Component 5')+ scale_color_manual(values=c("red","blue"))


D_data = dist(scores[,1:5])
set.seed(357)
hclust_data = hclust(D_data, method='average')
plot(hclust_data)
c3 = cutree(hclust_data, 6)
D3 = data.frame(data, z = c3)

count(D3$Label == "Fit_Food")/nrow(D3)

count(D3$Label == "Fit_Food")/(count(D3$z == 1))
count(D3$z == 1)

table(D3[D3$Label == "Fit_Food",]$z)

(table(D3[D3$Label=='Fit_Food',]$z))/(table(D3$z))
