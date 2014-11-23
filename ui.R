require(shiny)

shinyUI(fluidPage(title="Stock Chart",
  wellPanel(
    h3("Stock Chart"),
    p("An application to visualize equity returns, trading volume and trading range over a period of time"),
    p("Source available at", a("https://github.com/mmascherpa/StockChart",href="https://github.com/mmascherpa/StockChart"))
  ),
  
  helpText(
    strong("Instructions"),
    withTags(ol(
      li("Type a stock ticker e.g. 'AAPL' or 'GOOG' in the Stock Symbol text field"),
      li("Click on the Update Button"),
      li("Navigate the available charts by using the tabs"),
      li("Use the date inputs to visualize data for a specific interval of time"),
      li("Toggle the utilization of adjusted closing prices for returns by using the checkbox")
      ))
    ),
  
  sidebarLayout(
    
    sidebarPanel(
      inputPanel(
        verticalLayout(
        textInput(label="Stock Symbol","ticker"),
        actionButton("newTicker","Update")
        )
      ),
      inputPanel(
        verticalLayout(
        dateInput("startdate", "Start Date", value=Sys.Date()-365 ),
        dateInput("enddate", "End Date", value=Sys.Date()),
        checkboxInput("adj", "Use adjusted Close", value = TRUE)
        )
      ),
      width=4
    ),
    
    mainPanel(
      textOutput("message"),
      tabsetPanel(
        tabPanel("Cumulative Returns", plotOutput("stockchart")),
        tabPanel("Trading Volume", plotOutput("volumechart")),
        tabPanel("Daily Range", plotOutput("rangechart"))
      ),
      width=8
    )
  )

))
