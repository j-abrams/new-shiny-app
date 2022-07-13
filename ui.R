


# hi

ui <- dashboardPage(
  
  dashboardHeader(title = "Basic dashboard"),
  dashboardSidebar(
    sidebarMenu(id = "sidebar",
                tags$head(tags$style(".inactiveLink {
                            pointer-events: none;
                           cursor: default;
                           }")),
                menuItem("Dashboard", tabName = "dashboard", 
                         icon = icon("dashboard", verify_fa = FALSE)),
                menuItem("Widgets", tabName = "widgets", 
                         icon = icon("th", verify_fa = FALSE))
    )
  ),
  
  dashboardBody(
    # Boxes need to be put in a row (or column)
    fluidRow(
      
      column(class = "myCol1",
        width = 4,
        fileInput("file1", 
                  label = h3("Upload Receipts Projections"),
                  accept = c(
                    "text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv")
        ),
      ),
      column(class = "myCol1",
        width = 8,
        fileInput("file2", 
                  label = h3("Upload Disposals Projections"),
                  accept = c(
                    "text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv"))
      ),
      column(
        class = "myCol2",
        width = 4,
        div(style = "height:10px"),
        
        sliderInput("slider1",
                    label = "Select Date Range:",
                    min = as.Date(min(jdata_new$Date), "%b-%y"),
                    max = as.Date(max(jdata_new$Date), "%b-%y"),
                    value = c(as.Date(min(jdata_new$Date), "%b-%y"),
                              as.Date(max(jdata_new$Date), "%b-%y")),
                    timeFormat = "%b-%y"
        ),
        
        div(style = "height:50px", "Date range to display in tabular and plot outputs"),
        
        prettyCheckboxGroup(
          inputId = "checkbox1",
          label = "Actuals and Projections",
          choices = c("Actual", "Projection"),
          selected = c("Actual"),
          shape = "round",
          inline = F,
          icon = icon("bitcoin")
        ),
        
        div(style = "height:50px", "Select whether to display Actuals, Projections or both"),
        
        numericInputIcon("numeric",
                         label = "Enter Disposal Rate:",
                         min = 1,
                         max = 2,
                         step = 0.1,
                         value = 1.5,
                         icon = icon("percent")
        ),
        
        div(style = "height:50px", "Disposal rate for converting sitting days to disposals")
      ),
      column(class = "myCol2",
        width = 8,
        div(style = "height:20px"),
        plotlyOutput("plot")
        #dataTableOutput("table")
      ),
      tags$head(tags$style("
        .myCol1{background-color: LightBlue;}")
      ),
      tags$head(tags$style("
        .myCol2{height:450px;background-color: LightPink;}")
      )
    ),
    br(),
    fluidRow(
      column(width = 12,
        tableOutput("table")
      )
    )
  )
)
