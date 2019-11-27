observe({
  ddsReactive()
})


  ddsReactive <- reactive({
    
    if(input$run_deseq2 > 0)
    {
      withProgress(message = "Running DESeq2 , please wait",{
        
        removeNotification("errorNotify")
        removeNotification("errorNotify1")
        
        myValues$status = NULL
        myValues$dds = NULL
        
        #shinyjs::show(selector = "a[data-value=\"deseqTab\"]")
        js$addStatusIcon("conditionsTab","loading")
        
        
        
        
        samples <- myValues$DF
        dataCounts <- myValues$dataCounts
        
        rownames(samples) = samples$Samples
        samples$Samples = NULL
        
        isolate({
          if(input$no_replicates)
            dds <- DESeqDataSetFromMatrix(dataCounts, colData=samples,design = ~ 1)
          else
            dds <- DESeqDataSetFromMatrix(dataCounts, colData=samples,design = ~ Conditions)
        })
        
        shiny::setProgress(value = 0.2, detail = "...")
        
        #BiocParallel::register(MulticoreParam(detectCores() / 2))
        #nasqar use 3 cores
        BiocParallel::register(MulticoreParam(3))
        
        validate(need(
          tryCatch({
            dds <- DESeq(dds, parallel = T)
          },
          error = function(e) {
            
            myValues$status = paste("DESeq2 Error: ",e$message)
            
            showNotification(id="errorNotify", myValues$status, type = "error", duration = NULL)
            showNotification(id="errorNotify1", "If this is intended, please select 'No Replicates' in Input Data step.", type = "error", duration = NULL)
            
            shinyjs::hide(selector = "a[data-value=\"deseqTab\"]")
            shinyjs::hide(selector = "a[data-value=\"rlogTab\"]")
            shinyjs::hide(selector = "a[data-value=\"vstTab\"]")
            
            shinyjs::hide(selector = "a[data-value=\"resultsTab\"]")
            shinyjs::hide(selector = "a[data-value=\"boxplotTab\"]")
            shinyjs::hide(selector = "a[data-value=\"heatmapTab\"]")
            
            js$addStatusIcon("conditionsTab","done")
            
            return(NULL)
          }),
          "Error"
        )) 
        
        BiocParallel::register(SerialParam())
        
        shiny::setProgress(value = 0.4, detail = "Calculating rlog matrix ...")
        
        rld <- rlog(dds)
        myValues$rld <- rld
        myValues$rlogMat <- assay(rld)
        
        myValues$rldColNames <- colnames(rld)
        
        shiny::setProgress(value = 0.6, detail = "Variance Stabilizing Transformation ...")
        
        vsd <- varianceStabilizingTransformation(dds)
        myValues$vsd <- vsd
        myValues$vstMat <- assay(vsd)
        
        shiny::setProgress(value = 0.7, detail = "Formatting data ...")
        
        counts = as.data.frame(counts(dds))
        counts$genes = rownames(counts)
        countlong = reshape2::melt(counts,variable.name = "sampleid",value.name="count")
        countlong = countlong[order(countlong$genes,countlong$sampleid),]
        
        flatRlog = as.data.frame(myValues$rlogMat)
        flatRlog$genes = rownames(flatRlog)
        flatRlog = reshape2::melt(flatRlog,variable.name = "sampleid",value.name="rlog")
        flatRlog = flatRlog[order(flatRlog$genes,flatRlog$sampleid),]
        
        flatVst = as.data.frame(myValues$vstMat)
        flatVst$genes = rownames(flatVst)
        flatVst = reshape2::melt(flatVst,variable.name = "sampleid",value.name="vst")
        flatVst = flatVst[order(flatVst$genes,flatVst$sampleid),]
        
        boxplotData = countlong
        boxplotData$rlog = flatRlog$rlog
        boxplotData$vst = flatVst$vst
        
        samples <- myValues$DF
        
        # faster code
        new = boxplotData
        new[] <- lapply(boxplotData, function(x) samples$Conditions[match(x, samples$Samples)])
        boxplotData$group = as.character(new$sampleid)
        
        # boxplotData$group = unlist(lapply(boxplotData$sampleid, function(x){
        #   samples[samples$Samples == x,]$Conditions
        # }))
        
        myValues$boxplotData = boxplotData
        
        shiny::setProgress(value = 1, detail = "...")
        
        myValues$dds = dds
        
        shinyjs::show(selector = "a[data-value=\"boxplotTab\"]")
        shinyjs::show(selector = "a[data-value=\"resultsTab\"]")
        shinyjs::show(selector = "a[data-value=\"heatmapTab\"]")
        shinyjs::show(selector = "a[data-value=\"vstTab\"]")
        shinyjs::show(selector = "a[data-value=\"rlogTab\"]")
        
        #shinyjs::hide(selector = "a[data-value=\"deseqTab\"]")
        
        
        updateSelectInput(session,"condition1" ,choices = myValues$DF$Conditions)
        updateSelectInput(session,"condition2" ,choices = myValues$DF$Conditions)
        
        js$addStatusIcon("conditionsTab","done")
      })
      
    }
    

  })

  output$rlogData <- renderDataTable({
    if(!is.null(myValues$rlogMat))
    {
      
      myValues$rlogMat
    }
  }, 
  options = list(scrollX = TRUE, pageLength = 5))
  
  output$rlogPlot <- renderPlotly({
    if(!is.null(myValues$rlogMat))
    {
      sampleDists <- dist(t(myValues$rlogMat))

      sampleDistMatrix <- as.matrix(sampleDists)
      rownames(sampleDistMatrix) <- paste(myValues$rldColNames)
      colnames(sampleDistMatrix) <- NULL
      colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
      # rlogHeat = pheatmap(sampleDistMatrix,clustering_distance_rows=sampleDists,clustering_distance_cols=sampleDists,col=colors)
      #browser()
      # rlogHeat
      heatmaply::heatmaply(sampleDistMatrix, showticklabels = c(F,T))
    }


  })
  
  
  # observe({
  #   rlogPlotReactive()
  # })
  # rlogPlotReactive <- reactive({
  #   if(!is.null(myValues$rlogMat))
  #   {
  #     sampleDists <- dist(t(myValues$rlogMat))
  # 
  #     sampleDistMatrix <- as.matrix(sampleDists)
  #     rownames(sampleDistMatrix) <- paste(myValues$rldColNames)
  #     colnames(sampleDistMatrix) <- NULL
  #     colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
  #     pheatmap(sampleDistMatrix,clustering_distance_rows=sampleDists,clustering_distance_cols=sampleDists,col=colors,filename = "rlogheatmap.png")
  # 
  #     return(list(
  #       src = paste0("rlogheatmap.png"),
  #       filetype = "image/png",
  #       alt = "pathview image"
  #     ))
  #   }
  # })
  # 
  # 
  # 
  # output$rlogPlot <- renderPlot({
  #   rlogPlotReactive()
  # })

  output$rlogPcaPlot <- renderPlotly({
    if(!is.null(myValues$rld))
    {
      DESeq2::plotPCA(myValues$rld, intgroup = c("Conditions"))
    }


  })

  
  output$vsdPlot <- renderPlotly({
    
    if(!is.null(myValues$vstMat))
    {
      sampleDists <- dist(t(myValues$vstMat))
      sampleDistMatrix <- as.matrix(sampleDists)
      rownames(sampleDistMatrix) <- paste(myValues$rldColNames)
      colnames(sampleDistMatrix) <- NULL
      colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
      # vstHeat <- pheatmap(sampleDistMatrix,clustering_distance_rows=sampleDists,clustering_distance_cols=sampleDists,col=colors)
      # vstHeat
      
      heatmaply::heatmaply(sampleDistMatrix, showticklabels = c(F,T))
    }
    
    
  })
  
  output$vsdPcaPlot <- renderPlotly({
    if(!is.null(myValues$vsd))
    {
      DESeq2::plotPCA(myValues$vsd, intgroup = c("Conditions"))
    }
    
    
  })
  
  output$vsdData <- renderDataTable({
    if(!is.null(myValues$vstMat))
    {
      
      myValues$vstMat
      
    }
  }, 
  options = list(scrollX = TRUE, pageLength = 5))
  
  output$downloadRlogCsv <- downloadHandler(
    
    filename = function() {paste0("rlog",".csv")},
    content = function(file) {
      csv = myValues$rlogMat
      
      write.csv(csv, file, row.names=T)
    }
    
  )
  
  output$downloadVsdCsv <- downloadHandler(
    
    filename = function() {paste0("vsd",".csv")},
    content = function(file) {
      csv = myValues$vstMat
      
      write.csv(csv, file, row.names=T)
    }
    
  )

  output$ddsComputed <- reactive({
    return(!is.null(myValues$dds))
  })
  outputOptions(output, 'ddsComputed', suspendWhenHidden=FALSE)
  
  output$deseqError <- reactive({
    return(!is.null(myValues$status))
  })
  outputOptions(output, 'deseqError', suspendWhenHidden=FALSE)

