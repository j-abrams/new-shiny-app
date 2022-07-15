


# hi

ui <- dashboardPage(
  
  dashboardHeader(title = "Basic dashboard"),
  
  #### Sidebar ----
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
  
  ## Body ----
  dashboardBody(
    fluidRow(
      # Header
      headerPanel("HMCTS Dashboard Modelling - Receipts, Disposals & Outstanding Cases"),
      div(style = "height:100px")),
    
    fluidRow(
      
      column(
        class = "myCol1",
        width = 4,
        div(style = "height:10px"),
        
        # Slider for date inputs
        sliderInput("slider1",
                    label = "Select Date Range:",
                    min = as.Date(min(jdata_new$Date), "%b-%y"),
                    max = as.Date(max(jdata_new$Date), "%b-%y"),
                    value = c(as.Date(min(jdata_new$Date), "%b-%y"),
                              as.Date(max(jdata_new$Date), "%b-%y")),
                    timeFormat = "%b-%y"
        ),
        
        div(style = "height:40px", "Date range to display in tabular and plot outputs"),
        
        # Checkbox for selecting actuals, projections or both
        prettyCheckboxGroup(
          inputId = "checkbox1",
          label = "Actuals and Projections",
          choices = c("Actual"),
          selected = c("Actual"),
          inline = T
        ),
        
        div(style = "height:40px", "Select whether to display Actuals, Projections or both"),
        
        pickerInput(
          inputId = "picker1",
          label = "Plotting variable",
          choices = c("Receipts", "Disposals", "OutstandingCases"),
          selected = "OutstandingCases",
          multiple = T
        ),
        
        div(style = "height:40px", "Use dropdown to decide which variable / variables to plot"),
        
        knobInput(
          inputId = "knob1",
          label = "Confidence Interval",
          value = 10, min = 0, max = 20,
          height = "85px",
          #height = "95px",
          #angleArc = 180, angleOffset = 270,
          fgColor = "cornflowerblue",
          post = "%"
        ),
        
        div(style = "height:40px", "Adjust confidence interval with this widget")
        
    
      ),
      column(class = "myCol1",
        width = 8,
        div(style = "height:20px"),
        plotlyOutput("plot")
      ),
      
      tags$head(tags$style("
        .myCol1{height:600px;background-color: LightPink;}")
      ),
      
      
      
      column(class = "myCol2",
        width = 4,
        fileInput("file1", 
                 label = h3("Upload Receipts Projections"),
                 accept = c(
                   "text/csv",
                   "text/comma-separated-values,text/plain",
                   ".csv")
        ),
        
        
        # Numeric input for variable disposal rate
        numericInputIcon("numeric",
                        label = "Enter Disposal Rate:",
                        min = 1,
                        max = 2,
                        step = 0.1,
                        value = 1.5,
                        icon = icon("percent")
        ),
        
        div(style = "height:40px", "Disposal rate for converting sitting days to disposals"),
        
        rHandsontableOutput("hot", height = "32%"),
        
        div(style = "height:40px", "Disposal rate for converting sitting days to disposals"),
        
        downloadButton(
          "actionbutton1",
          label = "Export .csv",
          width = "50%", 
          height = "100px",
          icon = icon("download")
        ),
        div(style = "height:20px"),
        div(style = "height:40px", "Export underlyiing data into an Excel csv file"),
             
      ),
      
      tags$head(tags$style("
        .myCol2{height:600px;background-color: LightBlue;}")
      ),
      
      
      column(width = 8,
        tableOutput("table")
      )
    )
  )
)
