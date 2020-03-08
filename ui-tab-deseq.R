tabItem(tabName = "deseqTab", 
        fluidRow(
          column(11,
                 h3("Run DESeq"),
                 
                 hr(),
                 # conditionalPanel("!output.ddsComputed && input.run_deseq2 > 0 && !output.deseqError",
                 #                    wellPanel(
                 #                      h4(p(class = "text-center", tags$b(em("Running DESeq2, Please wait ..."))), style = "color:#f56a6a;"),
                 #                                           conditionalPanel("output.noReplicates",
                 #                                                            p('Experiments without replicates do not allow for estimation of the dispersion of counts 
                 #                                                              around the expected value for each group, which is critical for differential expression analysis. 
                 #                                                              If an experimental design is supplied which does not contain the necessary degrees of freedom for 
                 #                                                              differential analysis, DESeq will provide a message to the user and follow the strategy outlined 
                 #                                                              in Anders and Huber (2010) under the section "Working without replicates", wherein all the samples 
                 #                                                              are considered as replicates of a single group for the estimation of dispersion. As noted in the
                 #                                                              reference above: "Some overestimation of the variance may be expected, which will make that 
                 #                                                              approach conservative." Furthermore, "while one may not want to draw strong conclusions 
                 #                                                              from such an analysis, it may still be useful for exploration and hypothesis generation."')
                 #                                                            , style = "color:#f56a6a;")
                 #                                         )
                 #                        ),
                 # conditionalPanel("(output.ddsComputed && input.run_deseq2 > 0) || (!output.ddsComputed && input.run_deseq2 < 1) || output.deseqError",
                 box(title = "DESeq run settings:", solidHeader = T, status = "success",width = 12,
                     
                     column(6,
                            wellPanel(
                              p("The DESeq function performs Differential Expression analysis based on the Negative Binomial Distribution using the following steps:"),
                              tags$ul(
                                tags$li("1. estimation of size factors"),
                                tags$li("2. estimation of dispersion"),
                                tags$li("3. Negative Binomial GLM fitting and Wald statistics")
                              ),
                              checkboxInput("computeVST","Compute VST transfomation", value = T),
                              checkboxInput("computeRlog","Compute RLog transfomation (may take a long time)", value = F)
                            ),
                            actionButton("run_deseq2", "Run DESeq2", class = "btn btn-success",
                                         style = "width:100%;height:60px;")
                     ),
                     column(6,
                            tags$div(class = "BoxArea",
                                     p(strong("Design Formula: "),textOutput("ddsDesignFormula")),
                                     hr(),
                                     p("Showing only the first 5 rows of ",strong("colData")," table:"),
                                     tableOutput('ddsColData')
                            )
                     ),
                     column(12,
                            conditionalPanel("output.noReplicates",wellPanel(p('Experiments without replicates do not allow for estimation of the dispersion of counts
                                                                                                                                              around the expected value for each group, which is critical for differential expression analysis.
                                                                                                                       If an experimental design is supplied which does not contain the necessary degrees of freedom for
                                                                                                                       differential analysis, DESeq will provide a message to the user and follow the strategy outlined
                                                                                                                       in Anders and Huber (2010) under the section "Working without replicates", wherein all the samples
                                                                                                                       are considered as replicates of a single group for the estimation of dispersion. As noted in the
                                                                                                                       reference above: "Some overestimation of the variance may be expected, which will make that
                                                                                                                       approach conservative." Furthermore, "while one may not want to draw strong conclusions
                                                                                                                       from such an analysis, it may still be useful for exploration and hypothesis generation."')
                                             ), style = "color:#f56a6a;")
                            
                     ),
                     div(style = "clear:both;")
                     
                 ),
                 box(title = "(Optional) Surrogate Variable Analysis (SVA)", solidHeader = T, status = "primary",width = 6,
                     
                     wellPanel(
                       p("Run Surrogate Variable Analysis (for hidden batch detection)"),
                       p("You may choose to include computed Surrogate Variables (SVs) in your design formula for downstream differential expression analysis")
                     ),
                     actionButton("goto_svaTab", "Goto Surrogate Variable Analysis (SVA)", class = "btn btn-primary",
                                  style = "width:100%;height:60px;")
                     
                 )
                 #)
                 
                 
                 
                 
                 
          )
        )#fluidrow
)