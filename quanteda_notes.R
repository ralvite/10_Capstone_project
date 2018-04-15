require(quanteda)
require(data.table)
require(dplyr)
require(tm)

# Adding two corpus together
txt <- c(text1 = "This is $10 in 999 different ways,\n up and down; left and right!", 
         text2 = "@kenbenoit working: on #quanteda 2day\t4ever, http://textasdata.com?page=123.")

txtb <- c(text3 = "If they contain different sets of document-level variables, these will be stitched together in a fashion that guarantees that no information is lost. Corpus-level medata data is also concatenated.")

myCorpus1 <- corpus(txt) # subsetting character vector: txt[1:5]
myCorpus2 <- corpus(txtb)
myCorpus <- myCorpus1 + myCorpus2

# add metadata
metadoc(myCorpus, "docsource") <- "web"

# summary
summary(myCorpus, showmeta = TRUE)

# find word in corpus
kwic(myCorpus, "different", valuetype = "regex")
# [text1, 7]   is$ 10 in 999 | different | ways, up and down                
# [text3, 4] If they contain | different | sets of document-level variables

# Extracting features
# we must extract a matrix associating values for certain features with each document. 
# In quanteda, we use the dfm function to produce such a matrix. 
# “dfm” is short for document-feature matrix, and always refers to 
# documents in rows and “features” as columns

# 1. Tokenizing texts
# This produces an intermediate object, consisting of a list of tokens in the form of character vectors, 
# where each element of the list corresponds to an input document.
tokens(myCorpus
       , remove_numbers = TRUE
       ,  remove_punct = TRUE
       # , what = "character"
       , ngrams = 2:3
       , concatenator = " "
)

# 2. Constructing a document-feature matrix
# All of the options to tokens() can be passed to dfm()
# See also dfm_trim() to reduce matrix sparcity based on min frequency
myDfm <- dfm(myCorpus
             , remove = stopwords("english") # The option remove provides a list of tokens to be ignored
             # , stem = TRUE
             , remove_punct = TRUE
)
myDfm[, 1:5]
# Document-feature matrix of: 3 documents, 5 features (53.3% sparse).
# 3 x 5 sparse Matrix of class "dfm"
# features
# docs    this is $ 10 in
# text1    1  1 1  1  1
# text2    0  0 0  0  0
# text3    0  2 0  0  1

# To access a list of the most frequently occurring features, we can use topfeatures():
topfeatures(myDfm, 20)  # 20 top words

# Plotting a word cloud is done using textplot_wordcloud(), for a dfm class object.
set.seed(100)
textplot_wordcloud(myDfm, min.freq = 1, random.order = FALSE,
                   rot.per = .25, 
                   colors = RColorBrewer::brewer.pal(8,"Dark2"))

# create a DataTable
# (which is faster and more efficient than DataFrames) with 2 colums: the ngram and its count
dtDfm <- data.table(ngram = featnames(myDfm), count = colSums(myDfm), key = "ngram")
# Store the total number of ngrams (features in quanteda terminology) for later use
nfeats <- nfeat(myDfm)

