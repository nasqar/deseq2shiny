tabItem(tabName = "inputdata", 
        fluidRow(
          column(4,
                 box(title = "Upload Gene Counts", solidHeader = T, status = "primary", width = 12, collapsible = T,id = "uploadbox",
                     # h4("Upload Gene Counts"),
                     h4("(select .CSV)"),
                     radioButtons('data_file_type','Use example file or upload your own data',
                                  c(
                                    'Upload Counts File'="countsFile",
                                    'Example Data'="examplecounts"
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
                                        a(href="https://www.ncbi.nlm.nih.gov/pubmed?term=18978772", target="_blank", "this publication")),
                                      fileInput('datafile', '',
                                                accept=c('text/csv', 
                                                         'text/comma-separated-values,text/plain', 
                                                         '.csv'),multiple = FALSE
                                      )
                     )
                     
                 ),
                 conditionalPanel("output.fileUploaded",
                                  box(
                                    title = "Config & Prefilter",
                                    solidHeader = T,
                                    status = "primary",
                                    width = 12,
                                    checkboxInput("no_replicates", "No Replicates", FALSE),
                                    conditionalPanel("!output.noreplicates",
                                                     p("* Column names must indicate replicates by underscores (eg. sampleX_1,sampleX_2, etc ...)")
                                    ),
                                    conditionalPanel("output.noreplicates",
                                                     # tags$a(href = "#", bubbletooltip = 'If an experimental design is supplied which does not contain the necessary degrees of freedom for 
                                                     #                          differential analysis, DESeq will provide a message to the user and follow the strategy outlined 
                                                     #        <br> in Anders and Huber (2010) under the section "Working without replicates", wherein all the samples 
                                                     #        are considered as replicates of a single group for the estimation of dispersion. As noted in the
                                                     #        reference above: "Some overestimation of the variance may be expected, which will make that 
                                                     #        approach conservative." Furthermore, "while one may not want to draw strong conclusions 
                                                     #        from such an analysis, it may still be useful for exploration and hypothesis generation."',
                                                     #        icon("info-circle")),
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