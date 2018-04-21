require(quanteda)
require(data.table)
require(dplyr)
require(tm)
require(tidyr)


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
dfm1 <- dfm(ngram1, remove = stopwords("english"))
dfm1 <- dfm_select(dfm1, pattern = "[0-9]", selection = "remove", valuetype = "regex")
dfm1 <- dfm_select(dfm1, pattern = "[^a-z]", selection = "remove", valuetype = "regex")
# dfm1 <- parallelizeTask(dfm, ngram1, remove = stopwords("english") )
rm(ngram1)
# transform dfm to datatable (the dictionary)
dict1 <- data.table(ngram = featnames(dfm1), count = colSums(dfm1), key = "ngram")
rm(dfm1)

# 2-gram
ngram2 <- parallelizeTask(makeTokens, corpus_merge, 2)
dfm2 <- dfm(ngram2, remove = stopwords("english"))
# dfm2 <- parallelizeTask(dfm, ngram2, remove = stopwords("english") )
# remove: numbers and not letters or spaces (gram limiter)
dfm2 <- dfm_select(dfm2, pattern = "[0-9]", selection = "remove", valuetype = "regex")
dfm2 <- dfm_select(dfm2, pattern = "[^a-z ]", selection = "remove", valuetype = "regex")
rm(ngram2)
# transform dfm to datatable (the dictionary)
dict2 <- data.table(ngram = featnames(dfm2), count = colSums(dfm2), key = "ngram")
rm(dfm2)

# 3-gram
ngram3 <- parallelizeTask(makeTokens, corpus_merge, 3)
dfm3 <- dfm(ngram3, remove = stopwords("english"))
# dfm3 <- parallelizeTask(dfm, ngram3, remove = stopwords("english") )
dfm3 <- dfm_select(dfm3, pattern = "[0-9]", selection = "remove", valuetype = "regex")
dfm3 <- dfm_select(dfm3, pattern = "[^a-z ]", selection = "remove", valuetype = "regex")
rm(ngram3)
# transform dfm to datatable (the dictionary)
dict3 <- data.table(ngram = featnames(dfm3), count = colSums(dfm3), key = "ngram")
rm(dfm3)

# 4-gram
ngram4 <- parallelizeTask(makeTokens, corpus_merge, 4)
dfm4 <- dfm(ngram4, remove = stopwords("english"))
# dfm4 <- parallelizeTask(dfm, ngram4, remove = stopwords("english") )
dfm4 <- dfm_select(dfm4, pattern = "[0-9]", selection = "remove", valuetype = "regex")
dfm4 <- dfm_select(dfm4, pattern = "[^a-z ]", selection = "remove", valuetype = "regex")
rm(ngram4)
# transform dfm to datatable (the dictionary)
dict4 <- data.table(ngram = featnames(dfm4), count = colSums(dfm4), key = "ngram")
rm(dfm4)


# Arranging dictionaries
# ----------------------------------------

arrange3GramDict <- function(dict){
    dict[, c("w1", "w2", "lastTerm") := tstrsplit(ngram, " ", fixed=TRUE)]
    dict[, c("firstTerms") := paste(w1,w2,sep = " ")]
    select(dict,c("firstTerms","lastTerm","count"))    
}

dict3 <- arrange3GramDict(dict3)

arrange2GramDict <- function(dict){
    dict[, c("firstTerms", "lastTerm") := tstrsplit(ngram, " ", fixed=TRUE)]
    select(dict,c("firstTerms","lastTerm","count"))    
}

dict2 <- arrange2GramDict(dict2)


# Katz Backoff with Good-Turing Discounting
# ----------------------------------------
source("./app/assets/calculateDiscount.R")

# Calculate the discount column in dictionaries
dict3 = createdictExtended(dict3)
dict2 = createdictExtended(dict2)
dict1 = createdictExtended(dict1)

# Calculate the remaining probability (thanks to discounting...).
dict3_leftOverProb = dict3[, .(leftoverprob=calcLeftOverProb(lastTerm, count, discount)), by=firstTerms]

# We now have two important objects: dict3, dict3_leftOverProb
# ...


# Prediction
# ----------------------------------------

# dts is a list of the different datatables where dts[[4]] refer to the dt 4-grams
# dts is stored in app to call predictWord() function
dts <- list(dict1,dict2,dict3,dict4)
# dts[[4]]

predictWord <- function (inputPhrase) {
    # toDo: implementing Katz's Back-off
    # @param: inputPhrase <- "once upon a"
    # Searchs a inputPhrase in a dict
    # @params:
    # inputPhrase: the first n inputPhrase in the n+1-gram dict
    # ie: inputPhrase = america; n+1-gram = dict2; predicted_word = "and"
    
    # 1. filter the dictionary with the first input inputPhrase
    # convert input to lowercase
    inputPhrase <- tolower(inputPhrase)
    
    inputPhraseMatches <- dict4[ngram %like% paste("^", inputPhrase, " ", sep = ""), ]
    
    if (nrow(inputPhraseMatches) > 0){
        head( inputPhraseMatches %>% arrange(desc(count)), 4)
    } else {
        inputTerms <- unlist(strsplit(inputPhrase, " "))
        
        # get the n-1 gram and lookup in n-1 gram table
        nextGram <- paste(inputTerms[-1], collapse = " ")
        print(paste("no matches in 4-gram. searching 3-gram:", nextGram))
        # dict3
        inputPhraseMatches <- dict3[ngram %like% paste("^", nextGram, " ", sep = ""), ]
        if (nrow(inputPhraseMatches) > 0){
            head( inputPhraseMatches %>% arrange(desc(count)), 4)
        } else {
            # get the n-1 gram and lookup in n-1 gram table
            inputTerms <- unlist(strsplit(nextGram, " "))
            nextGram <- paste(inputTerms[-1], collapse = " ")
            print(paste("no matches in 3-gram. searching 2-gram:", nextGram))
            # dict2
            inputPhraseMatches <- dict2[ngram %like% paste("^", nextGram, " ", sep = ""), ]
            if (nrow(inputPhraseMatches) > 0){
                head( inputPhraseMatches %>% arrange(desc(count)), 4)
            } else { print(paste("no matches in 2-gram:", nextGram,". End"))  }   
           
        }
        
    }
}

predictWord("of Adam Sandler's")






