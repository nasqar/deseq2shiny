tabItem(tabName = "rlogTab", 
        fluidRow(
          column(11,
                 h3("Regularized Log Transformation"),
                 p('This function transforms the count data to the log2 scale in a way which minimizes differences between samples for rows with small counts, and which normalizes with respect to library size. The rlog transformation produces a similar variance stabilizing effect as varianceStabilizingTransformation, though rlog is more robust in the case when the size factors vary widely. The transformation is useful when checking for outliers or as input for machine learning techniques such as clustering or linear discriminant analysis.'),
                 hr(),
                 wellPanel(
                   
                   
                     
                                    box(title = "Distance Heatmap", width = 6, solidHeader = T, status = "primary",
                                        withSpinner(plotlyOutput(outputId = "rlogPlot"))
                                    ),
                                    box(title = "PCA Plot", width = 6, solidHeader = T, status = "primary",
                                        selectInput("rlogIntGroupsInput","Group of interest", choices=c()),
                                        withSpinner(plotlyOutput(outputId = "rlogPcaPlot"))
                                    ),
                                    h4(p(class = "text-right",downloadButton('downloadRlogCsv','Download rlog.csv', class = "btn btn-primary btn-sm"))),
                                    withSpinner(dataTableOutput("rlogData"))
                   
                   
                   
                   # tabPanel("Var Stabilizing Trans.",
                   #          conditionalPanel("output.ddsComputed",
                   # 
                   #                           box(title = "Distance Heatmap", width = 6, solidHeader = T, status = "primary",
                   #                               withSpinner(plotlyOutput(outputId = "vsdPlot"))
                   #                           ),
                   #                           box(title = "PCA Plot", width = 6, solidHeader = T, status = "primary",
                   #                               withSpinner(plotlyOutput(outputId = "vsdPcaPlot"))
                   #                           ),
                   # 
                   #                           h4(p(class = "text-right",downloadButton('downloadVsdCsv','Download vsd.csv', class = "btn btn-primary btn-sm"))),
                   #                           withSpinner(dataTableOutput("vsdData"))
                   #          ),
                   #          conditionalPanel("!output.ddsComputed",
                   #                           wellPanel(
                   #                             h4(p(class = "text-center", em("Running DESeq2, Please wait ..."), style = "color:#f56a6a;"))
                   #                           )
                   # 
                   #                           )
                   # 
                   # )
                   
                 )
                 
                 
          )
          
        )#fluidrow
)