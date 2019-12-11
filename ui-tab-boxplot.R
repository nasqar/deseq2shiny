tabItem(tabName = "boxplotTab", 
        fluidRow(
          box(title = "Gene Expression Boxplot", solidHeader = T, status = "primary", width = 12,
              
              fluidRow(
                column(6,
                       wellPanel(
                       column(12, 
                              selectizeInput("sel_gene",
                                             label="Gene Name/Id (Select 1 or more)",#or Ensembl ID",
                                             choices = NULL,
                                             multiple=TRUE,
                                             options = list(
                                               placeholder = 
                                                 'Start typing to search for a gene name/id'# or ID',
                                             ) #,
                              )
                       ),
                       column(12, 
                              selectizeInput("sel_groups",
                                             label="Select Groups",
                                             multiple = T,
                                             choices="", selected=""
                              )
                       ),
                       column(12, 
                              selectizeInput("sel_factors",
                                             label="Select Factors",
                                             multiple = T,
                                             choices="", selected="",
                                             options = list(minItems = 2)
                              )
                       ),
                       div(style = "clear:both;")
                )
                       ),
                column(6,
                       h4(strong("Plot Settings:")),
                       wellPanel(
                         
                         fluidRow(
                           column(12,
                                  selectInput("boxplotX","Group (x-axis)", choices = c())
                           ),
                           column(12,
                                  selectInput("boxplotFill", "Fill (group by)", choices = c())
                           )
                         ),
                         # column(2,
                         #        radioButtons("counttype","Y axis:",choices=c("counts","rlog","vst"))
                         #        ),
                         # column(2,
                         #        actionButton("genBoxplot","Generate Plot", class = "btn btn-primary", style = "width:100%;")
                         # ),
                         div(style = "clear:both;")
                       )
                       )
              
          )
          
                 
          )
        ),
        fluidRow(
          hr(),
          conditionalPanel("output.boxplotComputed",
                           tags$div(class = "BoxArea2",
                                    column(12,
                                           box(title = "Boxplot", solidHeader = T, status = "primary", width = 12,
                                               withSpinner(plotlyOutput(outputId = "boxPlot")))
                                    ),
                                    h4(p(class = "text-right",downloadButton('downloadBoxCsv','Download .csv', class = "btn btn-primary btn-sm"))),
                                    withSpinner(dataTableOutput("boxplotData")),
                                    div(style = "clear:both;")
                                    
                           )
          )
        )
)