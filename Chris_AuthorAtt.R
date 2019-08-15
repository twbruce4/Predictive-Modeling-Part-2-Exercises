## The tm library and related plugins comprise R's most popular text-mining stack.
## See http://cran.r-project.org/web/packages/tm/vignettes/tm.pdf
library(tm) 
library(magrittr)
library(slam) #sparse lightweight
library(proxy)

## tm has many "reader" functions.  Each one has
## arguments elem, language, id
## (see ?readPlain, ?readPDF, ?readXML, etc)
## This wraps another function around readPlain to read
## plain text documents in English.
readerPlain = function(fname){
  readPlain(elem=list(content=readLines(fname)), 
            id=fname, language='en') }

## apply to all of Reuters_train Cowell's articles
## (probably not THE Reuters_train Cowell: https://twitter.com/Reuters_traincowell)
## "globbing" = expanding wild cards in filename paths
file_list = Sys.glob('../data/ReutersC50/C50train/*/*.txt')
Reuters_train = lapply(file_list, readerPlain) 

# The file names are ugly...
file_list

# Clean up the file names
# This uses the piping operator from magrittr
# See https://cran.r-project.org/web/packages/magrittr/vignettes/magrittr.html
mynames = file_list %>%
  { strsplit(., '/', fixed=TRUE) } %>%
  { lapply(., tail, n=2) } %>%
  { lapply(., paste0, collapse = '') } %>%
  unlist

# Rename the articles
mynames
names(Reuters_train) = mynames

## once you have documents in a vector, you 
## create a text mining 'corpus' with: 
documents_raw = Corpus(VectorSource(Reuters_train))

## Some pre-processing/tokenization steps.
## tm_map just maps some function to every document in the corpus
my_documents = documents_raw
my_documents = tm_map(my_documents, content_transformer(tolower)) # make everything lowercase
my_documents = tm_map(my_documents, content_transformer(removeNumbers)) # remove numbers
my_documents = tm_map(my_documents, content_transformer(removePunctuation)) # remove punctuation
my_documents = tm_map(my_documents, content_transformer(stripWhitespace)) ## remove excess white-space

## Remove stopwords.  Always be careful with this: one person's trash is another one's treasure.
stopwords("en")
stopwords("SMART")
?stopwords
my_documents = tm_map(my_documents, content_transformer(removeWords), stopwords("en"))


## create a doc-term-matrix
DTM_Reuters_train = DocumentTermMatrix(my_documents)
DTM_Reuters_train # some basic summary statistics


## You can inspect its entries...
inspect(DTM_Reuters_train[1:10,1:20])

## ...find words with greater than a min count...
findFreqTerms(DTM_Reuters_train, 50)

## ...or find words whose count correlates with a specified word.
findAssocs(DTM_Reuters_train, "genetic", .5) 

## Finally, drop those terms that only occur in one or two documents
## This is a common step: the noise of the "long tail" (rare terms)
##	can be huge, and there is nothing to learn if a term occured once.
## Below removes those terms that have count 0 in >99% of docs.  
## Probably a bit stringent here... but only 50 docs!
DTM_Reuters_train = removeSparseTerms(DTM_Reuters_train, 0.99)
DTM_Reuters_train # now ~ 1000 terms (versus ~3000 before)

# construct TF IDF weights
tfidf_Reuters_train = weightTfIdf(DTM_Reuters_train)

####
# Compare documents
####

inspect(tfidf_Reuters_train[1,])
inspect(tfidf_Reuters_train[2,])
inspect(tfidf_Reuters_train[3,])

# could go back to the raw corpus
content(Reuters_train[[1]])
content(Reuters_train[[2]])
content(Reuters_train[[3]])

# cosine similarity
i = 1
j = 3
sum(tfidf_Reuters_train[i,] * (tfidf_Reuters_train[j,]))/(sqrt(sum(tfidf_Reuters_train[i,]^2)) * sqrt(sum(tfidf_Reuters_train[j,]^2)))


#####
# Cluster documents using cosine distance
# cosine distance = 1 - cosine similarity
#####

# define the cosine distance
cosine_dist_mat = proxy::dist(as.matrix(tfidf_Reuters_train), method='cosine')
tree_Reuters_train = hclust(cosine_dist_mat)
plot(tree_Reuters_train)
clust5 = cutree(tree_Reuters_train, k=5)

# inspect the clusters
which(clust5 == 1)
content(Reuters_train[[1]])
content(Reuters_train[[4]])
content(Reuters_train[[5]])



####
# Dimensionality reduction
####

# Now PCA on term frequencies
X = as.matrix(tfidf_Reuters_train)
summary(colSums(X))
scrub_cols = which(colSums(X) == 0)
X = X[,-scrub_cols]

pca_Reuters_train = prcomp(X, scale=TRUE)
plot(pca_Reuters_train) 

# Look at the loadings
pca_Reuters_train$rotation[order(abs(pca_Reuters_train$rotation[,1]),decreasing=TRUE),1][1:25]
pca_Reuters_train$rotation[order(abs(pca_Reuters_train$rotation[,2]),decreasing=TRUE),2][1:25]


## Look at the first two PCs..
# We've now turned each document into a single pair of numbers -- massive dimensionality reduction
pca_Reuters_train$x[,1:2]

plot(pca_Reuters_train$x[,1:2], xlab="PCA 1 direction", ylab="PCA 2 direction", bty="n",
     type='n')
text(pca_Reuters_train$x[,1:2], labels = 1:length(Reuters_train), cex=0.7)

# Both about "Scottish Amicable"
content(Reuters_train[[46]])
content(Reuters_train[[48]])

# Both about genetic testing
content(Reuters_train[[25]])
content(Reuters_train[[26]])

# Both about Ladbroke's merger
content(Reuters_train[[10]])
content(Reuters_train[[11]])

# Conclusion: even just these two-number summaries still preserve a lot of information


# Now look at the word view
# 5-dimensional word vectors
word_vectors = pca_Reuters_train$rotation[,1:5]

word_vectors[984,]

d_mat = dist(t(word_vectors))














