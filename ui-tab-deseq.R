tabItem(tabName = "deseqTab", 
        fluidRow(
          column(11,
                 h3("Run DESeq"),
                 
                 hr(),
                 wellPanel(
                   tabsetPanel(type = "tabs",
                               tabPanel("RLog",
                                        
                                        conditionalPanel("output.ddsComputed",
                                                         
                                                         box(title = "Distance Heatmap", width = 6, solidHeader = T, status = "primary",
                                                             withSpinner(plotOutput(outputId = "rlogPlot"))
                                                             ),
                                                         box(title = "PCA Plot", width = 6, solidHeader = T, status = "primary",
                                                             withSpinner(plotlyOutput(outputId = "rlogPcaPlot"))
                                                             ),
                                                         h4(p(class = "text-right",downloadButton('downloadRlogCsv','Download rlog.csv', class = "btn btn-primary btn-sm"))),
                                                         withSpinner(dataTableOutput("rlogData"))
                                                         )
                                        ,
                                        conditionalPanel("!output.ddsComputed",
                                                         wellPanel(
                                                           h4(p(class = "text-center", em("Running DESeq2, Please wait ..."), style = "color:#f56a6a;"))
                                                         )
                                        )
                                        
                               ),
                               tabPanel("Var Stabilizing Trans.",
                                        conditionalPanel("output.ddsComputed",
                                                         
                                                         box(title = "Distance Heatmap", width = 6, solidHeader = T, status = "primary",
                                                             withSpinner(plotOutput(outputId = "vsdPlot"))
                                                         ),
                                                         box(title = "PCA Plot", width = 6, solidHeader = T, status = "primary",
                                                             withSpinner(plotlyOutput(outputId = "vsdPcaPlot"))
                                                         ),
                                                         
                                                         h4(p(class = "text-right",downloadButton('downloadVsdCsv','Download vsd.csv', class = "btn btn-primary btn-sm"))),
                                                         withSpinner(dataTableOutput("vsdData"))
                                        ),
                                        conditionalPanel("!output.ddsComputed",
                                                         wellPanel(
                                                           h4(p(class = "text-center", em("Running DESeq2, Please wait ..."), style = "color:#f56a6a;"))
                                                         )
                                                         
                                                         )
                                        
                               )
                   )
                 )
                 
                 
                 )
          
        )#fluidrow
)