

if (interactive()) {
  
  server <- function(input, output, session) {
    
  
    vals <- reactiveValues()
    observe({
      vals$jdata <- jdata_new %>%
        filter(Actuals %in% input$checkbox1)
      
      print(min(vals$jdata$Date))
    })
    
    
    observeEvent(input$checkbox1, {
      
      require(length(input$checkbox1) > 0)
      
      vals$jdata <- jdata_new %>%
        filter(Actuals %in% input$checkbox1)
      
      updateSliderInput(session, "slider1", 
                        label = "Date:",
                        min = as.Date(min(vals$jdata$Date), "%b-%y"),
                        max = as.Date(max(vals$jdata$Date), "%b-%y"),
                        value = c(as.Date(min(vals$jdata$Date), "%b-%y"),
                                  as.Date(max(vals$jdata$Date), "%b-%y")),
                        timeFormat = "%b-%y")
    }, ignoreInit = TRUE )
    
    
    output$text = renderPrint(floor_date(input$slider1, unit = "months"))
    
    output$table <- renderTable({
      jdata_new %>%
        # Choose whether to display either actuals or projections, or both
        filter(Actuals %in% input$checkbox1) %>%
        select(-Actuals) %>%
        # Use floor date to filter on Date
        filter(Date >= floor_date(input$slider1[1], unit = "months") & 
               Date <= floor_date(input$slider1[2], unit = "months")) %>%
        mutate(Date = format(Date, "%b-%y"))
    })
    
    
  }
  
}



