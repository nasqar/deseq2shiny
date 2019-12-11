

observe({
  
  colnamesChoices = colnames(myValues$DF[!(names(myValues$DF) %in% c("Samples","Groups"))])
  updateSelectInput(session, "colToRemove", choices = colnamesChoices, selected = NULL)
  
})

observeEvent(input$removeCol,{
  validate(
    need(input$colToRemove != "", message = "need to select column to remove")
  )
  myValues$DF[,input$colToRemove] = NULL
  updateDesignFormula()
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
      updateDesignFormula()
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
  
  
  table = rhandsontable(DF1, rowHeaderWidth=100)  %>%
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
    write.csv(hot_to_r(input$table), file, row.names=T)
  }
)

observe({
  metadataFileReactive()
})
metadataFileReactive <- reactive({
  
  # Check if example selected, or if not then ask to upload a file.
  shiny:: validate(
    need( (!is.null(input$metadatafile)),
          message = "Please select a file")
  )
  
  inFile <- input$metadatafile
  if (is.null(inFile))
    return(NULL)
    
  inFile = inFile$datapath  
    
  # select file separator, either tab or comma
  sep = '\t'
  if(length(inFile) > 0 ){
    testSep = read.csv(inFile[1], header = TRUE, sep = '\t')
    if(ncol(testSep) < 2)
      sep = ','
  }
  else
    return(NULL)
  
  fileContent = read.csv(inFile[1], header = TRUE, sep = sep)
  
  sampleN = colnames(fileContent)[-1]
  metaData <- fileContent[,sampleN]
  metaData <- data.frame(sapply( metaData, as.factor ))
  row.names(metaData) <- fileContent[,1]
  
  myValues$DF = metaData
  
  updateDesignFormula()
  
  return(metaData)
})


updateDesignFormula = function()
{
  isolate({
    groupvars = colnames(myValues$DF)
    
    if(length(groupvars) == 1)
    {
      if(length(levels(myValues$DF[,groupvars])) == nrow(myValues$DF)) 
        designFormula = "~ 1"
      else
        designFormula = paste("~ ",groupvars)
    }
      
    else
      designFormula = paste(" ~ ",paste(groupvars, collapse=" + "))
    
    updateTextInput(session,"designFormula", value = designFormula)
  })
  
}


getConditionsListFromStr <- function(conditonsStr)
{
  conditions =isolate(  unlist(strsplit(conditonsStr,",")) )
  conditions = trimws(conditions)
  conditions = conditions[conditions != ""]
  conditions = unique(conditions)
  return(conditions)
}