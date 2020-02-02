observe({
  ddsReactive()
})


  ddsReactive <- eventReactive(input$run_deseq2, {
    
    # if(input$run_deseq2 > 0)
    # {
      withProgress(message = "Running DESeq2 , please wait",{
        
        removeNotification("errorNotify")
        removeNotification("errorNotify1")
        shinyjs::hide(selector = "a[data-value=\"deseqTab\"]")
        shinyjs::hide(selector = "a[data-value=\"rlogTab\"]")
        shinyjs::hide(selector = "a[data-value=\"vstTab\"]")

        shinyjs::hide(selector = "a[data-value=\"resultsTab\"]")
        shinyjs::hide(selector = "a[data-value=\"boxplotTab\"]")
        shinyjs::hide(selector = "a[data-value=\"heatmapTab\"]")
        
        myValues$status = NULL
        myValues$dds = NULL
        
        #shinyjs::show(selector = "a[data-value=\"deseqTab\"]")
        js$addStatusIcon("conditionsTab","loading")
        
        myValues$DF = hot_to_r(input$table)
      
        samples <- myValues$DF
        dataCounts <- myValues$dataCounts
        
        rownames(samples) = samples$Samples
        samples$Samples = NULL
        
        # convert factors to unordered
        #factor(samples, ordered = F)
        
        
        for (i in 1:ncol(samples)) {
          if(all(class(samples[,i]) %in% c("ordered","factor")))
            samples[,i] = factor(samples[,i], ordered = F)
        }
        
        isolate({
          # if(input$no_replicates)
          #   dds <- DESeqDataSetFromMatrix(dataCounts, colData=samples,design = ~ 1)
          # else
          #   dds <- DESeqDataSetFromMatrix(dataCounts, colData=samples,design = ~ Conditions)
          validate(need(
            tryCatch({
                  dds <- DESeqDataSetFromMatrix(dataCounts, colData=samples,design = as.formula(input$designFormula))
            },
            error = function(e)
            {
              myValues$status = paste("DESeq2 Error: ",e$message)
              
              showNotification(id="errorNotify", myValues$status, type = "error", duration = NULL)
              showNotification(id="errorNotify1", "Fix design formula OR Factors/Conditions", type = "error", duration = NULL)
              
              # shinyjs::hide(selector = "a[data-value=\"deseqTab\"]")
              # shinyjs::hide(selector = "a[data-value=\"rlogTab\"]")
              # shinyjs::hide(selector = "a[data-value=\"vstTab\"]")
              # 
              # shinyjs::hide(selector = "a[data-value=\"resultsTab\"]")
              # shinyjs::hide(selector = "a[data-value=\"boxplotTab\"]")
              # shinyjs::hide(selector = "a[data-value=\"heatmapTab\"]")
              
              js$addStatusIcon("conditionsTab","fail") 
            }
            ),
            "Error"
          )) 
            
          
          
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
            showNotification(id="errorNotify1", "If this is intended, please select 'No Replicates' in Input Data step. OR use ~ 1 as the design formula", type = "error", duration = NULL)
            
            # shinyjs::hide(selector = "a[data-value=\"deseqTab\"]")
            # shinyjs::hide(selector = "a[data-value=\"rlogTab\"]")
            # shinyjs::hide(selector = "a[data-value=\"vstTab\"]")
            # 
            # shinyjs::hide(selector = "a[data-value=\"resultsTab\"]")
            # shinyjs::hide(selector = "a[data-value=\"boxplotTab\"]")
            # shinyjs::hide(selector = "a[data-value=\"heatmapTab\"]")
            
            js$addStatusIcon("conditionsTab","fail")
            
            return(NULL)
          }),
          "Error"
        )) 
        
        BiocParallel::register(SerialParam())
        
        
        
        if(input$computeRlog)
        {
          shiny::setProgress(value = 0.4, detail = "Calculating RLog transformation ...")
          rld <- rlog(dds)
          myValues$rld <- rld
          myValues$rlogMat <- assay(rld)
          
          myValues$rldColNames <- colnames(rld)
          
          # flatRlog = as.data.frame(myValues$rlogMat)
          # flatRlog$genes = rownames(flatRlog)
          # flatRlog = reshape2::melt(flatRlog,variable.name = "sampleid",value.name="rlog")
          # flatRlog = flatRlog[order(flatRlog$genes,flatRlog$sampleid),]
        }
        
        
        shiny::setProgress(value = 0.6, detail = "Computing Variance Stabilizing Transformation ...")
        
        vsd <- varianceStabilizingTransformation(dds)
        myValues$vsd <- vsd
        myValues$vstMat <- assay(vsd)
        
        shiny::setProgress(value = 0.7, detail = "Formatting data ...")
        
        # counts = as.data.frame(counts(dds))
        # counts$genes = rownames(counts)
        # countlong = reshape2::melt(counts,variable.name = "sampleid",value.name="count")
        # countlong = countlong[order(countlong$genes,countlong$sampleid),]
        # 
        # 
        # 
        # flatVst = as.data.frame(myValues$vstMat)
        # flatVst$genes = rownames(flatVst)
        # flatVst = reshape2::melt(flatVst,variable.name = "sampleid",value.name="vst")
        # flatVst = flatVst[order(flatVst$genes,flatVst$sampleid),]
        # 
        # countsNorm = as.data.frame(log2((counts(dds, normalized = T) +.5)))
        # countsNorm$genes = rownames(countsNorm)
        # countlongNorm = reshape2::melt(countsNorm,variable.name = "sampleid",value.name="count")
        # countlongNorm = countlongNorm[order(countlongNorm$genes,countlongNorm$sampleid),]
        
        # samples <- myValues$DF
        
        
        
        
        shiny::setProgress(value = 1, detail = "...")
        
        myValues$dds = dds
        
        shinyjs::show(selector = "a[data-value=\"boxplotTab\"]")
        shinyjs::show(selector = "a[data-value=\"resultsTab\"]")
        shinyjs::show(selector = "a[data-value=\"heatmapTab\"]")
        shinyjs::show(selector = "a[data-value=\"vstTab\"]")
        
        if(input$computeRlog)
          shinyjs::show(selector = "a[data-value=\"rlogTab\"]")
        
        
        
        updateSelectizeInput(session, "resultNamesInput", choices = resultsNames(dds), selected = "Intercept")
        updateSelectizeInput(session, "factorNameInput", choices = colnames(myValues$DF), selected = colnames(myValues$DF)[1])
        
        choices = colnames(colData(dds))[ !colnames( colData(dds)) %in% c("replaceable")]
        updateSelectInput(session, "rlogIntGroupsInput", choices = choices, selected = choices[1])
        updateSelectInput(session, "vsdIntGroupsInput", choices = choices, selected = choices[1])
        
        disable("data_file_type")
        disable("no_replicates")
        #updateSelectInput(session, "boxPlotGroupsInput", choices = names(colData(dds)), selected = names(colData(dds))[1])
        # updateSelectInput(session,"condition1" ,choices = myValues$DF$Conditions)
        # updateSelectInput(session,"condition2" ,choices = myValues$DF$Conditions)
        
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

