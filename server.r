library(plyr)
library(dplyr)
library(DT)

server <- function(input, output, session){
  
  s <- reactiveValues(dataReady = "Data not reaedy...")
  
  blastresults <- eventReactive(input$blast, {
    
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
    system(paste0("./blat ./data/lytechinus_pictus_30Nov2018_OWxax.fasta ",tmp," -out=blast8 ",tmp,".txt"), intern = T)
    blat_table <- read.table(file = paste0(tmp,'.txt'),sep = '\t', quote="", skip=5)
    colnames(blat_table) = c("Query","Target","%ID","alignment length","mismatches","gap openings","query start","query end","subject start","subject end","e-value","bit score")
    return(blat_table)
  }, ignoreNULL= T)

  #makes the datatable
  output$blastResults <- renderDataTable({
    if (is.null(blastresults())){
    } else {
      blastresults()
    }
  }, selection="single")

  observeEvent(input$blast, {
    s$prepareData = "Data not reaedy..."
  })
  
  psl <- eventReactive(input$export, {
    
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
    system(paste0("./blat ./data/lytechinus_pictus.2bit ",tmp," -out=psl ",tmp,".psl"), intern = T)

    ## Here we're returning just the file path  
    return(paste0(tmp,".psl"))
  }, ignoreNULL= T)
  
  observeEvent(!is.null(psl()), {
    s$dataReady = "Download data below:"
  })
  
  output$dataReady <- renderText(s$dataReady)
  
  output$downloadTxt <- downloadHandler(
    filename = function() {
      paste("lol.txt", sep = "")
    },
    content = function(file) {
      write.table(blastresults(), file, row.names = FALSE)
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
