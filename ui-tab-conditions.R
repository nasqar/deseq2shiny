tabItem(tabName = "conditionsTab",
        fluidRow(
          conditionalPanel("!output.ddsComputed && input.run_deseq2 > 0 && !output.deseqError",
            
          column(12,
                 h3("Running DESeq"),
                 
                 hr(),
                 wellPanel(
                   
                   
                                    wellPanel(
                                      h4(p(class = "text-center", tags$b(em("Running DESeq2, Please wait ..."))), style = "color:#f56a6a;"),
                                      conditionalPanel("output.noReplicates",
                                                       p('Experiments without replicates do not allow for estimation of the dispersion of counts around the expected value for each group, which is critical for differential expression analysis. 
                                                         If an experimental design is supplied which does not contain the necessary degrees of freedom for 
                                                         differential analysis, DESeq will provide a message to the user and follow the strategy outlined 
                                                         in Anders and Huber (2010) under the section "Working without replicates", wherein all the samples 
                                                         are considered as replicates of a single group for the estimation of dispersion. As noted in the
                                                         reference above: "Some overestimation of the variance may be expected, which will make that 
                                                         approach conservative." Furthermore, "while one may not want to draw strong conclusions 
                                                         from such an analysis, it may still be useful for exploration and hypothesis generation."')
                                                       , style = "color:#f56a6a;")
                                    )
                   
                   
                 )
          )
        ),
        conditionalPanel("(output.ddsComputed && input.run_deseq2 > 0) || (!output.ddsComputed && input.run_deseq2 < 1) || output.deseqError",
                         
                         column(9,
                         box(title = "Design Formula", solidHeader = T, status = "primary",width = 12,
                             wellPanel(
                               textInput("designFormula","Design Formula:", placeholder = "~ Conditions")
                             )
                            )
                         ,
                        
                         
                         # box(
                         #   title = "Run",
                         #   solidHeader = T,
                         #   status = "success",
                         #   width = 2,
                         #   
                         #   actionButton("run_deseq2", "Run DESeq2", class = "btn btn-success",
                         #                style = "width:100%;height:60px;")
                         # )
                         # ,
                         
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
               box(title = "Run DESeq2", solidHeader = T, status = "success",width = 12,
                   wellPanel(
                     checkboxInput("computeVST","Compute VST transfomation", value = T),
                     checkboxInput("computeRlog","Compute RLog transfomation (may take a long time)", value = F)
                   ),
                   actionButton("run_deseq2", "Run DESeq2", class = "btn btn-success",
                                style = "width:100%;height:60px;")
               )
               
               )
        ,
        tags$div(class = "clearBoth")
        )
        )#fluidrow
        
        
        )