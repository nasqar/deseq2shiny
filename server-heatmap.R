observe({
  # updateSelectizeInput(session,'sel_gene',
  #                      choices= rownames(myValues$dataCounts),
  #                      server=TRUE)
# browser()
  tmpgroups = colnames(myValues$DF)
  tmpgroups = unlist(lapply(tmpgroups, function(x) {levels(myValues$DF[,x])}))

  updateSelectizeInput(session,'heat_group',
                       choices=tmpgroups, selected=tmpgroups, server = T)
  


})

observe({
  heatmapReactive()
})

heatmapReactive <- reactive({

  
  if(input$genHeatmap > 0)
  {
    isolate({
      
      logNormCounts <-log2((counts(myValues$dds, normalized=TRUE, replaced=FALSE)+.5))
      # %>%
      #   gather(gene, expression, (ncol(.)-length(input$sel_gene)+1):ncol(.))
      
      
      
      #vst = myValues$vstMat
      
      # selGroupSamples = row.names(myValues$DF[myValues$DF$Conditions %in% input$heat_group,])
      # logNormCounts = logNormCounts[,selGroupSamples]
      
      #vst = vst[,input$heat_group]
      
      myValues$heatmap_path = paste0(tempdir(),'/','heatmap-highres.pdf')
      
      if(!input$subsetGenes)
      {
        tmpsd = apply(logNormCounts,1,sd)
        
        selectGenes = rownames(logNormCounts)[order(tmpsd,decreasing=TRUE)]
        selectGenes = head(selectGenes,input$numGenes)
        
        genesNotFound = NULL
      }
      else{
        
        genes = unlist(strsplit(input$listPasteGenes,","))
        
        genes = gsub("^\\s+|\\s+$", "", genes)
        genes = gsub("\\n+$|^\\n+", "", genes)
        genes = gsub("^\"|\"$", "", genes)
        
        genes = genes[genes != ""] 
        
        genesNotFound = genes[!(genes %in% rownames(logNormCounts))]
        
        genes = genes[!(genes %in% genesNotFound)]
        
        selectGenes = genes
        
      }
      
      logNormCounts = logNormCounts[selectGenes,]
      
      return(list('logNormCounts'=logNormCounts,'genesNotFound'=genesNotFound))
    })
    
  }
 
#   
})

output$heatmapPlot <- renderPlot({
  if(!is.null(heatmapReactive()))
  {
    
    logNormCounts= heatmapReactive()$logNormCounts
    genesNotFound = heatmapReactive()$genesNotFound
    
    validate(
      need( is.null(genesNotFound) || length(genesNotFound) < 1, message = "Some genes were not found!"),
      need(nrow(logNormCounts) > 1, message = "Need atleast 2 genes to plot!")
    )
    
    
    coldata = colData(myValues$dds)
    coldata$sizeFactor = NULL
    coldata$replaceable = NULL
    
    if(input$no_replicates)
    {
      annLegend = F
      Rowv = NA
      annCol = NULL
    }
    else
    {
      annLegend = T
      Rowv = NA
      
      annCols = colnames(coldata)[ !colnames( coldata) %in% c("sizeFactor","replaceable")]
      annCol <- as.data.frame(coldata[, annCols] )
      
    }
    
    generateHeatmapPdf(logNormCounts,Rowv,annLegend, annCol)
    #dev.off()
    
    p = aheatmap(logNormCounts,scale = "none",
                  revC=TRUE,
                  fontsize = 10,
                  cexRow = 1.2,
                  Rowv = Rowv,
                  annLegend = annLegend,
                  #color = colorRampPalette( rev(brewer.pal(9, "Blues")) )(255),
                  annCol = annCol
             )
    return(p)
  }
  
  
})

generateHeatmapPdf <- function(logNormCounts,Rowv,annLegend, annCol)
{
  heatmaptmp = aheatmap(logNormCounts,scale = "none",
           revC=TRUE,
           fontsize = 10,
           cexRow = 1.2,
           Rowv = Rowv,
           annLegend = annLegend,
           #color = colorRampPalette( rev(brewer.pal(9, "Blues")) )(255),
           annCol = annCol,
           filename = myValues$heatmap_path
  )
}

# output$heatmapHighResAvailable <- reactive({
#   
#   if(is.null(heatmapReactive()))
#     return(F)
#   
#   return(file.exists(myValues$heatmap_path))
# })
# outputOptions(output, 'heatmapHighResAvailable', suspendWhenHidden=FALSE)

output$downloadHighResHeatmap <- downloadHandler(
  filename = c('heatmap_highres.pdf'),
  content = function(file) {
    
    file.copy(myValues$heatmap_path, file)
  }
)

output$heatmapData <- renderDataTable({
  if(!is.null(heatmapReactive()))
  {
    heatmapReactive()$logNormCounts
  }
}, 
options = list(scrollX = TRUE, pageLength = 5))

# 
output$heatmapComputed <- reactive({
  return(!is.null(heatmapReactive()))
})
outputOptions(output, 'heatmapComputed', suspendWhenHidden=FALSE)


output$downloadHeatmapCsv <- downloadHandler(

  filename = function() { "heatmap_data.csv"},
  content = function(file) {
    csv = heatmapReactive()$logNormCounts

    write.csv(csv, file, row.names=F)
  }

)