

# Max upload size
options(shiny.maxRequestSize = 600*1024^2)
# Define server 

server <- function(input, output, session) {
  
  source("server-inputdata.R",local = TRUE)
  
  source("server-conditions.R",local = TRUE)
  
  source("server-runDeseq.R",local = TRUE)
  
  source("server-analysisRes.R",local = TRUE)
  
  source("server-boxplot.R",local = TRUE)
  
  source("server-heatmap.R",local = TRUE)
  
}


