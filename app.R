library(shiny)
library(readxl)
library(openxlsx)

#Input for 
#1) Banner template file, 1 per component
#2) User's marksheet, could have multiple columns but requires
#student ID and at least one column of scores under the same header as the course component as listed under Banner
#3) Course component id as it appears on banner

ui <- fluidPage(
  titlePanel("Generate Autofilled Banner Import Templates for Mark Upload"),
  strong("1. Upload the template file for the course component as exported from Banner. This file should be in the .xlsx format."),
  fileInput("bannerTemplate", NULL, buttonLabel = "Banner Template Sheet...", accept = c(".xlsx", ".xls")),
  strong("2. Upload your marksheet. Download this sheet from Moodle."),
  br(),
  em("IMPORTANT: Don't Change anything in the downloaded sheet except the headers for the CW scores, that match their component name on Banner (eg. CWS2WEEk6)."),
  br(),
  em("I also assume the marks are out of 100 (or a percent) for each component.  Save the file as .xlsx"),
  fileInput("scoreSheet", NULL, buttonLabel = "Your Marksheet...", accept = c(".xlsx", ".xls")),
  br(),
  uiOutput("u_selector"),
  br(),
  strong("4. Download the file using the button below. This file should be able to be imported into Banner as is!!!"),
  downloadButton("download1", label = "4. Download your .xlxs file")
)


server <- function(input, output, session) {
  
  marksheet <- reactive({
    if(is.null(input$scoreSheet))
      return(NULL)
      ss <- read_excel(input$scoreSheet$datapath, 1, na=c("-",""))
  })
  
  #selecting score columns from Marksheet 
  output$u_selector <- renderUI({
    df_local <- req(marksheet())
    selectInput("user_selected","3. Select the column (from your marksheet) containing scores for this component:",
                choices=names(df_local),
                selected = names(df_local)[[1]])
  })
  

  dataset <- reactive({
    if(is.null(input$bannerTemplate))
      return(NULL)
    bt <-read_excel(input$bannerTemplate$datapath, 1 )
    CWComp = req(input$user_selected)
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
  
  #Download file
  output$download1 <- downloadHandler(
    filename = function() {
      paste0(basename(input$bannerTemplate$name))
    },
    content = function(file) {
      write.xlsx(dataset(), file)
    })

}
shinyApp(ui, server)