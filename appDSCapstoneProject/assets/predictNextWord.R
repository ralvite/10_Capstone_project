library(stringr)
library(data.table)

dict2 <- readRDS(file="./data/dict2Data.rds")
dict3 <- readRDS(file="./data/dict3Data.rds")

##########################################################################################################
# This function is used to get the probability of a given text, using Katz Backoff (with Good-Turing Discounting).
# Only consider the last 3 words.
# Input1: I want to sleep
# Output1: 0.04536
# Input2: I want to go
# Output2: 0.4323
# Thus, input2 has more chance to appear than input1. Statistically, it is more relevant to people.
getPredictWordFrom3Gram = function(inputString){
    # Preprocessing
    # mylist = separateTerms(getLastTerms(inputString, num = 3))
    # inFirstTerms3gram = mylist$firstTerms
    # inLastTerm3gram = mylist$lastTerm
    inFirstTerms3gram = getLastTerms(inputString, num = 2)
    
    oneGroupIn3Gram = dict3[firstTerms == inFirstTerms3gram]
    
    if (nrow(oneGroupIn3Gram) > 0){
        # Algorithm here
        oneRecordIn3Gram = dict3[firstTerms == inFirstTerms3gram]
        if (nrow(oneRecordIn3Gram) > 0){
            # We found one or more in 3-gram
            # get the next terms (lastTerm column of 3-gram with highest probability "-count")
            nextWord = as.character(head(oneGroupIn3Gram[order(-count),lastTerm],5))
            nextWord
            
            ### We're done!
        }
    } else {
        
        inFirstTerms2gram = getLastTerms(inputString, num = 1)
        oneGroupIn2Gram = dict2[firstTerms == inFirstTerms2gram]
        if (nrow(oneGroupIn2Gram) > 0){
            # Algorithm here
            oneRecordIn2Gram = dict2[firstTerms == inFirstTerms2gram]
            if (nrow(oneRecordIn2Gram) > 0){
                # We found one or more in 3-gram
                # get the next terms (lastTerm column of 3-gram with highest probability "-count")
                nextWord = as.character(head(oneGroupIn2Gram[order(-count),lastTerm],5))
                nextWord
                
                ### We're done!
            }
        } else {
            stop(sprintf("No options available"))      
        }
        
        
    }
    
    
}


##########################################################################################################
# This function is used to extract terms.
# Input: "A_B_C"
#        "X_Y_Z"
# Output: firstTerms  lastTerm
#         "A_B"       "C"
#         "X_Y"       "Z"
separateTerms = function(x){
  # Pre-allocate
  firstTerms = character(length(x))
  lastTerm = character(length(x))
  
  for(i in 1:length(x)){
    posOfSpaces = gregexpr(" ", x[i])[[1]]
    posOfLastSpace = posOfSpaces[length(posOfSpaces)]
    firstTerms[i] = substr(x[i], 1, posOfLastSpace-1)
    lastTerm[i] = substr(x[i], posOfLastSpace+1, nchar(x[i]))
  }
  
  list(firstTerms=firstTerms, lastTerm=lastTerm)
}


##########################################################################################################
# This function is used to get the last "num" terms of a given text.
# Input: We are students of the university
# Output: of_the_university (if num = 3)
getLastTerms = function(inputString, num = 3){
  # Preprocessing
  inputString = gsub("[[:space:]]+", " ", str_trim(tolower(inputString)))
  
  # Now, ready!
  words = unlist(strsplit(inputString, " "))
  
  if (length(words) < num){
    stop("Number of Last Terms: Insufficient!")
  }
  
  from = length(words)-num+1
  to = length(words)
  tempWords = words[from:to]
  
  paste(tempWords, collapse=" ")
}



