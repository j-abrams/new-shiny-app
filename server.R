

server <- function(input, output) {
  

  vals <- reactiveValues()
  observe({
    vals$jdata <- jdata_new %>%
      filter(Actuals %in% input$checkbox1)
    
    print(min(vals$jdata$Date))
  })
  
  
  output$text = renderPrint(input$slider1)
  
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

