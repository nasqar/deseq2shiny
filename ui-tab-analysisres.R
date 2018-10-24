tabItem(tabName = "resultsTab", 
        fluidRow(
          column(11,
                 h3(strong("Differential Expression Comparison")),
                 wellPanel(
                   column(3, selectInput("condition1","Condition 1", choices = NULL)),
                   column(1,
                          tags$div(class = "form-group",
                                   tags$label(" "),
                                   p(strong("VS")))
                          ),
                   column(3, selectInput("condition2","Condition 2", choices = NULL)),
                   column(5,
                          tags$div(class = "form-group",
                                   tags$label(" "),
                                   actionButton("getDiffResVs","Get Results", class = "btn btn-primary", style = "width:100%;"))
                          ),
                   div(style = "clear:both;")
                 ),
                 hr(),
                 conditionalPanel("output.comparisonComputed",
                                  tags$div(class = "BoxArea2",
                                  column(12,
                                         box(title = "MA Plot Settings", solidHeader = T, status = "primary",
                                                wellPanel(
                                                  sliderInput("alpha", "Adjusted p-value treshold", min=0, max=1, value=0.1, step=0.001),
                                                  numericInput("ylim",
                                                               label="Y Axis range abs value",min= 1, max=10,value=2)
                                                )),
                                         box(title = "MA Plot", solidHeader = T, status = "primary",
                                                withSpinner(plotOutput(outputId = "maPlot")))
                                         ),
                                  h4(p(class = "text-right",downloadButton('downloadVsCsv','Download .csv', class = "btn btn-primary btn-sm"))),
                                  withSpinner(dataTableOutput("comparisonData")),
                                  div(style = "clear:both;")
                                  
                 )
                 )
          )
        )
)