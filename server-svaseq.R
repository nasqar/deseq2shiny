observe({
  svaReactive()
})

svaReactive <- eventReactive(input$runSVA, {
  
  validate(need(as.formula(input$designFormulaSva) != as.formula("~1"), "Need biological factors to estimate SVs!"))
  isolate({
    dds = ddsInitReactive()
  })
  
  
  withProgress(message = "Running SVA , please wait",{
    
    js$addStatusIcon("svaseqTab","loading")
    
    removeNotification("errorNotify")
    removeNotification("errorNotify1")
    
    validate(need(
    tryCatch({
        dds <- estimateSizeFactors(dds)
        norm.cts <- counts(dds, normalized=TRUE)
        
        ### SVA
        isolate({
          mm <- model.matrix(as.formula(input$designFormulaSva), colData(dds))
          mm0 <- model.matrix(~ 1, colData(dds))
          norm.cts <- norm.cts[rowSums(norm.cts) > 0,]
          svafit <- svaseq(norm.cts, mod=mm, mod0=mm0, n.sv=input$numSVA)
          
          svNames = paste0("SV", 1:ncol(svafit$sv))
          
          for(i in 1:length(svNames))
            colData(dds)[,svNames[i]] <- svafit$sv[,i] 
          
          varNames = colnames(colData(dds))
          varNames = varNames[varNames != "sizeFactor"]
          
          svaFormula = paste("~", paste( rev(varNames), collapse="+"))
          
          myValues$ddsSva = dds
          
          updateTextInput(session, "newFormulaSva", value = svaFormula)
          updateSelectInput(session, "xaxisSva", choices = colnames(colData(dds)), selected = "SV1")
          updateSelectInput(session, "yaxisSva", choices = colnames(colData(dds)), selected = "SV2")
          updateSelectInput(session, "colorBy", choices = colnames(colData(dds)), selected = colnames(colData(dds))[1])
          
          updateSelectizeInput(session, "varsToRegress", choices = colnames(colData(dds)), selected = c("SV1","SV2"))
          
          updateSelectizeInput(session, "factorNameInputSva", choices = colnames(colData(dds)), selected = colnames(colData(dds))[1])
          
          js$addStatusIcon("svaseqTab","done")
          return(list('svafit'=svafit,'ddsSva'=dds))
          
        })
        

    },
    error = function(e) {
      myValues$status = paste("SVA Error: ",e$message)

      showNotification(id="errorNotify", myValues$status, type = "error", duration = NULL)
      #showNotification(id="errorNotify1", "If this is intended, please select 'No Replicates' in Input Data step. OR use ~ 1 as the design formula", type = "error", duration = NULL)

      js$addStatusIcon("svaseqTab","fail")

      return(NULL)
    })
    ,
      "Error"
    ))
    
  })
  
  
})

output$svaText = renderText({
  
  validate(need(as.formula(input$designFormulaSva) != as.formula("~1"), "Cannot use ~ 1 to estimate SVs. Biological factors are required!"))
  
  return(paste("Using biological factors:", input$designFormulaSva,"to estimate Surrogate Variables (SVs)"))
})

output$svaPlot <- renderPlotly({
  dds = svaReactive()$ddsSva
  
  if(!is.null(dds))
  {
    
    df = as.data.frame(colData(dds))
    
    xaxis = input$xaxisSva
    yaxis = input$yaxisSva
    colorBy = input$colorBy
    
    if(xaxis == "" && yaxis == "" && colorBy == "")
    {
      xaxis = colnames(df)[1]
      yaxis = colnames(df)[1]
      colorBy = colnames(df)[1]
    }
    
    ggplot(df, aes_string(xaxis,yaxis, col = colorBy)) + 
        geom_point() + 
        geom_text(aes(label = rownames(df)),hjust=0, vjust=0)
    
  }
  
})


observeEvent(input$regressVarsBatch,ignoreInit = TRUE,{
  withProgress(message = "Removing batch effect, this may take a long time.",{
  dds = myValues$ddsSva
  
  svaFormula = as.formula(input$newFormulaSva)
  
  design(dds) <- svaFormula
  
  BiocParallel::register(MulticoreParam(3))
  
  shiny::setProgress(value = 0.3, detail = "Running DESeq ...")
  dds <- DESeq(dds, parallel = T)
  
  shiny::setProgress(value = 0.6, detail = "Computing VST matrix ...")
  vsd <- varianceStabilizingTransformation(dds)
  
  shiny::setProgress(value = 0.8, detail = "limma::removeBatchEffect ...")
  assay(vsd) <- limma::removeBatchEffect(assay(vsd), covariates = colData(dds)[,input$varsToRegress])
  
  
  myValues$vsdSva = vsd
  myValues$ddsAddSV = dds
  
  })
})


output$pcaSvaPlot = renderPlotly({
  
  validate(need(length(input$factorNameInputSva) > 0 ,"Need at least one condition!"))
  
  vsd = myValues$vsdSva
  
  if(!is.null(vsd))
  {
    DESeq2::plotPCA(vsd, intgroup = input$factorNameInputSva)
  }
})

output$pcaSvaAvailable <- reactive({
    return(!is.null(myValues$vsdSva))
  })
outputOptions(output, 'pcaSvaAvailable', suspendWhenHidden=FALSE)

output$ddsSvaAvailable <- reactive({
  return(!is.null(svaReactive()$ddsSva))
})
outputOptions(output, 'ddsSvaAvailable', suspendWhenHidden=FALSE)

output$varsToIncludeInDeseq = renderText({
  return("")
})

observe({
  if(input$runDeseqWithSVs > 0 )
  {
    #
    #myValues$DF = colData(myValues$ddsAddSV)
    myValues$dds = myValues$ddsAddSV
    
    GotoTab("deseqTab")
  }
    
})

observe({
  if(input$runDeseqWithoutSVs > 0 )
  {
    myValues$dds = ddsInitReactive()
    GotoTab("deseqTab")
  }
})
