tabItem(tabName = "heatmapTab", 
        fluidRow(
          column(11,
                 h3(strong("Heatmap")),
                 wellPanel(
                   fluidRow(
                     column(3,
                            numericInput("numGenes",label="Number of genes to include (ordered by SD max 1000)",
                                         min=10,max= 1000,value=100,step=10)
                     ),
                     # column(5,
                     #        selectizeInput("heat_group",
                     #                           label="Select Group",
                     #                           multiple = T,
                     #                           choices="", selected=""
                     #        )
                     # ),
                     column(7,
                            checkboxInput("subsetGenes","Select a subset of genes"),
                            conditionalPanel("input.subsetGenes",
                                             textAreaInput("listPasteGenes", "List Of Genes (comma seperated)", width = "100%", rows = 5)
                            )
                     ),
                     column(2,
                            actionButton("genHeatmap","Generate Plot", class = "btn btn-primary", style = "width:100%;")
                     ),
                     column(2, offset = 10,
                            conditionalPanel("output.heatmapComputed",
                                             downloadButton('downloadHighResHeatmap', 
                                                            'Download Heatmap', class = "btn btn-warning"))
                            ),
                     column(12,
                            p("* This heatmap uses normalized counts which can be viewed/downloaded below the figure")
                            )
                   ),
                   div(style = "clear:both;")
                 ),
                 hr(),
                 conditionalPanel("output.heatmapComputed",
                                  tags$div(class = "BoxArea2",
                                           column(12,
                                                  box(title = "Heatmap", solidHeader = T, status = "primary", width = 12,
                                                      withSpinner(plotOutput(outputId = "heatmapPlot",height="1200px")))
                                           ),
                                           h4(p(class = "text-right",downloadButton('downloadHeatmapCsv','Download Normalized Counts .csv', class = "btn btn-primary btn-sm"))),
                                           withSpinner(dataTableOutput("heatmapData")),
                                           div(style = "clear:both;")
                                           
                                  )
                 )
          )
        )
)