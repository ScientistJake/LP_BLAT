library(plyr)
library(dplyr)
library(DT)

server <- function(input, output, session){
  
  s <- reactiveValues(dataReady = "Data not reaedy...")
  
  psl <- eventReactive(input$blast, {
    
    #gather input and set up temp file
    query <- input$query
    tmp <- tempfile(fileext = ".fa")

    #this makes sure the fasta is formatted properly
    if (startsWith(query, ">")){
      writeLines(query, tmp)
    } else {
      writeLines(paste0(">Query\n",query), tmp)
    }
    
    #calls the blast
    system(paste0("./blat ./data/lytechinus_pictus.2bit ",tmp," ",tmp,".psl"), intern = T)
    return(paste0(tmp,".psl"))
  }, ignoreNULL= T)
  
  blat_results <-reactive({
    system(paste0("perl pslScore.pl ",psl()," > ",psl(),".scored"), intern = T)
    blat_table <- read.table(file = paste0(psl(),'.scored'),sep = '\t', quote="", skip=5)
    colnames(blat_table) = c("Target","Target_start","Target_end","Query","score","percent Identity")
    return(blat_table)
  })

  #makes the datatable
  output$blastResults <- renderDataTable({
    if (is.null(blat_results())){
    } else {
      blat_results()
    }
  }, selection="single")
  
  output$downloadTxt <- downloadHandler(
    filename = function() {
      paste("lol.txt", sep = "")
    },
    content = function(file) {
      write.table(blat_results(), file, row.names = FALSE, sep='\t', quote=FALSE)
    }
  )
    
  output$downloadPsl <- downloadHandler(
    filename = function() {
      paste("lol.psl", sep = "")
    },
    content = function(file) {
      file.copy(psl(), file)
    }
  )
}
