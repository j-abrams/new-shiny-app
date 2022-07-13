


# hi

ui <- dashboardPage(
  
  dashboardHeader(title = "Basic dashboard"),
  dashboardSidebar(),
  
  dashboardBody(
    # Boxes need to be put in a row (or column)
    fluidRow(
      #shinyjs::useShinyjs(),
      
      column(
        width = 6,
        fileInput("file1", 
                  label = h3("Upload Receipts"),
                  accept = c(
                    "text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv")
        ),
      ),
      column(
        width = 6,
        fileInput("file2", 
                  label = h3("Upload Disposals"),
                  accept = c(
                    "text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv"))
      ),
      column(
        width = 3,
        prettyCheckboxGroup(
          inputId = "checkbox1",
          label = "Actuals and Projections",
          choices = c("Actual", "Projection"),
          selected = c("Actual"),
          shape = "round",
          inline = F
        )
      ),
      column(
        width = 6,
        sliderInput("slider1",
                    "Date Range:",
                    min = as.Date(min(jdata_new$Date), "%b-%y"),
                    max = as.Date(max(jdata_new$Date), "%b-%y"),
                    value = c(as.Date(min(jdata_new$Date), "%b-%y"),
                              as.Date(max(jdata_new$Date), "%b-%y")),
                    timeFormat = "%b-%y")
      ),
      column(12,
        plotlyOutput("plot"),
      ),  
      column(12,
        tableOutput("table")
      )
    )
  )
)
