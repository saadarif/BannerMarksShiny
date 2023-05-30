library(shiny)
library(shinyFeedback)
library(readxl)
library(openxlsx)

#Input for 
#1) Banner template file, 1 per component
#2) User's marksheet, could have multiple columns but requires
#student ID and at least one column of scores under the same header as the course component as listed under Banner
#3) Course component id as it appears on banner

ui <- fluidPage(
  shinyFeedback::useShinyFeedback(),
  titlePanel("Generate Autofilled Banner Import Templates for Mark Upload"),
  strong("1. Upload the template file for the course component as exported from Banner. This file should be in the .xlsx format."),
  fileInput("bannerTemplate", NULL, buttonLabel = "Banner Template Sheet...", accept = c(".xlsx", ".xls")),
  strong("2. Upload your marksheet. Download this sheet from Moodle or use that as a template to enter your marks"),
  br(),
  em("IMPORTANT: the columns with component scores should be values only, formulas might also work - but you should verify this"),
  br(),
  em("I also assume the marks are out of 100 (or are a percentage) for each component.  Save the file as .xlsx"),
  fileInput("scoreSheet", NULL, buttonLabel = "Your Marksheet...", accept = c(".xlsx", ".xls")),
  br(),
  uiOutput("u_selector"),
  br(),
  strong("4. Download the file using the button below. This file should be able to be imported into Banner as is!!!"),
  br(),
  downloadButton("download1", label = "4. Download your .xlxs file")
)


server <- function(input, output, session) {
  
  #read in marksheet
  marksheet <- reactive({
    if(is.null(input$scoreSheet))
      return(NULL)
    ss <- read_excel(input$scoreSheet$datapath, 1, na=c("-",""))
    #check if Username column exists, this should be the name of the column containing student IDS
    id_col= "Username" %in% colnames(ss)
    shinyFeedback::feedbackWarning("scoreSheet", !id_col, "Make sure your marksheet has a column called 'Username' containing student IDS!")
    req(id_col)
    ss
  })
  
  #selecting score columns from Marksheet 
  output$u_selector <- renderUI({
    ms_local <- req(marksheet())
    selectInput("user_selected","3. Select the column (from your marksheet) containing scores for this component:",
                choices=names(ms_local),
                selected = names(ms_local)[[1]])
  })
  
  #read in and update banner template
  dataset <- reactive({
    if(is.null(input$bannerTemplate))
      return(NULL)
    bt <-read_excel(input$bannerTemplate$datapath, 1 )
    CWComp = req(input$user_selected)
    #TODO:
    #Validate that CWComp column is numeric
    for(id in marksheet()$Username) {
      if(!(is.na(marksheet()[[CWComp]][marksheet()["Username"] == id]))) {
        bt$Score[bt["Student ID"] == id] = round(marksheet()[[CWComp]][marksheet()["Username"] == id],digits=1)
      }
      else{
      bt$Score[bt["Student ID"] == id] = 0
      bt$Comment[bt["Student ID"] == id] = "Not Attempted"
      }
    }
    bt$`Grade Change Reason` = "OE"
    bt
  })
  
  #Download file for upload to banner
  output$download1 <- downloadHandler(
    filename = function() {
      paste0(basename(input$bannerTemplate$name))
    },
    content = function(file) {
      write.xlsx(dataset(), file)
    })

}
shinyApp(ui, server)