tabItem(tabName = "deseqTab", 
        fluidRow(
          column(11,
                 h3("Running DESeq"),
                 
                 hr(),
                 wellPanel(
                                        
                                        conditionalPanel("!output.ddsComputed",
                                                         wellPanel(
                                                           h4(p(class = "text-center", tags$b(em("Running DESeq2, Please wait ..."))), style = "color:#f56a6a;"),
                                                           conditionalPanel("output.noReplicates",
                                                                            p('Experiments without replicates do not allow for estimation of the dispersion of counts 
                                                                              around the expected value for each group, which is critical for differential expression analysis. 
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
          )
        )#fluidrow
)