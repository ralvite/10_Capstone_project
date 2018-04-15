require(quanteda)
require(data.table)
require(dplyr)
require(tm)


raw_data_dir <- "./data_raw/final/en_US/"
source("./app/assets/parallelize.R")

# Corpus creation
# ----------------------------------------

createCorpus <- function(doc_file){
    # read an input file and load into a corpus
    text_file <- paste(raw_data_dir,doc_file,".txt",sep = "")
    conn <- conn <- file(text_file, "r")
    
    # load doc in character vector
    doc_data <- readLines(conn)
    
    # create corpus
    corpus(doc_data)
    
    # close connection
    # close(conn)
}

corpus_bg <- createCorpus("sample_blogs")
corpus_tw <- createCorpus("sample_twitter")
corpus_nw <- createCorpus("sample_news")


# merge corpus and unlink parts
corpus_merge <- corpus_bg + corpus_nw + corpus_tw
rm(corpus_bg)
rm(corpus_tw)
rm(corpus_nw)


# Extracting features
# ----------------------------------------

# 1. Tokenizing texts

makeTokens <- function(corpus_i, ngram = 1L) {
    
    tokens(corpus_i
           , remove_numbers = TRUE
           , remove_punct = TRUE
           , remove_symbols = TRUE
           , remove_twitter = TRUE
           , remove_url = TRUE
           , what = "word"
           , ngrams = ngram
           , concatenator = " "
    )    
}

# 1-gram
ngram1 <- parallelizeTask(makeTokens, corpus_merge, 1)
dfm1 <- parallelizeTask(dfm, ngram1, remove = stopwords("english") )
rm(ngram1)
# transform dfm to datatable (the dictionary)
dict1 <- data.table(ngram = featnames(dfm1), count = colSums(dfm1), key = "ngram")
rm(dfm1)

# 2-gram
ngram2 <- parallelizeTask(makeTokens, corpus_merge, 2)
dfm2 <- parallelizeTask(dfm, ngram2, remove = stopwords("english") )
rm(ngram2)
# transform dfm to datatable (the dictionary)
dict2 <- data.table(ngram = featnames(dfm2), count = colSums(dfm2), key = "ngram")
rm(dfm2)

# 3-gram
ngram3 <- parallelizeTask(makeTokens, corpus_merge, 3)
dfm3 <- parallelizeTask(dfm, ngram3, remove = stopwords("english") )
rm(ngram3)
# transform dfm to datatable (the dictionary)
dict3 <- data.table(ngram = featnames(dfm3), count = colSums(dfm3), key = "ngram")
rm(dfm3)

# 4-gram
ngram4 <- parallelizeTask(makeTokens, corpus_merge, 4)
dfm4 <- parallelizeTask(dfm, ngram4, remove = stopwords("english") )
rm(ngram4)
# transform dfm to datatable (the dictionary)
dict4 <- data.table(ngram = featnames(dfm4), count = colSums(dfm4), key = "ngram")
rm(dfm4)

predictWord <- function (dict,term) {
    # @params:
    # term: the first n term in the n+1-gram dict
    # ie: term = america; n+1-gram = dict2; predicted_word = "and"
    
    # 1. filter the dictionary with the first input term
    termMatches <- dict[ngram %like% paste("^", term, " ", sep = ""), ]
    
    # 2. get the row with max counts
    termMatches %>% filter(count == max(count))
}

predictWord(dict2, "america")






