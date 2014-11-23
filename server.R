require(shiny)

# Runs once when the app is started
yahURL <- "http://ichart.finance.yahoo.com/table.csv?s="

# Charts' common params
myplot <- function(...) plot(..., type="l", col="#66afe9", lwd="2",
          col.axis="grey", las=1)

shinyServer(function(input, output) {
    
  # Reactive stuff runs every time the user changes an input
  histdata <- reactive({

    input$newTicker # Reactive when Update button is clicked, not on other inputs
    isolate( # Isolates all inputs except the Update button
      
      # Basic error handler to suppress ugly errors if data is not available
      tryCatch({
        d<-read.csv(paste(yahURL,input$ticker,sep="")) # reads stock data from Yahoo
        d$Date<-as.Date(as.character(d$Date))
        d<-d[order(d$Date),] # Yahoo data comes in inverse date order..
        d
      }, warning = function(w) {
      }, error = function(e) {
      }, finally = {
      })
    )
    
  })

  output$stockchart <- renderPlot({
    if (length(histdata())>0) { # Procees only if data download was successful
      
      data<-histdata()
      
      # select data for specified date interval
      data<-data[(data$Date>=input$startdate & data$Date<=input$enddate),]
      
      x<-data$Date
      
      # Calculate cumulative returns based on daily close or daily adjusted close
      if (input$adj) y<-data$Adj.Close/data$Adj.Close[1]
      else y<-data$Close/data$Close[nrow(data)]
      
      myplot(x,(y-1)*100, main=paste(input$ticker, "'s cumulative returns between ", input$startdate, " and ", input$enddate,sep=""), xlab="", ylab="% Return")
    }
  })
  
  output$volumechart <- renderPlot({
    if (length(histdata())>0) {
      
      data<-histdata()
      
      data<-data[(data$Date>=input$startdate & data$Date<=input$enddate),]
      
      x<-data$Date
      y<-data$Volume/1000000 # in million shares
      
      myplot(x,y, main=paste(input$ticker, "'s trading volume (millions) between ", input$startdate, " and ", input$enddate,sep=""), xlab="", ylab="Million Shares")
    }
  })

  output$rangechart <- renderPlot({
    if (length(histdata())>0) {
      
      data<-histdata()
      
      data<-data[(data$Date>=input$startdate & data$Date<=input$enddate),]
      
      x<-data$Date
      y<-(data$High-data$Low)/data$Close # Percentage difference
      
      myplot(x,y*100, main=paste(input$ticker, "'s daily percentage range between ", input$startdate, " and ", input$enddate,sep=""), xlab="", ylab="% Range")
    }
  })
  
  output$message <- renderText({ # Purely for error handling
    
    input$newTicker  # React to Update button only
    isolate(
      # Tell the user if we weren't able to get data for the specified ticker
      if (length(histdata())==0 & nchar(input$ticker)>0) paste("Sorry, data is not available for ", input$ticker )
    )
    
  })
  
})
