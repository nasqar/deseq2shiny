tabItem(tabName = "conditionsTab",
        fluidRow(
          conditionalPanel("(output.ddsInitAvailable && input.init_deseq2 > 0) || (!output.ddsInitAvailable && input.init_deseq2 < 1)",
                           
                           column(9,
                                  box(title = "Design Formula", solidHeader = T, status = "primary",width = 12,
                                      wellPanel(
                                        textInput("designFormula","Design Formula:", placeholder = "~ Conditions")
                                      )
                                  )
                                  ,
                                  box(
                                    title = "Conditions/Factors",
                                    solidHeader = T,
                                    status = "primary",
                                    width = 12,
                                    h4(strong("Option 1) Edit Table: ")),
                                    column(
                                      8,
                                      
                                      rHandsontableOutput("table"),
                                      hr(),
                                      tags$ul(
                                        tags$li("Tag samples with corresponding conditions"),
                                        tags$li("Download CSV")
                                      ),
                                      downloadButton('downloadCSV', 'Download CSV')
                                      
                                    ),
                                    column(
                                      4,
                                      wellPanel(
                                        
                                        column(12,
                                               #h4("Add Conditions/Factors"),
                                               textInput("conditionName", "Condition/Factor Name", placeholder = "Eg. Time"),
                                               textInput(
                                                 "conditions",
                                                 "List of Conditions/Factors (comma seperated)",
                                                 placeholder = "Eg. 1hr, 5hr, 6hr"
                                               ),
                                               actionButton(
                                                 "addConditions",
                                                 "Add Condition/Factor",
                                                 class = "btn btn-primary"
                                               )
                                        ),
                                        
                                        
                                        column(12,
                                               hr(),
                                               #h4("Remove Columns"),
                                               
                                               selectInput("colToRemove", "Remove Column", choices = NULL),
                                               actionButton(
                                                 "removeCol",
                                                 "Remove",
                                                 class = "btn btn-danger",
                                                 icon = icon("times")
                                               )
                                        )
                                        ,
                                        tags$div(class = "clearBoth")
                                      )
                                    ),
                                    column(12,
                                           hr(),
                                           h4(strong("Option 2) Upload Experiment design table (meta table)")),
                                           p(".csv/.txt counts file (tab or comma delimited)")
                                           ,
                                           fileInput('metadatafile', '',
                                                     accept=c('text/csv', 
                                                              'text/comma-separated-values,text/plain', 
                                                              '.csv'),multiple = FALSE
                                           )
                                    )
                                  )
                                  
                                  ,
                                  tags$div(class = "clearBoth")
                                  
                           ),
                           column(3,
                                  box(title = "1. Initialize DESeq2 Dataset", solidHeader = T, status = "success",width = 12,
                                      wellPanel(
                                        p("Initialize DESeq2 dataset with current counts and experimental design conditions")
                                      ),
                                      actionButton("init_deseq2", "Initialize DESeq2", class = "btn btn-success",
                                                   style = "width:100%;height:60px;")
                                  )
                                  
                                  
                                  
                           )
                           ,
                           tags$div(class = "clearBoth")
          )
        )#fluidrow
        
        
)