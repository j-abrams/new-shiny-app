

if (interactive()) {
  
  server <- function(input, output, session) {
    
    vals <- reactiveValues(jdata = jdata_new)
    
    
    jdata <- reactive({
      vals$jdata %>%
        # Filter for actuals or projections based on contents of checkbox
        filter(Actuals %in% input$checkbox1)
    })
    
    jdata2 <- reactive({
      jdata() %>%
      # Use floor date to filter on Date
      filter(Date >= floor_date(input$slider1[1], unit = "months") &
               Date <= floor_date(input$slider1[2], unit = "months"))
    })
    
    
    
    observeEvent(input$file1, {
      
      receipt_data <- read.csv(input$file1$datapath) 
      
      req("Receipts" %in% names(receipt_data))
      
      receipt_data <- receipt_data %>%
        dplyr::rename("Date" = 1) %>%
        dplyr::mutate(Date = as.Date(Date, "%d/%m/%Y"),
               Actuals = "Projection") 
      
      vals$jdata <- vals$jdata %>%
        full_join(receipt_data, by = c("Date", "Actuals")) %>%
        mutate(Receipts = coalesce(Receipts.x, Receipts.y)) %>% 
        select(c(names(jdata_new)))
      
      #shinyjs::disable("file1")
      
    })
    
    observeEvent(input$file2, {
      
      disposal_data <- read.csv(input$file2$datapath) 
      
      req("Disposals" %in% names(disposal_data))
      
      disposal_data <- disposal_data %>%
        dplyr::rename("Date" = 1) %>%
        dplyr::mutate(Date = as.Date(Date, "%d/%m/%Y"),
                      Actuals = "Projection") 
      
      vals$jdata <- vals$jdata  %>%
        full_join(disposal_data, by = c("Date", "Actuals"))  %>%
        mutate(Disposals = coalesce(Disposals.x, Disposals.y)) %>% 
        select(c(names(jdata_new)))
      
    })
    
    
    observeEvent(input$checkbox1, {
    
      new_limits <- jdata()$Date
      
      updateSliderInput(session, "slider1",
                        min = as.Date(min(new_limits), "%b-%y"),
                        max = as.Date(max(new_limits), "%b-%y"),
                        value = c(as.Date(min(new_limits), "%b-%y"),
                                  as.Date(max(new_limits), "%b-%y")),
                        timeFormat = "%b-%y")
      
    }, ignoreInit = TRUE, ignoreNULL = T )
    
    output$plot <- renderPlotly({
      req(nrow(jdata2()) > 0 )
      ggplotly(
        ggplot(jdata2(), mapping = aes(x = Date, y = OutstandingCases)) +
          geom_line() +
          ggtitle("Time series for total Outstanding Cases by month")
      )
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



