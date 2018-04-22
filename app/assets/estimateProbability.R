library(stringr)
library(data.table)
# 
# Assumption: The 3-gram model is considered as main model with support of 2-gram and 1-gram models. 
# The estimate takes two forms depending if counts(w_(i-1),w_i) == 0 or not
# Reference: Columbia NLP Course at https://www.youtube.com/playlist?list=PL0ap34RKaADMjqjdSkWolD-W2VSCyRUQC

# These following are the 3-gram, 2-gram and 1-gram tables. The "discount" column is of Good-Turing Discounting.
# Katz suggested that in practice, frequencies being larger than 5 are "reliable enough", so their discount factors remain "1"; otherwise, they should be within (0,1).
# The "count" column is of "true frequency" in the corpus. For example, "a_a_a" appears 14 times in the corpus.
# The "discount" column is also known as "Discounting factor" or "Discounting coefficient".

#  dic3 (3-gram)
# firstTerms lastTerm count  discount
# 1:        a a        a     3 0.6477603
# 2:        a a  beaming     1 0.1484109
# 3:        a a  bowling     1 0.1484109
# 4:        a a checkout     1 0.1484109
# 5:        a a   cherry     1 0.1484109
# 6:        a a  company     1 0.1484109

#  dict2 (2-gram)
# firstTerms  lastTerm count  discount
# 1:          a         a    62 1.0000000
# 2:          a       aau     1 0.2995095
# 3:          a     about     3 0.7310986
# 4:          a     above     1 0.2995095
# 5:          a abundance     1 0.2995095
# 6:          a  abundant     1 0.2995095

# dict1 (1-gram)
# 1:                                                                    aa    71 1.000000
# 2:                                                                   aaa    51 1.000000
# 3:                                                             aaaaaaaaa     1 0.517224
# 4:     aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaahhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh     1 0.517224
# 5: aaaaaaaaaaaaaaaaaiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiaaaaaaaaaaaaaaeee     1 0.517224
# 6:                                                     aaaaaaaaaasdlghlk     1 0.517224

# we also have a table with the Left-over Probability reserved to share among the "unseen" words.
# head(dict3_leftOverProb)
# firstTerms leftoverprob
# 1:         a a    0.7221353
# 2:       a aau    0.8515891
# 3:     a about    0.8515891
# 4:     a above    0.8515891
# 5: a abundance    0.8515891
# 6:  a abundant    0.8515891

##########################################################################################################
# This function is used to get the probability of a given text, using Katz Backoff (with Good-Turing Discounting).
# Only consider the last 3 words.
# Input1: I want to sleep
# Output1: 0.04536
# Input2: I want to go
# Output2: 0.4323
# Thus, input2 has more chance to appear than input1. Statistically, it is more relevant to people.
getProbabilityFrom3Gram = function(inputString){
    # Preprocessing
    mylist = separateTerms(getLastTerms(inputString, num = 3))
    inFirstTerms3gram = mylist$firstTerms
    inLastTerm3gram = mylist$lastTerm
    
    finalProb = -1
    
    oneGroupIn3Gram = dict3[firstTerms == inFirstTerms3gram]
    
    if (nrow(oneGroupIn3Gram) > 0){
        # Algorithm here
        oneRecordIn3Gram = dict3[firstTerms == inFirstTerms3gram & lastTerm == inLastTerm3gram]
        if (nrow(oneRecordIn3Gram) > 0){
            # We found one in 3-gram
            all_freq = sum(oneGroupIn3Gram$count)
            finalProb = ((oneRecordIn3Gram$discount * oneRecordIn3Gram$count) / all_freq)
            ### We're done!
        } else {
            # NOT found in 3-gram => check 2-gram & 1-gram
            mylist = separateTerms(getLastTerms(inputString, num = 2))
            inFirstTerms2gram = mylist$firstTerms
            inLastTerm2gram = mylist$lastTerm
            
            # Get the left-over probability so that we can distribute it for lower-order grams.
            beta_leftoverprob = dict3_leftOverProb[firstTerms == inFirstTerms3gram]$leftoverprob
            
            oneGroupIn2Gram = dict2[firstTerms == inFirstTerms2gram]
            oneRecordIn2Gram = dict2[firstTerms == inFirstTerms2gram & lastTerm == inLastTerm2gram]
            if (nrow(oneRecordIn2Gram) > 0){
                # We found one in 2-gram!
                # We only consider ones that do not appear in 3-grams...
                oneGroupIn2Gram_Remain = oneGroupIn2Gram[!(oneGroupIn2Gram$lastTerm %in% oneGroupIn3Gram$lastTerm)]
                all_freq = sum(oneGroupIn2Gram$count)
                
                alpha = beta_leftoverprob / sum((oneGroupIn2Gram_Remain$count * oneGroupIn2Gram_Remain$discount) / all_freq)
                
                finalProb = alpha * ((oneRecordIn2Gram$count * oneRecordIn2Gram$discount ) / all_freq)
                ### We're done!
            } else {
                # We only have hope in 1-gram!
                oneGroupIn1Gram = dict1 # we don't have "firstTerms" here!
                oneRecordIn1Gram = dict1[lastTerm == inLastTerm2gram] # what if this returns "zero" row?
                
                oneGroupIn1Gram_Remain = oneGroupIn1Gram[!(oneGroupIn1Gram$lastTerm %in% oneGroupIn3Gram$lastTerm)]
                all_freq = sum(oneGroupIn1Gram$count)
                
                alpha = beta_leftoverprob / sum((oneGroupIn1Gram_Remain$count * oneGroupIn1Gram_Remain$discount) / all_freq)
                
                finalProb = alpha * ((oneRecordIn1Gram$count * oneRecordIn1Gram$discount) / all_freq)
                ### We're done!
            }
        }
    } else {
        stop(sprintf("[%s] not found in the 3-gram model.", inFirstTerms3gram))
        # The workaround could be:
        # + Write another function in which we primarily use 2-gram with support from 1-gram.
        # + Increase the corpus size so that the 3-gram can capture more diversity of words...
    }
    
    finalProb
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