



if (interactive()) {
  
  server <- function(input, output, session) {
    
    # Initiate
    vals <- reactiveValues(jdata = jdata_new)
    
    # Checkbox functionality for filtering
    jdata <- reactive({
      vals$jdata %>%
        # Filter for actuals or projections based on contents of checkbox
        filter(Actuals %in% input$checkbox1)
    })
    
    # Integrate the date slider functionality
    jdata2 <- reactive({
      jdata() %>%
      # Use floor date to filter on Date
      filter(Date >= floor_date(input$slider1[1], unit = "months") &
               Date <= floor_date(input$slider1[2], unit = "months"))
    })
    
    # Call this function to update our reactive plot in the renderPlotly command
    jdata_selected <- reactive({
      jdata2() %>%
        pivot_longer(c("Receipts", "Disposals", "OutstandingCases"),
                     names_to = "Category", values_to = "Total") %>%
        filter(Category %in% input$picker1) %>%
        mutate(Total2 = ifelse(Actuals == "Actual", Total, NA)  )
    })
        
    
    # Calculate OutstandingCases from Receipts and Sitting Days
    jdata_update <- reactive({
      vals$jdata %>%
        dplyr::mutate(
          Disposals = ifelse(Actuals == "Projection", `Sitting Days` * input$numeric, Disposals),
          diff = ifelse(Actuals == "Projection", Receipts - Disposals,  0),
          OutstandingCases = ifelse(Actuals == "Projection",
                                    cumsum(diff) + last_outstanding_val, 
                                    OutstandingCases))  %>%
        select(-diff)
    })
    
    
    # Define what happens when a new receipts input file is uploaded to the app
    observeEvent(input$file1, {
      
      # Read contents from $datapath
      receipt_data <- read.csv(input$file1$datapath) 
      
      # Check to see whether the right receipts file has been uploaded
      req("Receipts" %in% names(receipt_data))
      
      receipt_data <- receipt_data %>%
        dplyr::rename("Date" = 1) %>%
        dplyr::mutate(Date = as.Date(Date, "%d/%m/%Y"),
               Actuals = "Projection") 
      
      # Re-assign vals$jdata with the latest receipts forecasts
      vals$jdata <- vals$jdata %>%
        full_join(receipt_data, by = c("Date", "Actuals")) %>%
        dplyr::mutate(Receipts = coalesce(Receipts.x, Receipts.y)) %>% 
        dplyr::select(names(jdata_new)) 
        
      vals$jdata <- jdata_update()
      
    })
    
    # Update slider input limits when input for checkbox1 changes
    observeEvent(input$checkbox1, {
    
      new_limits <- jdata()$Date
      min <- as.Date(min(new_limits), format = "%b-%y")
      max <- as.Date(max(new_limits), format = "%b-%y")
      
      updateSliderInput(session, "slider1",
                        min = min,
                        max = max,
                        value = c(min, max),
                        timeFormat = "%b-%y")
      
    }, ignoreNULL = T )
    
    
    # Re-assign vals$jdata when input$numeric changes - 
    # new disposal rates will result in updated Disposal figures
    observeEvent(input$numeric, {
      vals$jdata <- jdata_update()
    })
    
    # rhandsontable output - configure which cols are and are not read only
    output$hot <- renderRHandsontable({
      rhandsontable(sitting_days_total) %>%
        hot_col("Period", readOnly = TRUE)
    })
    
    
    # call jdata_update() when something changes in "input$hot"
    observeEvent(input$hot, {
      
      # hot_to_r function convert rhandsontable to an r dataframe
      df <- hot_to_r(input$hot) %>%
        right_join(sd_join, by = "Period") %>%
        dplyr::mutate(`Sitting Days` = `Total Sitting Days` * `Monthly share pa`) %>%
        select(Date = Month, `Sitting Days`) %>%
        filter(Date <= "2023-01-01")
      
      # power_full_join : A full and right join rolled into one
      vals$jdata <- vals$jdata %>%
        power_full_join(df, by = "Date", conflict = coalesce_yx) %>%
        mutate(Actuals = ifelse(Date < forecast_start_date, Actuals, "Projection")) %>%
        arrange(Date)
        
      vals$jdata <- jdata_update()
      
    })
    
    
    # renderPlotly - plot updates dynamically subject to contents of the picker1 input
    output$plot <- renderPlotly({
      
      # Only render when this criteria is met
      req(length(input$picker1) > 0)
      req(nrow(jdata2() %>% filter(!is.na(OutstandingCases))) > 0 )
      
      #print(factor(jdata_selected()$Actuals, levels = level_test))
      
      # Line graph
      p <- ggplot(jdata_selected(), 
                  aes(x = Date)) +
        geom_line(aes(y = Total, colour = factor(Category), 
                      linetype = factor(Actuals, levels = level_test)), 
                  size = 1) +
        ggtitle("Time series for total Outstanding Cases by month")
      
      # Add bar graph, only in the case where one item is selected from the picker
      if (length(input$picker1) == 1 & 
          nrow(jdata_selected() %>% filter(Actuals == "Actual")) > 0 ) {
        p <- p +
          geom_bar(aes(y = Total2), stat = "identity", fill = "cadetblue")
      }
      
      # Convert ggplot object to a plotly object
      ggplotly(p)
      
    })
    
    
    # renderTable - updates dynamically 
    output$table <- renderTable({
      
      jdata2() %>%
        mutate(Date = format(Date, "%b-%y"))
      
    })
    
  }

}



