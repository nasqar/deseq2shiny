tabItem(tabName = "svaseqTab",
        fluidRow(
          column(11,
                 h3("Surrogate variable analysis (svaseq): hidden batch effects"),
                 hr(),
                 wellPanel(
                   p("We can sometimes identify the source of batch 
                     effects, and by using statistical models, we can remove any sample-specific variation we can 
                     predict based on features like sequence content or gene length. Here we use Surrogate Variable Analysis (SVA), 
                     which doesn’t require the use of knowing exactly how the counts will vary across 
                     batches. It uses only the biological condition, and looks for large scale variation which is 
                     orthogonal to the biological condition. This approach requires that the technical variation be orthogonal to 
                     the biological conditions."
                   ),
                   p("For more information, see following ", a("link",target = "_blank",href="https://www.bioconductor.org/packages/devel/workflows/vignettes/rnaseqGene/inst/doc/rnaseqGene.html#using-sva-with-deseq2"))
                 ),
                 box(title = "Estimate Surrogate Variables (SVA)", width = 12, solidHeader = T, status = "primary",
                     column(6,
                            numericInput("numSVA","Numer of SVs to estimate", value = 2)
                     ),
                     column(6,
                            textInput("designFormulaSva","Design Formula (SVA):", placeholder = "~ Conditions")
                     ),
                     column(12,
                            actionButton("runSVA","Run SVA")
                     ),
                     hr(),
                     column(12,
                            textOutput("svaText")
                     )
                     
                 ),
                 conditionalPanel("output.ddsSvaAvailable",
                                  box(title = "SVA Plot", width = 12, solidHeader = T, status = "primary",
                                      column(8,
                                             withSpinner(plotlyOutput("svaPlot"))
                                      ),
                                      column(4,
                                             wellPanel(
                                               selectInput("xaxisSva","x-axis variable",choices = c()),
                                               selectInput("yaxisSva","y-axis variable",choices = c()),
                                               selectInput("colorBy","colorBy",choices = c())
                                             )
                                      )
                                  ),
                                  box(title = "Remove Batch Effect (PCA Visualization)", width = 12, solidHeader = T, status = "primary",
                                      p("Here we use limma::removeBatchEffect in order to regress the effect of selected Surrogate/Batch variable(s)"),
                                      p("This is strictly for visualization purposes only, and the corrected counts are NOT used for downstream analysis"),
                                      p(em("Inspect the plots and decide whether to include Surrogate Variables as adjustment factors in design for downstream analysis")),
                                      column(6,
                                             selectizeInput("varsToRegress","Select Variables to regress", multiple = T, choices = c())
                                      ),
                                      column(6,
                                             textInput("newFormulaSva","New Design formula for regression of batch variables","")
                                      ),
                                      column(12,
                                             actionButton("regressVarsBatch", "Regress selected variables and plot PCA", class = "btn btn-warning")
                                      ),
                                      column(12,
                                             conditionalPanel("output.pcaSvaAvailable",
                                                              hr(),
                                                              wellPanel(
                                                                p(strong("Next step:")),
                                                                #textOutput("varsToIncludeInDeseq"),
                                                                fluidRow(
                                                                  column(5,
                                                                         actionButton("runDeseqWithSVs","Include selected SVs and proceed to DESeq2 analysis", class = "btn btn-success") 
                                                                  ),
                                                                  column(1,
                                                                         p("OR")
                                                                  ),
                                                                  column(6,
                                                                         actionButton("runDeseqWithoutSVs","Proceed to DESeq2 analysis without SVs")
                                                                  ),
                                                                  div(style = "clear:both;")
                                                                )
                                                                
                                                              )
                                             )
                                             
                                             
                                      ),
                                      div(style = "clear:both;"),
                                      conditionalPanel("output.pcaSvaAvailable",
                                                       hr(),
                                                       div(class = "BoxArea2",
                                                           h4(strong("PCA (VST) after regression of batch/surrogate variable(s)")),
                                                           column(8,
                                                                  withSpinner(  plotlyOutput("pcaSvaPlot") )
                                                           ),
                                                           column(4,
                                                                  wellPanel(
                                                                    column(12,
                                                                           selectizeInput("factorNameInputSva","Factor(s)", choices =c(), multiple = T)
                                                                    ),
                                                                    div(style = "clear:both;")
                                                                  )
                                                           ),
                                                           div(style = "clear:both;")
                                                       )
                                      )
                                      
                                  )
                 )
                 
          )#fluidrow
          
          
        )
)