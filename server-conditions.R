
# observe({
#   tableCreateReactive()
# })
# 
# tableCreateReactive <- reactive({
#   
#   if(input$createTable > 0)
#   {
#     isolate({
#       
#       
#       validate(
#         
#         need((input$samplesList!="")|(!is.null(input$datafile)),
#              message = "Please select a file or type in list of sample names")
#       )
#       
#       
#       if(input$samplesList!="")
#         inputSampleNames = input$samplesList
#       else
#         inputSampleNames <- read_file(input$datafile$datapath)
#       
#       samplenames = getSampleNamesFromStr(inputSampleNames)
#       
#       DF = data.frame(Samples=samplenames)
#       
#       
#       myValues$DF = DF
#       myValues$conditions = list()
#     })
#   }
# })


observe({
  
  colnamesChoices = colnames(myValues$DF[!(names(myValues$DF) %in% c("Samples","Groups"))])
  updateSelectInput(session, "colToRemove", choices = colnamesChoices, selected = NULL)
  
})

observeEvent(input$removeCol,{
  validate(
    need(input$colToRemove != "", message = "need to select column to remove")
  )
  myValues$DF[,input$colToRemove] = NULL
})

observe({
  tableEditReactive()
})

tableEditReactive <- reactive({
  
  if(input$addConditions > 0)
  {
    
    isolate({
      myValues$DF = hot_to_r(input$table)
      DF = myValues$DF
      
      
      validate(
        need(!(input$conditionName %in% colnames(DF)), message = "Condition name already exists"),
        need(trimws(input$conditionName) != "", message = "Condition name empty"),
        need(trimws(input$conditions) != "", message = "Conditions empty")
      )
      
      newDF = data.frame(newCol = character(dim(DF)[1]))
      names(newDF) = c(input$conditionName)
      
      DF = cbind(DF,newDF)
      
      myValues$DF = DF
      
      myValues$conditions[[dim(DF)[2] - 1]] = input$conditions
      
      updateTextInput(session, "conditionName", value = "")
      updateTextInput(session, "conditions",value = "")
      
    })
  }
})

# output$tableCreated <-
#   reactive({
#     return(!is.null(myValues$DF))
#   })
# outputOptions(output, 'tableCreated', suspendWhenHidden=FALSE)

output$table = renderRHandsontable({
  
  DF1 = myValues$DF
  if(is.null(DF1))
    return()
  
  
  table = rhandsontable(DF1)  %>%
    hot_cols(colWidths = 150)
  
  table =  table %>% hot_table(highlightCol = TRUE, highlightRow = TRUE, colHeaders = NULL)
  
  for(i in 2:dim(DF1)[2])
  {
    if(dim(DF1)[2] < 2)
      break()
    if(!is.null(myValues$conditions[[i-1]]))
      table = table %>% hot_col(col = colnames(DF1)[i], type = "dropdown", source = getConditionsListFromStr(myValues$conditions[[i-1]]))
    
  }
  
  table
  
})

output$downloadCSV <- downloadHandler(
  
  filename = paste0("metadatatable_",format(Sys.time(), "%y-%m-%d_%H-%M-%S"),".csv"),
  content = function(file) {
    write.csv(hot_to_r(input$table), file, row.names=F)
  }
)
