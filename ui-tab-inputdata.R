tabItem(tabName = "inputdata", 
        fluidRow(
          column(4,
                 box(title = "Upload Gene Counts", solidHeader = T, status = "primary", width = 12, collapsible = T,id = "uploadbox",
                     # h4("Upload Gene Counts"),
                     h4("(select .CSV)"),
                     radioButtons('data_file_type','Use example file or upload your own data',
                                  c(
                                    'Upload Counts File (single-factor)'="countsFile",
                                    'Example Data (single-factor)'="examplecounts",
                                    'Example Data (multi-factor)'='examplecountsfactors'
                                  ),selected = "countsFile"),
                     conditionalPanel(condition="input.data_file_type=='countsFile'",
                                      p(".csv/.txt counts file (tab or comma delimited)")
                                      ,
                                      fileInput('datafile', '',
                                                accept=c('text/csv', 
                                                         'text/comma-separated-values,text/plain', 
                                                         '.csv'),multiple = FALSE
                                      )
                     ),
                     conditionalPanel(condition="input.data_file_type=='examplecounts'",
                                      p("For details on this data, see ",
                                        a(href="https://www.ncbi.nlm.nih.gov/pubmed?term=18978772", target="_blank", "this publication"))
                                      # fileInput('datafile', '',
                                      #           accept=c('text/csv', 
                                      #                    'text/comma-separated-values,text/plain', 
                                      #                    '.csv'),multiple = FALSE
                                      # )
                     ),
                     conditionalPanel(condition="input.data_file_type=='examplecountsfactors'",
                                      p("For details on this data, see ",
                                        a(href="https://doi.org/10.1007/978-3-319-07212-8_3", target="_blank", "this publication"))
                                      
                     )
                     
                 ),
                 conditionalPanel("output.fileUploaded",
                                  box(
                                    title = "Config & Prefilter",
                                    solidHeader = T,
                                    status = "primary",
                                    width = 12,
                                    checkboxInput("no_replicates", "No Replicates", FALSE)
                                    ,
                                    conditionalPanel("!output.noreplicates",
                                                     p("* For convenience, if this is a single-factor experiment and column names are denoted by underscore replicate number (eg. sampleX_1,sampleX_2, etc ...)"),
                                                     p("the sample names will be parsed automatically and the conditions table will be set for the next step.")
                                    ),
                                    conditionalPanel("output.noreplicates",
                                                     
                                                     p('Experiments without replicates do not allow for estimation of the dispersion of counts 
                                                        around the expected value for each group, which is critical for differential expression analysis.'),
                                                     span("For more details, click ",a("here",href="https://www.rdocumentation.org/packages/DESeq2/versions/1.12.3/topics/DESeq", target="_blank"))
                                                     
                                    , style = "color:#f56a6a;"),
                                    tags$div(class = "BoxArea2",
                                    numericInput("minRowCount",label="(Optional) Minimum number of counts to include for each gene (Default 0, to include all)",
                                                 min=0,value=0),
                                    actionButton("prefilterCounts","Filter"),
                                    p("This step is not necessary, but can speed up the processing time")
                                    ),
                                    hr(),
                                    actionButton("submit","Next: Conditions", class = "btn btn-primary")
                                  )
                 )
                 )
          
        ,#column
        column(8,h2("Gene Counts Table"),hr(),
              withSpinner(dataTableOutput("contents"))
        )#column
        )#fluidrow
)