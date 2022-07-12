

if (interactive()) {
  
  server <- function(input, output, session) {
    
    
    jdata <- reactive({
      jdata_new %>%
        filter(Actuals %in% input$checkbox1)
    })
    
    jdata2 <- reactive({
      jdata() %>%
      # Use floor date to filter on Date
      filter(Date >= floor_date(input$slider1[1], unit = "months") &
               Date <= floor_date(input$slider1[2], unit = "months"))
    })
    
    
    observeEvent(input$checkbox1, {
    
     
      
      # Don't break the slider input
      req(length(input$checkbox1) > 0)
      updateSliderInput(session, "slider1", 
                        label = "Date:",
                        min = as.Date(min(jdata()$Date), "%b-%y"),
                        max = as.Date(max(jdata()$Date), "%b-%y"),
                        value = c(as.Date(min(jdata()$Date), "%b-%y"),
                                  as.Date(max(jdata()$Date), "%b-%y")),
                        timeFormat = "%b-%y")
      
    }, ignoreInit = TRUE, ignoreNULL = FALSE )
    
    
    output$plot <- renderPlot({
      
      req(jdata2())
      
      ggplot(jdata2(), mapping = aes(x = Date, y = OutstandingCases)) +
        geom_line()
    })
    
    output$table <- renderTable({
        
      if (nrow(jdata2()) == 0) {
        "Please select Actuals or Projections from above"
      } else {
        jdata2() %>%
          mutate(Date = format(Date, "%b-%y")) 
      }
      
    })
    
    
  }
  
}



