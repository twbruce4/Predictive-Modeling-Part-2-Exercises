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
Art_dirs = Sys.glob('C:/Users/chris/OneDrive/Documents/GitHub/STA380/data/ReutersC50/C50train/*')


#author_dirs = Sys.glob('C:/Users/Dhwani/Documents/Coursework/Summer - Predictive Analytics/STA380/STA380/data/ReutersC50/C50train/*')

file_list = NULL
labels = NULL

for(author in Art_dirs) {
  author_name = substring(author, first=73)
  files_to_add = Sys.glob(paste0(author, '/*.txt'))
  file_list = append(file_list, files_to_add)
  labels = append(labels, rep(author_name, length(files_to_add)))
}

Reuters_train = lapply(file_list, readerPlain) 
# Clean up the file names
# This uses the piping operator from magrittr
# See https://cran.r-project.org/web/packages/magrittr/vignettes/magrittr.html
mynames = file_list %>%
  { strsplit(., '/', fixed=TRUE) } %>%
  { lapply(., tail, n=2) } %>%
  { lapply(., paste0, collapse = '') } %>%
  unlist

names(Reuters_train) = mynames
names(Reuters_train) = sub('.txt', '', names(Reuters_train))


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

# cosine similarity
i = 1
j = 3
sum(tfidf_Reuters_train[i,] * (tfidf_Reuters_train[j,]))/(sqrt(sum(tfidf_Reuters_train[i,]^2)) * sqrt(sum(tfidf_Reuters_train[j,]^2)))


# Now PCA on term frequencies
X_train = as.matrix(tfidf_Reuters_train)
summary(colSums(X_train))
scrub_cols = which(colSums(X_train) == 0)
X_train = X_train[,-scrub_cols]

pca_Reuters_train = prcomp(DTM_Reuters_train, scale=TRUE)

X_train_pca = pca_Reuters_train$x[,1:1500]

# If we want to use PCA compressed matricies, we would use pca_Reuters_train$x[,1:1000]

smooth_count = 1/nrow(X_train)
w = rowsum(X_train + smooth_count, labels)
w = w/sum(w)
w = log(w)

smooth_count_pca = 1/nrow(X_train_pca)
w_pca = rowsum(X_train_pca + smooth_count, labels)
w_pca = w_pca/sum(w_pca)
w_pca = log(w_pca)

##################################################################################################
# Get Test Data
Art_dirs = Sys.glob('C:/Users/chris/OneDrive/Documents/GitHub/STA380/data/ReutersC50/C50test/*')


#author_dirs = Sys.glob('C:/Users/Dhwani/Documents/Coursework/Summer - Predictive Analytics/STA380/STA380/data/ReutersC50/C50train/*')

file_list = NULL
test_labels = NULL
author_names = NULL

for(author in Art_dirs) {
  author_name = substring(author, first=72)
  author_names = append(author_names, author_name)
  files_to_add = Sys.glob(paste0(author, '/*.txt'))
  file_list = append(file_list, files_to_add)
  test_labels = append(test_labels, rep(author_name, length(files_to_add)))
}

Reuters_test = lapply(file_list, readerPlain) 

mynames = file_list %>%
  { strsplit(., '/', fixed=TRUE) } %>%
  { lapply(., tail, n=2) } %>%
  { lapply(., paste0, collapse = '') } %>%
  unlist

names(Reuters_test) = mynames
names(Reuters_test) = sub('.txt', '', names(Reuters_test))


## once you have documents in a vector, you 
## create a text mining 'corpus' with: 
documents_raw_test = Corpus(VectorSource(Reuters_test))

## Some pre-processing/tokenization steps.
## tm_map just maps some function to every document in the corpus
my_documents_test = documents_raw_test
my_documents_test = tm_map(my_documents_test, content_transformer(tolower)) # make everything lowercase
my_documents_test = tm_map(my_documents_test, content_transformer(removeNumbers)) # remove numbers
my_documents_test = tm_map(my_documents_test, content_transformer(removePunctuation)) # remove punctuation
my_documents_test = tm_map(my_documents_test, content_transformer(stripWhitespace)) ## remove excess white-space

my_documents_test = tm_map(my_documents_test, content_transformer(removeWords), stopwords("en"))


## create a doc-term-matrix
DTM_Reuters_test = DocumentTermMatrix(my_documents_test, control = list(dictionary=Terms(DTM_Reuters_train)))
DTM_Reuters_test_pca = DocumentTermMatrix(my_documents_test, control = list(dictionary=Terms(X_train_pca)))

X_test = as.matrix(DTM_Reuters_test)
X_test_pca = as.matrix(DTM_Reuters_test_pca)
##################################################################################################################

library(randomForest)
library("caret")

X <- as.matrix(DTM_Reuters_train)

Aut_RF = randomForest(x=X, y=as.factor(labels),ntree=100)

Aut_pred =predict(Aut_RF,newdata=X_test)

Aut_cm = confusionMatrix(table(Aut_pred,test_labels))
Aut_cm$overall


# This got 62% accuracy, when using the X_train matrix that had the tfidf matrix
# got a 55% accuracy.







