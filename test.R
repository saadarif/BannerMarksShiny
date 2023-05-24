library(readxl)

BT <- read_excel("./TestData/202301_51175_1_CWS2WEEK12.xlsx")
scores <- read_excel("./TestData/BIOL5002 (2023011) Grades (1).xlsx", na=c("-",""))


for(id in scores$Username) {
  if(!(is.na(scores$`Turnitin Assignment 2: CW1 - Part 3 (Final) Literature Review on a Genomic Sequencing Assay (Real)`[scores$Username == id]))) {
    BT$Score[BT$`Student ID` == id]=scores$`Turnitin Assignment 2: CW1 - Part 3 (Final) Literature Review on a Genomic Sequencing Assay (Real)`[scores$Username == id]
  }
  else{
    BT$Score[BT$`Student ID` == id] = 0
    BT$Comment[BT$`Student ID` == id] = "Not Attempted"
  }
  BT$`Grade Change Reason` = "OE"
}

SS <- reactive({
  scoresSheet <- input$scoreSheet
  if(is.null(scores))
    return(NULL)
  read_excel(scoresSheet$datapath, 1, na=c("-",""))})

calc <- reactive({
  CW = as.character(input$CW)
  for(id in SS()$Username) {
    if(!(is.na(SS()$CW[SS()$Username == id]))) {
      BT()$Score[BT()$`Student ID` == id]=SS()$CW[SS()$Username == id]
    }
    else{
      BT()$Score[BT()$`Student ID` == id] = 0
      BT()$Comment[BT()$`Student ID` == id] = "Not Attempted"
    }
    BT()$`Grade Change Reason` = "OE"
  }
  BT
})

output$Btemp <- renderTable(calc())