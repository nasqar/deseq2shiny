observe({
  compareReactive()
})

compareReactive <- reactive({
  if(input$getDiffResVs > 0)
  {
    isolate({
      validate(
        need(input$condition1 != input$condition2, message = "condition 1 must be different from condition 2")
      )
      myValues$vsResults <- results(myValues$dds,contrast=c("Conditions",input$condition1,input$condition2))
      
      return(myValues$vsResults)
    })
    
  }
})

output$maPlot <- renderPlot({
  if(!is.null(compareReactive()))
  {
    isolate({
      plotMA(compareReactive(), main=paste0(input$condition1,"_vs_",input$condition2), ylim=c(-input$ylim,input$ylim), alpha=input$alpha)
    })
    
  }
  
  
})

output$comparisonData <- renderDataTable({
  if(!is.null(compareReactive()))
  {
    df = as.data.frame(compareReactive())
    df[is.na(df)] = 0
    df
  }
}, 
options = list(scrollX = TRUE, pageLength = 5))



output$downloadVsCsv <- downloadHandler(
  
  filename = function() {paste0(input$condition1,"_vs_",input$condition2,".csv")},
  content = function(file) {
    csv = myValues$vsResults
    
    write.csv(csv, file, row.names=F)
  }
  
)

output$comparisonComputed <- reactive({
  return(!is.null(myValues$vsResults))
})
outputOptions(output, 'comparisonComputed', suspendWhenHidden=FALSE)