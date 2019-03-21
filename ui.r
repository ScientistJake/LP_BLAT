library(shinythemes)
library(DT)
library(shinyjs)

ui <- navbarPage(
  id = "navbar",
  selected = 'home',
  header = tagList(
    tags$head(
      tags$link(rel="stylesheet", type="text/css",href="style.css"),
      tags$script(type="text/javascript", src = "busy.js")
    )
  ),
  theme = shinytheme("cerulean"),
  title="LP-BLAT",
  tabPanel("BLAT",value = "home",
    #This block gives us all the inputs:
    mainPanel(
      headerPanel('LP BLAT!'),
      textAreaInput('query', 'Input sequence:', value = "", placeholder = "", width = "600px", height="200px"),
      actionButton("blast", "BLAT!")
    ),
                
    #this snippet generates a progress indicator for long BLASTs
    div(class = "busy",  
      p("Calculation in progress.."), 
      img(src="happyurchin.gif", align = "center")
    ),
                
    #Basic results output
    mainPanel(
      h4("Results"),
      DT::dataTableOutput("blastResults"),
      br(),
      p("Download txt here:"),
      downloadButton("downloadTxt", "Download txt"),                 
      br(),
      br(),
      p("Download psl here:"),
      br(),

      downloadButton("downloadPsl", "Download psl")
      
    )
  ),
  tabPanel("About",value = "about",
    h3("About:"),
    p("LP BLAT is a BLAT wrapper for the Lytechinus pictus genome assembly sequenced and assembled by the Lyons lab at the Scripps Institute of Oceanography."),
    h3("Usage:"),
    p("Paste a sequence or several in fasta format in the entry box and click BLAT. 
      The alignment is slow so be patient. Once completed a table displaying the alignments will generate. 
      You can download this table by clicking the 'Download txt' button.
      To download a psl file that can be directly loaded into IGV, click Export psl ONLY ONCE. It will build the psl file and generate a download button upon completion."
    ),
    h3("Bugs:"),
    p("Report bugs to: warnerj atsymbol uncw.edu")
  )  
)
