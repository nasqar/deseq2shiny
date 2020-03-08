
output$ddsColData <- renderTable(
  { 
    colDataTable = colData(myValues$dds)
    colsToSelect = labels(terms(design(myValues$dds)))
    if(length(colsToSelect) == 0)
      return(head( colDataTable, n = 5 ))
    
    head( colDataTable[,colsToSelect], n = 5 )
  }, bordered = TRUE, spacing = 'xs', rownames = T) 

output$ddsDesignFormula <- renderText({
  dds = myValues$dds
  paste(as.character(design(dds)))
})

  observe({
    ddsReactive()
  })
    
    ddsReactive <- eventReactive(input$run_deseq2, {
      
      dds = myValues$dds #ddsInitReactive()
      
      withProgress(message = "Running DESeq2 , please wait",{
        
        js$addStatusIcon("deseqTab","loading")
        shiny::setProgress(value = 0.4, detail = " ...")
        
        removeNotification("errorNotify")
        removeNotification("errorNotify1")
        #nasqar use 3 cores
        BiocParallel::register(MulticoreParam(3))
        
        validate(need(
          tryCatch({
            dds <- DESeq(dds, parallel = T)
          },
          error = function(e) {
            
            myValues$status = paste("DESeq2 Error: ",e$message)
            
            showNotification(id="errorNotify", myValues$status, type = "error", duration = NULL)
            showNotification(id="errorNotify1", "If this is intended, please select 'No Replicates' in Input Data step. OR use ~ 1 as the design formula", type = "error", duration = NULL)
            
            
            js$addStatusIcon("deseqTab","fail")
            
            return(NULL)
          }),
          "Error"
        )) 
        
        BiocParallel::register(SerialParam())
        
        
        if(input$computeRlog)
        {
          shiny::setProgress(value = 0.5, detail = "Calculating RLog transformation ...")
          rld <- rlog(dds)
          myValues$rld <- rld
          myValues$rlogMat <- assay(rld)
          
          myValues$rldColNames <- colnames(rld)
          
        }
        
        
        shiny::setProgress(value = 0.7, detail = "Computing Variance Stabilizing Transformation ...")
        
        vsd <- varianceStabilizingTransformation(dds)
        myValues$vsd <- vsd
        myValues$vstMat <- assay(vsd)
        
        shiny::setProgress(value = 0.8, detail = "Formatting data ...")
        
        shiny::setProgress(value = 1, detail = "...")
        
        js$addStatusIcon("deseqTab","done")
        
        myValues$dds = dds
        
        shinyjs::show(selector = "a[data-value=\"boxplotTab\"]")
        shinyjs::show(selector = "a[data-value=\"resultsTab\"]")
        shinyjs::show(selector = "a[data-value=\"heatmapTab\"]")
        shinyjs::show(selector = "a[data-value=\"vstTab\"]")
        
        if(input$computeRlog)
          shinyjs::show(selector = "a[data-value=\"rlogTab\"]")
        else
          shinyjs::hide(selector = "a[data-value=\"rlogTab\"]")
        
        
        factorChoices = colnames(colData(dds))
        factorChoices = factorChoices[!grepl("^SV[::digit::]*",factorChoices)]
        
        updateSelectInput(session, "rlogIntGroupsInput", choices = factorChoices, selected = factorChoices[1])
        updateSelectInput(session, "vsdIntGroupsInput", choices = factorChoices, selected = factorChoices[1])
        
        factorChoices = factorChoices[ !(factorChoices %in% c("sizeFactor","replaceable"))]
        
        updateSelectizeInput(session, "resultNamesInput", choices = resultsNames(dds), selected = NULL)
        updateSelectizeInput(session, "factorNameInput", choices = factorChoices, selected = factorChoices[1])
        
        
        
        disable("data_file_type")
        disable("no_replicates")
        
        js$addStatusIcon("conditionsTab","done")
      })
      
    #}
    

  })
  
  observeEvent(input$factorNameInput, {
    
    if(input$factorNameInput != "")
    {
      updateSelectInput(session,"condition1" ,choices = levels(myValues$DF[,input$factorNameInput]))
      updateSelectInput(session,"condition2" ,choices = levels(myValues$DF[,input$factorNameInput]))
    }
    
    
    
  },ignoreInit = T)
  
  
  observe({
    if(input$goto_svaTab > 0 )
      GotoTab("svaseqTab")
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
  
  output$rlogPcaPlot <- renderPlotly({
      if(!is.null(myValues$rld))
      {
        intgroups = input$rlogIntGroupsInput
        if(is.null(intgroups) | intgroups == "")
          intgroups = names(colData(myValues$dds))[1]
          
        DESeq2::plotPCA(myValues$rld, intgroup = intgroups)
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
      intgroups = input$vsdIntGroupsInput
      if(is.null(intgroups) | intgroups == "")
        intgroups = names(colData(myValues$dds))[1]
      
      DESeq2::plotPCA(myValues$vsd, intgroup = intgroups)
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

