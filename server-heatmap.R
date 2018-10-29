observe({
  # updateSelectizeInput(session,'sel_gene',
  #                      choices= rownames(myValues$dataCounts),
  #                      server=TRUE)

  tmpgroups = unique(myValues$DF$Conditions)
  updateCheckboxGroupInput(session,'heat_group',
                           choices=tmpgroups, selected=tmpgroups)


})

observe({
  heatmapReactive()
})

heatmapReactive <- reactive({

  
  if(input$genHeatmap > 0)
  {
    isolate({
      vst = myValues$vstMat
      selGroupSamples = as.character(myValues$DF[myValues$DF$Conditions %in% input$heat_group,]$Samples)
      vst = vst[,selGroupSamples]
      browser()
      #vst = vst[,input$heat_group]
      
      if(!input$subsetGenes)
      {
        tmpsd = apply(vst,1,sd)
        
        selectGenes = rownames(vst)[order(tmpsd,decreasing=TRUE)]
        selectGenes = head(selectGenes,input$numGenes)
        
        genesNotFound = NULL
      }
      else{
        
        genes = unlist(strsplit(input$listPasteGenes,","))
        
        genes = gsub("^\\s+|\\s+$", "", genes)
        genes = gsub("\\n+$|^\\n+", "", genes)
        genes = gsub("^\"|\"$", "", genes)
        
        genes = genes[genes != ""] 
        
        genesNotFound = genes[!(genes %in% rownames(vst))]
        
        genes = genes[!(genes %in% genesNotFound)]
        
        selectGenes = genes
        
      }
      
      vst = vst[selectGenes,]
      return(list('vst'=vst,'genesNotFound'=genesNotFound))
    })
    
  }
 
#   
})

output$heatmapPlot <- renderPlot({
  if(!is.null(heatmapReactive()))
  {
    vst= heatmapReactive()$vst
    genesNotFound = heatmapReactive()$genesNotFound
    
    validate(
      need( is.null(genesNotFound) || length(genesNotFound) < 1, message = "Some genes were not found!"),
      need(nrow(vst) > 1, message = "Need atleast 2 genes to plot!")
    )
    
    annCol = myValues$DF
    annCol[,1] = NULL
    isolate({
      annCol = annCol[which(annCol$Conditions %in% input$heat_group),]
    })
    
    
    NMF::aheatmap(vst,scale = "none",
                  revC=TRUE,
                  fontsize = 10,
                  cexRow = 1.2,
                  color = colorRampPalette( rev(brewer.pal(9, "Blues")) )(255),
                  annCol = annCol)
    
  }
  
  
})
# 
# output$boxplotData <- renderDataTable({
#   if(!is.null(heatmapReactive()))
#   {
#     heatmapReactive()
#   }
# }, 
# options = list(scrollX = TRUE, pageLength = 5))
# 
# 
output$heatmapComputed <- reactive({
  return(!is.null(heatmapReactive()))
})
outputOptions(output, 'heatmapComputed', suspendWhenHidden=FALSE)


# output$downloadBoxCsv <- downloadHandler(
#   
#   filename = function() {paste0(input$condition1,"_vs_",input$condition2,".csv")},
#   content = function(file) {
#     csv = heatmapReactive()
#     
#     write.csv(csv, file, row.names=F)
#   }
#   
# )