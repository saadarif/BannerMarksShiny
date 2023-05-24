library(shiny)
library(readxl)
library(openxlsx)

#Input for 
#1) Banner template file, 1 per component
#2) User's marksheet, could have multiple columns but requires
#student ID and at least one column of scores under the same header as the course component as listed under Banner
#3) Course component id as it appears on banner
ui <- fluidPage(
  fileInput("bannerTemplate", NULL, buttonLabel = "Banner Template Sheet...", accept = ".xlsx"),
  fileInput("scoreSheet", NULL, buttonLabel = "Your Marksheet...", accept = ".xlsx"),
  textInput("CW", "Enter the course component code as it appears on Banner (and should be the same in your Marksheet)"),
  tableOutput("test")
)


server <- function(input, output, session) {
  
  BT <- reactive({
    bTemp <- input$bannerTemplate
    if(is.null(bTemp))
      return(NULL)
    read_excel(bTemp$datapath, 1)})
  
  SS <- reactive({
    scoresSheet <- input$scoreSheet
    if(is.null(scores))
      return(NULL)
    read_excel(scoresSheet$datapath, 1, na=c("-",""))})
  
  CW1 <- reactive({
    input$CW }) 
  
  calc <- reactive({
    BT()["Score"] = 0
  })
  
  output$test <- renderTable(calc())
}
shinyApp(ui, server)