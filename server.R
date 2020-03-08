

# Max upload size
options(shiny.maxRequestSize = 600*1024^2)
# Define server 

server <- function(input, output, session) {
  
  source("server-inputdata.R",local = TRUE)
  
  source("server-conditions.R",local = TRUE)
  
  source("server-svaseq.R",local = TRUE)
  
  source("server-runDeseq.R",local = TRUE)
  
  source("server-analysisRes.R",local = TRUE)
  
  source("server-boxplot.R",local = TRUE)
  
  source("server-heatmap.R",local = TRUE)
  
  GotoTab <- function(name){
    
    shinyjs::show(selector = paste0("a[data-value=\"",name,"\"]"))
    
    shinyjs::runjs("window.scrollTo(0, 0)")
  }
}


