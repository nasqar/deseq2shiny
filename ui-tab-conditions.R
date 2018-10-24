tabItem(tabName = "conditionsTab",
        
        
        column(
          10,
          box(
            title = "Conditions/Factors (Optional)",
            solidHeader = T,
            status = "primary",
            width = 12,
            column(
              8,
              h4("Edit Table"),
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
              h4("Add Conditions/Factors"),
              wellPanel(
                textInput("conditionName", "Condition/Factor Name", placeholder = "Eg. Time"),
                textInput(
                  "conditions",
                  "List of Conditions/Factors (comma seperated)",
                  placeholder = "Eg. 1hr, 5hr, 6hr"
                ),
                actionButton(
                  "addConditions",
                  "Add Condition/Factor",
                  class = "btn btn-primary",
                  disabled = "disabled"
                )
              ),
              hr(),
              h4("Remove Columns"),
              wellPanel(
                selectInput("colToRemove", "Remove Column", choices = NULL),
                actionButton(
                  "removeCol",
                  "Remove",
                  class = "btn btn-danger",
                  disabled = "disabled",
                  icon = icon("times")
                )
              )
            )
          )
        ),
        column(2,
               box(
                 title = "Run",
                 solidHeader = T,
                 status = "primary",
                 width = 12,
                 
                 actionButton("run_deseq2", "Run DESeq2", class = "btn btn-success",
                              style = "width:100%;height:60px;")
               )
        ),
        tags$div(class = "clearBoth"))