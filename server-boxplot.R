observe({
  updateSelectizeInput(session,'sel_gene',
                       choices= rownames(myValues$dataCounts),
                       server=TRUE)
  
  tmpgroups = unique(myValues$DF$Conditions)
  updateCheckboxGroupInput(session,'sel_group',
                           choices=tmpgroups, selected=tmpgroups)
  
  
})

observe({
  geneExrReactive()
})

geneExrReactive <- reactive({

  # if(input$genBoxplot > 0)
  # {
  #   isolate({
      validate(need(length(input$sel_gene)>0,"Please select a gene."))
      validate(need(length(input$sel_group)>0,"Please select group(s)."))
      
      # if(input$counttype == "counts")
      #   counts = as.data.frame(counts(myValues$dds))
      # if(input$counttype == "rlog")
      #   counts = as.data.frame(myValues$rlogMat)
      # if(input$counttype == "vst")
      #   counts = as.data.frame(myValues$vstMat)
      
      
      # counts$genes = as.character(rownames(counts))
      # 
      # countlong = reshape2::melt(counts,variable.name = "sampleid",value.name="count")
      # 
      # samples <- myValues$DF
      # countlong$group = unlist(lapply(countlong$sampleid, function(x){
      #   samples[samples$Samples == x,]$Conditions
      # }))
      
      # countlong$group = gsub("_[0-9]+","",countlong$sampleid)
      
      countlong = myValues$boxplotData
      
      filtered = countlong[countlong$genes %in% input$sel_gene,]
      filtered = filtered[filtered$group %in% input$sel_group,]
      
      
      return(filtered)
  #   })
  # }
  #     
    
})

output$boxPlot <- renderPlotly({
  if(!is.null(geneExrReactive()))
  {
    filtered = geneExrReactive()
    
    if(input$counttype == "counts")
      filtered$y = filtered$count
    if(input$counttype == "rlog")
      filtered$y = filtered$rlog
    if(input$counttype == "vst")
      filtered$y = filtered$vst
    
    ## Adapted from STARTapp dotplot
    
    p <- ggplot(filtered,aes(x=group,y=y,fill=group)) + geom_boxplot()
    
    p <- p + facet_grid(.~ genes,scales = "free_y")+
      geom_point(size=3,aes(text = paste("group:", group))) + 
      stat_summary(fun.y=mean,geom="point",shape=5,size=3,fill=1)
    
    countlong = myValues$boxplotData
    
    sel_group = as.character(unique(countlong$group))
    p <- p + scale_fill_discrete(name="group",breaks=sel_group,
                                 labels=sel_group,
                                 guide=guide_legend(keyheight=4,keywidth=2))
    
    p <- p + theme_base() + ylab(" ") + xlab(" ")+theme(
      plot.margin = unit(c(1,1,1,1), "cm"),
      axis.text.x = element_text(angle = 45),
      legend.position="bottom")+theme(legend.position="none")
    
    p
    
  }
  
  
})

output$boxplotData <- renderDataTable({
  if(!is.null(geneExrReactive()))
  {
    geneExrReactive()
  }
}, 
options = list(scrollX = TRUE, pageLength = 5))


output$boxplotComputed <- reactive({
  return(!is.null(geneExrReactive()))
})
outputOptions(output, 'boxplotComputed', suspendWhenHidden=FALSE)


# output$downloadBoxCsv <- downloadHandler(
#   
#   filename = function() {paste0(input$condition1,"_vs_",input$condition2,".csv")},
#   content = function(file) {
#     csv = geneExrReactive()
#     
#     write.csv(csv, file, row.names=F)
#   }
#   
# )