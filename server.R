



if (interactive()) {
  
  server <- function(input, output, session) {
    
    # Initiate
    vals <- reactiveValues(jdata = jdata_new)
    
    
    # Integrate the date slider functionality
    
    # Call this function to update our reactive plot in the renderPlotly command
    jdata_selected <- reactive({
      
      vals$jdata %>%
        # Filter for actuals or projections based on contents of checkbox
        filter(Actuals %in% input$checkbox1) %>%
        # Use floor date to filter on Date
        filter(Date >= floor_date(input$slider1[1], unit = "months") &
                 Date <= floor_date(input$slider1[2], unit = "months")) %>%
        dplyr::relocate(Actuals, .after = last_col()) %>%
        pivot_longer(c("Receipts", "Disposals", "OutstandingCases"),
                     names_to = "Category", values_to = "Total") %>%
        filter(Category %in% input$picker1) %>%
        mutate(Total2 = ifelse(Actuals == "Actual", Total, NA))
      
    })
    
    
    
    
    # Define what happens when a new receipts input file is uploaded to the app
    observeEvent(input$file1, {
      
      # Read contents from $datapath
      receipt_data <- read.csv(input$file1$datapath) 
      
      # Check to see whether the right receipts file has been uploaded
      req("Receipts" %in% names(receipt_data))
      
      # Update options and selections
      updatePrettyCheckboxGroup(
        session, 
        "checkbox1",
        choices = c("Actual", "Projection"),
        selected = c("Actual"),
        inline = T
      )
      
      receipt_data <- receipt_data %>%
        dplyr::rename("Date" = 1) %>%
        dplyr::mutate(Date = as.Date(Date, "%d/%m/%Y"),
               Actuals = "Projection") 
      
      # Re-assign vals$jdata with the latest receipts forecasts
      vals$jdata <- vals$jdata %>%
        full_join(receipt_data, by = c("Date", "Actuals")) %>%
        dplyr::mutate(Receipts = coalesce(Receipts.x, Receipts.y)) %>% 
        dplyr::select(names(jdata_new)) 
        
      #vals$jdata <- jdata_update()

      
    })
    
    # Update slider input limits when input for checkbox1 changes
    
    observeEvent(input$checkbox1, {

      # This refreshes twice when called, once to update the slider, once to update plot
      # Investigate how to use isolate to counter this
      isolate({
        new_limits <- vals$jdata %>%
          # Filter for actuals or projections based on contents of checkbox
          filter(Actuals %in% input$checkbox1)
        
  
        min <- as.Date(min(new_limits$Date), format = "%b-%y")
        max <- as.Date(max(new_limits$Date), format = "%b-%y")
        
        # use freeze react to force an error / warning
        
        freezeReactiveValue(input, "slider1")
        
        updateSliderInput(session, "slider1",
                          min = min,
                          max = max,
                          value = c(min, max),
                          timeFormat = "%b-%y")
      })

    }, ignoreNULL = T )
    
    
    
    observeEvent(input$radio1, {
      
      
      if (input$radio1 == "Worst") {
      
        #input$numeric <- 0.8
        
        updateNumericInputIcon(
          inputId = "numeric",
          value = 0.8
        )  
        
        updateKnobInput(
          inputId = "knob1",
          value = 15
        )
      }
      
      if (input$radio1 == "Medium") {
        updateNumericInputIcon(
          inputId = "numeric",
          value = 1.3
        )  
        
        updateKnobInput(
          inputId = "knob1",
          value = 0
        )
      }
      
      if (input$radio1 == "Best") {
        updateNumericInputIcon(
          inputId = "numeric",
          value = 1.5
        )  
        
        updateKnobInput(
          inputId = "knob1",
          value = 10
        )
      }
      
      
    })
    
    
    
    #call jdata_update() when something changes in "input$hot"
    observeEvent(input$hot, {
      
      #req(input$file1)
      
      # hot_to_r function convert rhandsontable to an r dataframe
      df <- hot_to_r(input$hot) %>%
        right_join(sd_join, by = "Period") %>%
        dplyr::mutate(`Sitting Days` = `Total Sitting Days` * `Monthly share pa`) %>%
        select(Date = Month, `Sitting Days`) #%>%
      #filter(Date <= "2023-01-01")
      
      # power_full_join : A full and right join rolled into one
      vals$jdata <- vals$jdata %>%
        power_full_join(df, by = "Date", conflict = coalesce_yx) %>%
        mutate(Actuals = ifelse(Date < forecast_start_date, Actuals, "Projection")) %>%
        arrange(Date) %>%
        select(names(jdata_new))
      
      #vals$jdata <- jdata_update()
      
    })
    
    
    
    # Re-assign vals$jdata when input$numeric changes - 
    # new disposal rates will result in updated Disposal figures
    # Re-assign when input$knob1 changes also
    
    observe({
      
      vals$jdata <- vals$jdata %>%
        dplyr::mutate(
          Disposals = ifelse(Actuals == "Projection", `Sitting Days` * input$numeric, Disposals),
          diff = ifelse(Actuals == "Projection", Receipts - Disposals,  0),
          OutstandingCases = ifelse(Actuals == "Projection",
                                    cumsum(diff) + last_outstanding_val, 
                                    OutstandingCases)) %>%
        select(-diff)  %>% 
        
        mutate(`Upper Receipts` = ifelse(Actuals == "Projection", 
                                         Receipts * ((100 + input$knob1) / 100), NA)) %>%
        mutate(`Lower Receipts` = ifelse(Actuals == "Projection", 
                                         Receipts * ((100 - input$knob1) / 100), NA)) %>%
        mutate(diff1 = ifelse(Actuals == "Projection", `Upper Receipts` - Disposals,  0)) %>%
        mutate(`Upper Interval` = ifelse(Actuals == "Projection",
                                         cumsum(diff1) + last_outstanding_val, 
                                         NA)) %>%
        mutate(diff2 = ifelse(Actuals == "Projection", `Lower Receipts` - Disposals,  0)) %>%
        mutate(`Lower Interval` = ifelse(Actuals == "Projection",
                                         cumsum(diff2) + last_outstanding_val, 
                                         NA)) %>%
        select(-c(diff1, diff2, `Upper Receipts`, `Lower Receipts`))
      
    })

    
    
    # rhandsontable output - configure which cols are and are not read only
    output$hot <- renderRHandsontable({
      rhandsontable(sitting_days_total) %>%
        hot_col("Period", readOnly = TRUE)
    })
    
    
    # Export vals$jdata with the download button
    output$actionbutton1 <- downloadHandler(
      filename = function() {
        paste("data-", Sys.Date(), ".csv", sep="")
      },
      content = function(file) {
        write.csv(
          vals$jdata %>%
            mutate(`Disposal Rate` = input$numeric), 
          file)
      }
    )
    
    
    # renderPlotly - plot updates dynamically subject to contents of the picker1 input
    output$plot <- renderPlotly({
      
      # Only render when this criteria is met
      req(input$hot)
      req(length(input$picker1) > 0)
      req(length(input$checkbox1) > 0)
      
      
      
      tryCatch({
      
      
      #print(factor(jdata_selected()$Actuals, levels = level_test))
      
      # Line graph
      
        data <- jdata_selected()
        
        # Fix factor prior to plotting to fix hovering / legend labels
        data$Category <- factor(data$Category, levels = levels(as.factor(data$Category)))
        data$Actuals <- factor(data$Actuals, levels = levels(as.factor(data$Actuals)))
        
        
        p <- ggplot(data, 
                  aes(x = Date)) +
          geom_line(aes(y = Total, 
                        colour = Category, 
                        linetype = Actuals), 
                    size = 1) +
          ggtitle("Time series for total Outstanding Cases by month") +
          theme_bw() 
        
      
        # Add bar graph, only in the case where one item is selected from the picker
        if (length(input$picker1) == 1) {
          if (nrow(jdata_selected() %>% filter(Actuals == "Actual")) > 0 ) {
            p <- p +
              geom_bar(aes(y = Total2), stat = "identity", fill = "cadetblue")
          }
          
          if ("Projection" %in% jdata_selected()$Actuals & 
              input$picker1 == "OutstandingCases") {
            p <- p +
              geom_line(aes(y = `Upper Interval`), color = "cornflowerblue", linetype = "dashed") +
              geom_line(aes(y = `Lower Interval`), color = "cornflowerblue", linetype = "dashed")
          }
        }
        
      
      #req(typeof(p) == "vector" )
      # Convert ggplot object to a plotly object
      #suppressWarnings(
      
      
        ggplotly(p, height = 550) %>%
          layout(showlegend = FALSE)
        
      },
      error = function(e) {} )  
      
      #)
      
    })
    
    
    # renderTable - updates dynamically 
    output$table <- renderTable({
      
      req(input$hot)
      
      tryCatch({
      
        vals$jdata %>%
          # Filter for actuals or projections based on contents of checkbox
          filter(Actuals %in% input$checkbox1) %>%
          # Use floor date to filter on Date
          filter(Date >= floor_date(input$slider1[1], unit = "months") &
                   Date <= floor_date(input$slider1[2], unit = "months")) %>%
          dplyr::relocate(Actuals, .after = last_col()) %>%
          mutate(Date = format(Date, "%b-%y"))
      
      },
      # add code to run if error here if you wish
      error = function(e) {} )  
        
    })
    
  }

}



