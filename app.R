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
  strong("Workflow:"),
  textInput("CW", "1. Enter the course component code as it appears on Banner (and should be the same in your Marksheet)"),
  strong("2. Upload the template file for the course component as exported from Banner. This file should be in the .xlsx format."),
  fileInput("bannerTemplate", NULL, buttonLabel = "2. Banner Template Sheet...", accept = ".xlsx"),
  strong("3. Upload your marksheet. For now, the best thing is to download marks from moodle. Keep the downloaded sheet as is except change the headers for the scores to match their component name on Banner (eg. CWS2WEEk6)."),
  fileInput("scoreSheet", NULL, buttonLabel = "3. Your Marksheet...", accept = ".xlsx"),
  strong("Download the file using the button below. This file should be able to be imported into Banner as is!!!"),
  br(),
  downloadButton("download1", label = "4. Download your .xlxs file")
)


server <- function(input, output, session) {
  
  dataset <- reactive({
    req(input$CW)
    if(is.null(input$bannerTemplate))
      return(NULL)
    if(is.null(input$scoreSheet))
      return(NULL)
    bt <-read_excel(input$bannerTemplate$datapath, 1 )
    ss <- read_excel(input$scoreSheet$datapath, 1, na=c("-","", "0"))
    CWComp = as.name(input$CW)
    for(id in ss$Username) {
      if(!(is.na(ss[CWComp][ss["Username"] == id]))) {
        bt$Score[bt["Student ID"] == id] = round(ss[CWComp][ss["Username"] == id],digits=1)
      }
      else{
      bt$Score[bt["Student ID"] == id] = 0
      bt$Comment[bt["Student ID"] == id] = "Not Attempted"
      }
    }
    bt$`Grade Change Reason` = "OE"
    bt
  })
  
  
  output$download1 <- downloadHandler(
    filename = function() {
      paste0(basename(input$bannerTemplate$name))
    },
    content = function(file) {
      write.xlsx(dataset(), file)
    })

}
shinyApp(ui, server)