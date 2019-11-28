tabItem(tabName = "vstTab", 
        fluidRow(
          column(11,
                 h3("Variance Stabilizing Transformation"),
                 p('This function calculates a variance stabilizing transformation (VST) from the fitted dispersion-mean relation(s) and then transforms the count data (normalized by division by the size factors or normalization factors), yielding a matrix of values which are now approximately homoskedastic (having constant variance along the range of mean values). The transformation also normalizes with respect to library size. The rlog is less sensitive to size factors, which can be an issue when size factors vary widely. These transformations are useful when checking for outliers or as input for machine learning techniques such as clustering or linear discriminant analysis.'),
                 hr(),
                 wellPanel(
                   
                                             box(title = "Distance Heatmap", width = 6, solidHeader = T, status = "primary",
                                                 withSpinner(plotlyOutput(outputId = "vsdPlot"))
                                             ),
                                             box(title = "PCA Plot", width = 6, solidHeader = T, status = "primary",
                                                 withSpinner(plotlyOutput(outputId = "vsdPcaPlot"))
                                             ),

                                             h4(p(class = "text-right",downloadButton('downloadVsdCsv','Download vsd.csv', class = "btn btn-primary btn-sm"))),
                                             withSpinner(dataTableOutput("vsdData"))
                            

                   
                   
                 )
                 
                 
          )
          
        )#fluidrow
)