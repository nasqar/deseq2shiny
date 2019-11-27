tabItem(tabName = "boxplotTab", 
        fluidRow(
          column(11,
                 h3(strong("Gene Expression Boxplot")),
                 wellPanel(
                   column(5, 
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
                   column(5, 
                          selectizeInput("sel_group",
                                             label="Select Group",
                                             multiple = T,
                                             choices="", selected=""
                          )
                          ),
                   column(2,
                          radioButtons("counttype","Y axis:",choices=c("counts","rlog","vst"))
                          ),
                   # column(2,
                   #        actionButton("genBoxplot","Generate Plot", class = "btn btn-primary", style = "width:100%;")
                   # ),
                   div(style = "clear:both;")
                 ),
                 hr(),
                 conditionalPanel("output.boxplotComputed",
                                  tags$div(class = "BoxArea2",
                                           column(12,
                                                  box(title = "Boxplot", solidHeader = T, status = "primary", width = 12,
                                                      withSpinner(plotlyOutput(outputId = "boxPlot")))
                                           ),
                                           # h4(p(class = "text-right",downloadButton('downloadBoxCsv','Download .csv', class = "btn btn-primary btn-sm"))),
                                           withSpinner(dataTableOutput("boxplotData")),
                                           div(style = "clear:both;")
                                           
                                  )
                 )
          )
        )
)