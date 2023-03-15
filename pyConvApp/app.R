

#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
library(RColorBrewer)
library(reticulate)

reticulate::py_install("pandas")
reticulate::source_python("data_cleaning.py")

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # App title ----
    #h1("Uploading Data")
    #h1("Uploading Data", href="https://github.com/futres/RShinyFuTRES/blob/main/README.md"),
    #tags$a(href="https://github.com/futres/RShinyFuTRES/blob/main/README.md",
           #"Uploading Data"),
    
    titlePanel(tags$h1(
        tags$a("Data Cleaning",href="https://github.com/futres/RShinyFuTRES/blob/main/README.md")
    )
    ),
    # Sidebar layout with input and output definitions ----
    sidebarLayout(
        # Sidebar panel for inputs ----
        sidebarPanel(id = "tPanel",style = "overflow-y:scroll; max-height: 90vh; position:relative;",
            
            # Input: Select a file ----
            fileInput("file1", "Choose CSV File",
                      multiple = FALSE,
                      accept = c("text/csv",
                                 "text/comma-separated-values,text/plain",
                                 ".csv")),
            
            # Horizontal line ----
            tags$hr(),
            
            # Input: Select number of rows to display ----
            radioButtons("disp", "Display",
                         choices = c(Head = "head",
                                     All = "all"),
                         selected = "head"),
            
            tags$hr(),
            ## Column Check function, makes sure that
            ## column names in the csv match those of
            ## the FuTRES template
            radioButtons("cc", "Check your columns: this compares your columns to the template",
                         choices = c(No = "cc_no",
                                     Yes = "cc_yes"),
                         selected = "cc_no"),
            
            ## Asks user if they want to check
            ## if all of the countries in the data
            ## are accepted by FuTRES
            radioButtons("cv", "Check country terms",
                         choices = c(No = "cv_no",
                                     Yes = "cv_yes"),
                         selected = "cv_no"),
            ## Asks user if they want to melt the 
            ## quantitative values in their
            ## data
            radioButtons("melt", "Do you need to transform the dataset so that there is one measurement per row?",
                         choices = c(No = "melt_no",
                                     Yes = "melt_yes"),
                         selected = "melt_no"),
            conditionalPanel(
                condition = "input.melt == 'melt_yes'",
                checkboxGroupInput("dm_cols",
                                   "Temp Checkbox",
                                   c("label 1" = "option1",
                                     "label 2" = "option2"))
            ),
            radioButtons("license", "Do you need to add a license to your dataset?",
                         choices = c(No = "license_no",
                                     Yes = "license_yes"),
                         selected = "license_no"),
            ## if user selects yes above
            ## program asks user for their
            ## current weight and length
            ## values
            conditionalPanel(
                condition = "input.license == 'license_yes'",
                radioButtons("choice", "license Options",
                             choices = c(CC0 = "CC0",
                                         CCBY = "CCBY",
                                         BSD = "BSD"),
                             selected = "CC0")
            ),
            radioButtons("dp", "Would you like to convert your unrecognized columns to dynamicProperties",
                         choices = c(No = "dp_no",
                                     Yes = "dp_yes"),
                         selected = "dp_no"),
            
            downloadButton("download", "Download Cleaned CSV")
        ),
        
        
        
        
        mainPanel(
            h4(strong(span(textOutput("text0"), style="color:#FF33FF"))),
            h4(strong(span(textOutput("text4"), style="color:#FF33FF"))),
            verbatimTextOutput("text"),
            verbatimTextOutput("countryText"),
            verbatimTextOutput("mstUnaccepted"),
            verbatimTextOutput("warning_auto_del"),
            titlePanel("Data Pre-cleaning"),
            tableOutput("contents"),
            titlePanel("Data After Cleaning"),
            tableOutput("clean_data")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output,session) {
  options(shiny.maxRequestSize=30*1024^2) 
    
    output$contents <- renderTable({
        
        # input$file1 will be NULL initially. After the user selects
        # and uploads a file, head of that data file by default,
        # or all rows if selected, will be shown.
        
        req(input$file1)
        
        df <- open_df(input$file1$datapath)
    
        
        if(input$disp == "head") {
            return(head(df))
        }
        else {
            return(df)
        }
    })
    
    clean_data_reac <- shiny::reactive({
        req(input$file1)
        df <- open_df(input$file1$datapath)
        
        if (input$melt == "melt_yes"){
            if (length(input$dm_cols) >= 2){
                arr = c(input$dm_cols)
                df <- dataMelt(df,arr)
                df <- noMeasurementsPostMelt(df)
            }
        }
        
        if(input$license == "license_yes"){
            df <- license(df,input$choice)
        }
        ##----------------------------------------------------------------------
        
        ##df <- measurementUnits(df)
        df <- remove_rcna(df)
        
        if(input$dp == "dp_yes"){
          df <- dynamicProperties(df)  
        }
        df <- diagnosticId(df)
        
        ##----------------------------------------------------------------------
        
        if(input$disp == "head") {
            return(head(df))
        }
        else {
            return(df)
        }
    })
    
    output$clean_data <- renderTable(clean_data_reac())
    
    output$text <- renderPrint({
        req(input$file1)
        df <- open_df(input$file1$datapath)
        if (input$cc == "cc_yes"){
            cat(colcheck(df))
        }
    })
    
    output$countryText <- renderPrint({
        req(input$file1)
        df <- open_df(input$file1$datapath)
        if (input$cv == "cv_yes" & "country" %in% names(df)){
            cat(countryValidity(df))
        }
    })
    
    output$mstUnaccepted <- renderPrint({
      req(input$file1)
      df <- open_df(input$file1$datapath)
      cat(matSampTypeUnmatched(df))
    })
    
    warning_text_cc <- reactive({
      if (input$cc == "cc_yes"){
        paste("Please ensure that all of your column names are spelled correctly and in snakeCase")
      }
    })
    
    warning_text_cv <- reactive({
        req(input$file1)
        df <- open_df(input$file1$datapath)
        if (input$cv == "cv_yes" & isFALSE("country" %in% names(df))){
          paste("WARNING: The selected function cannot be applied because you do not have a column named country.")
        }
    })
    
    output$warning_auto_del <- renderPrint({
      req(input$file1)
      df <- open_df(input$file1$datapath)
      cat(dropped_cols(df))
    })

    output$text0 <- renderText(warning_text_cc())
    output$text4 <- renderText(warning_text_cv())
    
    output$download <-
      downloadHandler(
        filename = function () {
          paste("cleanData.csv", sep = "")
        },
        content = function(file) {
          ##apply(df,2,as.character)
          write.csv(apply(clean_data_reac(),2,as.character), file, row.names=FALSE)
        }
      )
}

# Run the application 
shinyApp(ui, server)
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
library(RColorBrewer)
library(reticulate)

reticulate::py_install("pandas")
reticulate::source_python("data_cleaning.py")

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # App title ----
  #h1("Uploading Data")
  #h1("Uploading Data", href="https://github.com/futres/RShinyFuTRES/blob/main/README.md"),
  #tags$a(href="https://github.com/futres/RShinyFuTRES/blob/main/README.md",
  #"Uploading Data"),
  
  titlePanel(tags$h1(
    tags$a("Data Cleaning",href="https://github.com/futres/RShinyFuTRES/blob/main/README.md")
  )
  ),
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    # Sidebar panel for inputs ----
    sidebarPanel(id = "tPanel",style = "overflow-y:scroll; max-height: 90vh; position:relative;",
                 
                 # Input: Select a file ----
                 fileInput("file1", "Choose CSV File",
                           multiple = FALSE,
                           accept = c("text/csv",
                                      "text/comma-separated-values,text/plain",
                                      ".csv")),
                 
                 # Horizontal line ----
                 tags$hr(),
                 
                 # Input: Select number of rows to display ----
                 radioButtons("disp", "Display",
                              choices = c(Head = "head",
                                          All = "all"),
                              selected = "head"),
                 
                 tags$hr(),
                 ## Column Check function, makes sure that
                 ## column names in the csv match those of
                 ## the FuTRES template
                 radioButtons("cc", "Check your columns: this compares your columns to the template",
                              choices = c(No = "cc_no",
                                          Yes = "cc_yes"),
                              selected = "cc_no"),
                 
                 ## Asks user if they want to check
                 ## if all of the countries in the data
                 ## are accepted by FuTRES
                 radioButtons("cv", "Check country terms",
                              choices = c(No = "cv_no",
                                          Yes = "cv_yes"),
                              selected = "cv_no"),
                 ## Asks user if they want to melt the 
                 ## quantitative values in their
                 ## data
                 radioButtons("melt", "Do you need to transform the dataset so that there is one measurement per row?",
                              choices = c(No = "melt_no",
                                          Yes = "melt_yes"),
                              selected = "melt_no"),
                 conditionalPanel(
                   condition = "input.melt == 'melt_yes'",
                   checkboxGroupInput("dm_cols",
                                      "Temp Checkbox",
                                      c("label 1" = "option1",
                                        "label 2" = "option2"))
                 ),
                 radioButtons("license", "Do you need to add a license to your dataset?",
                              choices = c(No = "license_no",
                                          Yes = "license_yes"),
                              selected = "license_no"),
                 ## if user selects yes above
                 ## program asks user for their
                 ## current weight and length
                 ## values
                 conditionalPanel(
                   condition = "input.license == 'license_yes'",
                   radioButtons("choice", "license Options",
                                choices = c(CC0 = "CC0",
                                            CCBY = "CCBY",
                                            BSD = "BSD"),
                                selected = "CC0")
                 ),
                 radioButtons("dp", "Would you like to convert your unrecognized columns to dynamicProperties",
                              choices = c(No = "dp_no",
                                          Yes = "dp_yes"),
                              selected = "dp_no"),
                 
                 downloadButton("download", "Download Cleaned CSV")
    ),
    
    
    
    
    mainPanel(
      h4(strong(span(textOutput("text6"), style="color:#FF33FF"))),
      h4(strong(span(textOutput("text0"), style="color:#FF33FF"))),
      h4(strong(span(textOutput("text4"), style="color:#FF33FF"))),
      verbatimTextOutput("text"),
      verbatimTextOutput("countryText"),
      verbatimTextOutput("mstUnaccepted"),
      verbatimTextOutput("warning_auto_del"),
      titlePanel("Data Pre-cleaning"),
      tableOutput("contents"),
      titlePanel("Data After Cleaning"),
      tableOutput("clean_data")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output,session) {
  options(shiny.maxRequestSize=30*1024^2) 
  
  output$contents <- renderTable({
    
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, head of that data file by default,
    # or all rows if selected, will be shown.
    
    req(input$file1)
    
    df <- open_df(input$file1$datapath)
    
    
    if(input$disp == "head") {
      return(head(df))
    }
    else {
      return(df)
    }
  })
  
  dataDownload <- reactive({
    req(input$file1)
    df <- open_df(input$file1$datapath)
    
    if (input$melt == "melt_yes"){
      if (length(input$dm_cols) >= 2){
        arr = c(input$dm_cols)
        df <- dataMelt(df,arr)
        df <- noMeasurementsPostMelt(df)
      }
    }
    
    if(input$license == "license_yes"){
      df <- license(df,input$choice)
    }
    ##----------------------------------------------------------------------
    
    ##df <- measurementUnits(df)
    df <- remove_rcna(df)
    
    if(input$dp == "dp_yes"){
      df <- dynamicProperties(df)  
    }
    df <- diagnosticId(df)
    
    ##----------------------------------------------------------------------
    df <- apply(df,2,as.character)
    return(df)
  })
  
  output$clean_data <- renderTable({
    req(input$file1)
    df <- open_df(input$file1$datapath)
    
    if (input$melt == "melt_yes"){
      cat("test")
      if (length(input$dm_cols) >= 2){
        arr = c(input$dm_cols)
        df <- dataMelt(df,arr)
        df <- noMeasurementsPostMelt(df)
      }
    }
    
    if(input$license == "license_yes"){
      df <- license(df,input$choice)
    }
    ##----------------------------------------------------------------------
    
    ##df <- measurementUnits(df)
    df <- remove_rcna(df)
    
    if(input$dp == "dp_yes"){
      df <- dynamicProperties(df)  
    }
    df <- diagnosticId(df)
    df <- transform(df, diagnosticID = as.integer(diagnosticID))
    
    ##----------------------------------------------------------------------
    
    if(input$disp == "head") {
      return(head(df))
    }
    else {
      return(df)
    }
  })
  
  observe({
    req(input$file1)
    df <- open_df(input$file1$datapath)
    df_cols <- names(df)
    cols <- list()
    cols[df_cols] <- df_cols
    #print(cb_options)
    updateCheckboxGroupInput(session, "dm_cols",
                             label = "Select Measurements",
                             choices = cols,
                             selected = NULL)
  })
  
  output$text <- renderPrint({
    req(input$file1)
    df <- open_df(input$file1$datapath)
    if (input$cc == "cc_yes"){
      cat(colcheck(df))
    }
  })
  
  output$countryText <- renderPrint({
    req(input$file1)
    df <- open_df(input$file1$datapath)
    if (input$cv == "cv_yes" & "country" %in% names(df)){
      cat(countryValidity(df))
    }
  })
  
  output$mstUnaccepted <- renderPrint({
    req(input$file1)
    df <- open_df(input$file1$datapath)
    cat(matSampTypeUnmatched(df))
  })
  
  warning_text_cc <- reactive({
    if (input$cc == "cc_yes"){
      paste("Please ensure that all of your column names are spelled correctly and in snakeCase")
    }
  })
  
  warning_text_cv <- reactive({
    req(input$file1)
    df <- open_df(input$file1$datapath)
    if (input$cv == "cv_yes" & isFALSE("country" %in% names(df))){
      paste("WARNING: The selected function cannot be applied because you do not have a column named country.")
    }
  })
  
  warning_text_data_display <- reactive({
    paste("Values in decimalLatitude, decimalLongitude, and yearCollected may appear differently on the app but will appear similar to the original data file in the downloaded data")
  })
  
  output$warning_auto_del <- renderPrint({
    req(input$file1)
    df <- open_df(input$file1$datapath)
    cat(dropped_cols(df))
  })
  
  output$text0 <- renderText(warning_text_cc())
  output$text4 <- renderText(warning_text_cv())
  output$text6 <- renderText(warning_text_data_display())
  
  output$download <-
    downloadHandler(
      filename = function () {
        paste("cleanData.csv", sep = "")
      },
      content = function(file) {
        write.csv(dataDownload(), file, row.names = FALSE)
      }
    )
}

# Run the application 
shinyApp(ui, server)