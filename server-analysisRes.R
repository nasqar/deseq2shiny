observe({
  compareReactive()
})

compareReactive <- reactive({
  if(input$getDiffResVs > 0)
  {
    isolate({
      factorsStr = "Intercept: no replicates"
      if(input$no_replicates)
      {
        
        myValues$vsResults <- results(myValues$dds)
      }
        
      else{
        if(input$resultNameOrFactor == 'Result Names')
        {
          validate(
            need((length(input$resultNamesInput) > 0 & length(input$resultNamesInput) < 3), message = "Need to chooise at least 1 (Max. 2)")
          )
          
          myValues$vsResults <- results(myValues$dds,contrast=list(input$resultNamesInput))
          factorsStr = paste(list(input$resultNamesInput))
        }
        else if(input$resultNameOrFactor == 'Factors')
        {
          validate(
            need((input$condition1 != input$condition2) , message = "condition 1 must be different from condition 2")
          )
          
          myValues$vsResults <- results(myValues$dds,contrast=c(input$factorNameInput,input$condition1,input$condition2))
          factorsStr = paste(input$factorNameInput, " : ", input$condition1,input$condition2)
        }
      }
      
      return(list('results'=myValues$vsResults, 'conditions'=factorsStr))
    })
    
  }
})

output$maPlot <- renderPlot({
  if(!is.null(compareReactive()))
  {
    isolate({
      plotMA(compareReactive()$results, main="MA Plot", ylim=c(-input$ylim,input$ylim), alpha=input$alpha)
    })
    
  }
  
  
})

output$comparisonData <- renderDataTable({
  if(!is.null(compareReactive()))
  {
    df = as.data.frame(compareReactive()$results)
    df[is.na(df)] = 0
    df
  }
}, 
options = list(scrollX = TRUE, pageLength = 5))

output$factorsStr <- renderText({
  if(!is.null(compareReactive()))
    return(compareReactive()$conditions)
  
  return(NULL)
  
})

output$downloadVsCsv <- downloadHandler(
  
  filename = function() {paste0(input$condition1,"_vs_",input$condition2,".csv")},
  content = function(file) {
    csv = myValues$vsResults
    
    write.csv(csv, file, row.names=T)
  }
  
)

output$comparisonComputed <- reactive({
  return(!is.null(myValues$vsResults))
})
outputOptions(output, 'comparisonComputed', suspendWhenHidden=FALSE)

output$noReplicates <- reactive({
  return(input$no_replicates)
})
outputOptions(output, 'noReplicates', suspendWhenHidden=FALSE)