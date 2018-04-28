suppressPackageStartupMessages(c(
  library(shinythemes),
  library(shiny),
  library(tm),
  library(stringr),
  library(markdown)
  # library(stylo)
  ))

source("./assets/predictNextWord.R")


shinyServer(function(input, output) {
    num = 2 # minimum number of words typed
    wordPrediction <- reactive({
        
        textInput <- input$text
        # textInput <- cleanInput(text)
        # wordCount <- length(textInput)
        words = unlist(strsplit(textInput, " "))
        
        if (length(words) < num){
            wordPrediction <- c("","") # empty options to build the selectInput
        } else {
            wordPrediction <- getPredictWordFrom3Gram(textInput)
        }
        
    })
    
    output$predictedWords <- renderUI({
    
      selectInput(inputId = "next-words", label = "", choices = as.list(wordPrediction()))
    })
  
})
