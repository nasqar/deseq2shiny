observe({
  
  # Hide the loading message when the rest of the server function has executed
  hide(id = "loading-content", anim = TRUE, animType = "fade")
  
  removeClass("app-content", "hidden")
  
  shinyjs::hide(selector = "a[data-value=\"conditionsTab\"]")
  shinyjs::hide(selector = "a[data-value=\"deseqTab\"]")
  shinyjs::hide(selector = "a[data-value=\"resultsTab\"]")
  shinyjs::hide(selector = "a[data-value=\"boxplotTab\"]")
  shinyjs::hide(selector = "a[data-value=\"heatmapTab\"]")
  
  # Check if example selected, or if not then ask to upload a file.
  
  # shiny:: validate(
  #   need((input$data_file_type=="examplecounts")|((!is.null(input$rdatafile))|(!is.null(input$datafile))),
  #        message = "Please select a file")
  # )
  # inFile <- input$datafile
  
  inputFileReactive()
  
})


decryptUrlParam = function (cipher)
{
  keyHex <- readr::read_file("private.txt")
  
  key = hex2bin(keyHex)
  cipher = hex2bin(cipher)
  
  orig <- simple_decrypt(cipher, key)
  
  unserialize(orig)
}


inputFileReactive <- reactive({
  
  query <- parseQueryString(session$clientData$url_search)
  
  # Check if example selected, or if not then ask to upload a file.
  shiny:: validate(
    need( identical(input$data_file_type,"examplecounts")|(!is.null(input$datafile))|(!is.null(query[['countsdata']])),
          message = "Please select a file")
  )
  
  if (!is.null(query[['countsdata']])) {
    inFile = decryptUrlParam(query[['countsdata']])
    
    shinyjs::show(selector = "a[data-value=\"inputdata\"]")
    shinyjs::disable("datafile")
    js$collapse("uploadbox")
    
  }
  else if(input$data_file_type=="countsFile")
  {
    inFile <- input$datafile
    if (is.null(inFile))
      return(NULL)
    
    inFile = inFile$datapath
  }
  else if(input$data_file_type=="examplecounts")
  {
    inFile = "www/wang_count_table.csv"
    updateCheckboxInput(session, "no_replicates", value = "true")
  }
  
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
  dataCounts <- fileContent[,sampleN]
  dataCounts <- data.frame(sapply( dataCounts, as.integer ))
  row.names(dataCounts) <- fileContent[,1]
  myValues$dataCounts = as.matrix(dataCounts)
  
  js$collapse("uploadbox")
  return(dataCounts)
})

output$contents <- renderDataTable({
  tmp <- inputFileReactive()
  #test = myValues$dataCounts
  if(!is.null(tmp)) myValues$dataCounts
  
}, 
options = list(scrollX = TRUE))


observeEvent(input$prefilterCounts,ignoreInit = TRUE,{
  
    dataCounts = inputFileReactive()
    dataCounts <- dataCounts[rowSums(dataCounts) >= input$minRowCount, ]
    myValues$dataCounts = dataCounts
})

myValues <- reactiveValues()

observe({
  csvDataReactive()
})

csvDataReactive <- eventReactive(input$submit,{
  
  fileContent = inputFileReactive()
  
  shinyjs::show(selector = "a[data-value=\"conditionsTab\"]")
  shinyjs::runjs("window.scrollTo(0, 0)")
  
  sampleN = colnames(fileContent)
  
  if(input$no_replicates)
    sampleConditions = sampleN
  else
  {
    sampleConditions = strsplit(sampleN,"_")
    sampleConditions = unlist(lapply(sampleConditions, function(x){ x[1]}))
  }
  
  #samples <- data.frame(row.names = sampleN, condition = sampleConditions)
  samples <- data.frame(Samples = sampleN, Conditions = sampleConditions)

  
  #myValues$countsData = fileContent
  
  myValues$DF = samples
  
  return(list('countsData' = fileContent))
  
})

output$fileUploaded <- reactive({
  return(!is.null(inputFileReactive()))
})
outputOptions(output, 'fileUploaded', suspendWhenHidden=FALSE)

output$noreplicates <- reactive({
  return(input$no_replicates)
})
outputOptions(output, 'noreplicates', suspendWhenHidden=FALSE)
