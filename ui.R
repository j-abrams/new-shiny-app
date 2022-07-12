


# hi

ui <- dashboardPage(
  dashboardHeader(title = "Basic dashboard"),
  dashboardSidebar(),
  dashboardBody(
    # Boxes need to be put in a row (or column)
    fluidRow(
      column(
        width = 4,
        prettyCheckboxGroup(
          inputId = "checkbox1",
          label = "Actuals and Projections",
          choices = c("Actual", "Projection"),
          selected = c("Actual", "Projection"),
          shape = "round",
          inline = F
        ),
      ),
      
      column(width = 8,
        sliderInput("slider1",
                    "Dates:",
                    min = as.Date(min(jdata_new$Date), "%b-%y"),
                    max = as.Date(max(jdata_new$Date), "%b-%y"),
                    value = c(as.Date(min(jdata_new$Date), "%b-%y"),
                              as.Date(max(jdata_new$Date), "%b-%y")),
                    timeFormat = "%b-%y")
      ),
      column(12,
        plotOutput("plot"),
      ),  
      column(12,
        tableOutput("table")
      )
    )
  )
)