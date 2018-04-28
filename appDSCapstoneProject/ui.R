# https://github.com/garciasebastian/DSCapstoneProject
suppressPackageStartupMessages(c(
  library(shinythemes),
  library(shiny),
  library(tm),
  library(stringr),
  library(markdown)
  # ,
  # library(stylo)
  ))

shinyUI(navbarPage("Coursera Data Science Capstone", 
                   
                   theme = shinytheme("journal"),
                   
                   tabPanel("Next Word Prediction",
                            
                            fluidRow(
                              
                              column(3),
                              column(6,
                                     tags$div(textInput("text", 
                                                        label = tags$span(style="color:grey",("Enter text:")),
                                                        value = ),
                                              tags$span(style="color:grey",("Predicted next words:")),
                                              br(),
                                              tags$span(style="color:darkred",
                                                        uiOutput("predictedWords")),
                                                        # tags$strong(tags$h3(textOutput("predictedWord")))),
                                              br(),
                                              # tags$hr(),
                                              # h4("What you have entered:"),
                                              tags$em(tags$h4(textOutput("warning"))),
                                              align="center")
                              ),
                              column(3)
                            )
                   ),
                   
                   
                   tabPanel("About This Application",
                            fluidRow(
                              column(2,
                                     p("")),
                              column(8,
                                     includeMarkdown("./www/about.md")),
                              column(2,
                                     p(""))
                            )
                   )
)
)
