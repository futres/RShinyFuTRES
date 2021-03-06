

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
            ## Verbatim Locality function
            radioButtons("verLoc", "create verbatimLocality column",
                         choices = c(No = "vl_no",
                                     Yes = "vl_yes"),
                         selected = "vl_no"),
            ## If user selects yes above, the app
            ## will present a drop down menu of 
            ## all of the column names for the
            ## user to select which columns will
            ## create verbatim locality
            conditionalPanel(
                condition = "input.verLoc == 'vl_yes'",
                checkboxGroupInput("verLoc_cols",
                                   "Temp Checkbox",
                                   c("label 1" = "option1",
                                     "label 2" = "option2"))
            ),
            ## Material Sample Type function, will
            ## only work with a materialSampleType
            ## column
            radioButtons("mst", "Standardize terms in materialSampleType (Whole organism, Part organism - whole element, Part organism - part element)",
                         choices = c(No = "mst_no",
                                     Yes = "mst_yes"),
                         selected = "mst_no"),
            conditionalPanel(
                condition = "input.mst == 'mst_yes'",
                ## Values to replace
                textInput("matSamp_check", "Values to check for(Seperate with commas)", value = "", width = NULL,
                          placeholder = NULL),
                ## Replacement values
                textInput("matSamp_replace", "Replacement Values(Seperate with commas)", value = "", width = NULL,
                          placeholder = NULL)
            ),
            ## Asks user if the values of Length
            ## and Weight columns 
            radioButtons("conv", "Do you need to convert your units to 'mm' and 'g'?",
                         choices = c(No = "conv_no",
                                     Yes = "conv_yes"),
                         selected = "conv_no"),
            ## if user selects yes above
            ## program asks user for their
            ## current weight and length
            ## values
            conditionalPanel(
                condition = "input.conv == 'conv_yes'",
                checkboxGroupInput("len_col",
                                   "Temp Checkbox",
                                   c("label 1" = "option1",
                                     "label 2" = "option2")),
                checkboxGroupInput("mass_col",
                                   "Temp Checkbox",
                                   c("label 1" = "option1",
                                     "label 2" = "option2")),
                radioButtons("len", "Current Length Values",
                             choices = c(Inches = "inches",
                                         Centimeters = "centimeters",
                                         Meters = "meters"),
                             selected = ),
                radioButtons("wght", "Current Mass Values",
                             choices = c(Pounds = "pounds",
                                         Kilograms = "kilograms",
                                         Milligrams = "milligrams"),
                             selected = 'pounds')
            ),
            ## Asks user if they want to
            ## standardize the sex column
            ## values
            radioButtons("s", "sex",
                         choices = c(No = "s_no",
                                     Yes = "s_yes"),
                         selected = "s_no"),
            ## Asks user if they want to
            ## add a year collected column
            radioButtons("yc", "Create yearCollected (Current date must be in yyyy-mm-dd format)",
                         choices = c(No = "yc_no",
                                     Yes = "yc_yes"),
                         selected = "yc_no"),
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
            
            downloadButton("download", "Download Cleaned CSV"),
        ),
        
        
        
        
        mainPanel(
            h4(strong(span(textOutput("text1"), style="color:#FF33FF"))),
            h4(strong(span(textOutput("text2"), style="color:#FF33FF"))),
            h4(strong(span(textOutput("text3"), style="color:#FF33FF"))),
            h4(strong(span(textOutput("text4"), style="color:#FF33FF"))),
            h4(strong(span(textOutput("text5"), style="color:#FF33FF"))),
            h4(strong(span(textOutput("text6"), style="color:#FF33FF"))),
            h4(strong(span(textOutput("text7"), style="color:#FF33FF"))),
            verbatimTextOutput("text"),
            titlePanel("Data Pre-cleaning"),
            tableOutput("contents"),
            titlePanel("Data After Cleaning"),
            tableOutput("clean_data")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output,session) {
    
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
    
    output$clean_data <- renderTable({
        req(input$file1)
        df <- open_df(input$file1$datapath)
        df <- remove_rcna(df)
        df <- dynamicProperties(df) 
        df <- individualID(df)
        #df <- add_ms_and_indivdID(df)
        ##----------------------------------------------------------------------
        if (input$verLoc == "vl_yes"){
            if (length(input$verLoc_cols) >= 2){
                arr = c(input$verLoc_cols)
                df <- verLocal(df,arr)
            }
            if (length(input$verLoc_cols) == 1){
                arr = c(input$verLoc_cols)
                df <- verLocal_oneCol(df,arr[1])
            }
        }
        ##----------------------------------------------------------------------
        if (input$s == "s_yes"){
            df <- sex(df)
        }
        ##----------------------------------------------------------------------
        if (input$yc == "yc_yes"){
            df <- yc(df)
        }
        ##----------------------------------------------------------------------
        if (input$conv == "conv_yes" & length(input$len_col) == 1) {
            arr_len = c(input$len_col)
            if (input$len == "inches") {
                df <- inConv(df,arr_len[1])
            }
            if (input$len == "centimeters") {
                df <- cmConv(df,arr_len[1])
            }
            if (input$len == "meters") {
                df <- mConv(df,arr_len[1])
            }
        }
        ##----------------------------------------------------------------------
        if (input$conv == "conv_yes" & length(input$mass_col) == 1) {
            arr_mass = c(input$mass_col)
            if (input$wght == "pounds") {
                df <- lbsConv(df,arr_mass[1])
            }
            if (input$wght == "milligrams") {
                df <- mgConv(df,arr_mass[1])
            }
            if (input$wght == "kilograms") {
                df <- kgConv(df,arr_mass[1])
            }
        }
        ##----------------------------------------------------------------------
        if (input$mst == "mst_yes" & "materialSampleType" %in% names(df)){
            check = strsplit(input$matSamp_check, ",")
            replace = strsplit(input$matSamp_replace, ",")
            matSamp_check <- unlist(strsplit(input$matSamp_check, ","))
            matSamp_replace <- unlist(strsplit(input$matSamp_replace, ",")) 
            df <- matSampType(df, check, replace)
            mst_dict <- mst_add(mst_dict,check,replace)
        }
        ##----------------------------------------------------------------------
        if (input$melt == "melt_yes"){
            if (length(input$dm_cols) >= 2){
                arr = c(input$dm_cols)
                df <- dataMelt(df,arr)
            }
        }
        
        if(input$license == "license_yes"){
            df <- license(df,input$choice)
        }
        ##----------------------------------------------------------------------
        output$download <-
            downloadHandler(
                filename = function () {
                    paste("cleanData.csv", sep = "")
                },
                content = function(file) {
                    write.csv(df, file, row.names = FALSE)
                }
            )
        ##----------------------------------------------------------------------
        
        df <- measurementUnits(df)
        
        df <- diagnosticId(df)
        
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
        df <- remove_rcna(df)
        df_cols <- names(df)
        cols <- list()
        cols[df_cols] <- df_cols
        #print(cb_options)
        updateCheckboxGroupInput(session, "verLoc_cols",
                                 label = "Select Desired Columns",
                                 choices = cols,
                                 selected = NULL)
        updateCheckboxGroupInput(session, "dm_cols",
                                 label = "Select Desired Columns",
                                 choices = cols,
                                 selected = NULL)
        updateCheckboxGroupInput(session, "len_col",
                                 label = "Select Length Column",
                                 choices = cols,
                                 selected = NULL)
        updateCheckboxGroupInput(session, "mass_col",
                                 label = "Select Mass Column",
                                 choices = cols,
                                 selected = NULL)
    })
    
    
    output$text <- renderPrint({
        req(input$file1)
        df <- open_df(input$file1$datapath)
        df <- remove_rcna(df)
        if (input$cc == "cc_yes"){
            cat(colcheck(df))
        }
        if (input$cv == "cv_yes" & "country" %in% names(df)){
            cat(countryValidity(df))
        }
    })
    
    warning_text_mst <- reactive({
        ifelse(input$mst == "mst_yes" & !("materialSampleType" %in% names(df)),
               'WARNING: No column named materialSampleType in data, Material Sample Type function cannot be applied',
               '') 
    })
    
    warning_text_cv <- reactive({
        ifelse(input$cv == "cv_yes" & !("country" %in% names(df)),
               'WARNING: No column named country in data, Country Validity function cannot be applied',
               '') 
    })
    
    warning_text_uc <- reactive({
        ifelse(input$conv == "conv_yes" ,
               'Please double check the units you have selected as your original length and mass',
               '')
    })
    
    warning_text_len_sel <- reactive({
        arr_len = c(input$len_col)
        if (input$conv == "conv_yes" & (length(input$len_col) == 1)){
            paste("You have selected your length to be: ", arr_len[1], " with original units in ",input$len )
        }
    })
    
    warning_text_mass_sel <- reactive({
        arr_mass = c(input$mass_col)
        if (input$conv == "conv_yes" & (length(input$mass_col) == 1)){
            paste("You have selected your mass to be: ", arr_mass[1], " with original units in ",input$wght)
        }
    })
    
    warning_text_len_mul_sel <- reactive({
        ifelse(input$conv == "conv_yes" & (length(input$len_col) > 1),
               'You have selected more than one length unit, please change this',
               '') 
    })
    
    warning_text_mass_mul_sel <- reactive({
        ifelse(input$conv == "conv_yes" & (length(input$mass_col) > 1),
               'You have selected more than one mass unit, please change this',
               '') 
    })
    
    #Render the text so that it is available in the UI
    output$text1 <- renderText(warning_text_mst()) 
    
    output$text2 <- renderText(warning_text_cv()) 
    
    output$text3 <- renderText(warning_text_uc()) 
    
    output$text4 <- renderText(warning_text_len_sel()) 
    
    output$text5 <- renderText(warning_text_mass_sel()) 
    
    output$text6 <- renderText(warning_text_len_mul_sel()) 
    
    output$text7 <- renderText(warning_text_mass_mul_sel()) 
    
    ##observeEvent(input$preview, {
        # Show a modal when the button is pressed
        ##shinyalert("Caution!", "Please confim that you wight and length columns are correctly selected and the current unit of measurements are accurate", type = "warning")
    ##})
    
    
    # output$download <-
    #     downloadHandler(
    #         filename = function () {
    #             paste("cleanData.csv", sep = "")
    #         },
    #         content = function(file) {
    #             write.csv(df, file)
    #         }
    #     )
}

# Run the application 
shinyApp(ui, server)
