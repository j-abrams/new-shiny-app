


# hi

ui <- dashboardPage(
  
  dashboardHeader(title = "HMCTS dashboard"),
  
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
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "stylesheet.css")
    ),
    fluidRow(
      # Header
      headerPanel("HMCTS Dashboard Stock Flow Modelling - Receipts, Disposals & Outstanding Cases"),
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
        
        prettyRadioButtons(
          inputId = "radio1",
          label = "Scenario Selecions",
          choices = c("Best", "Medium", "Worst"),
          selected = "Medium",
          shape = c("round", "square", "curve")
        ),
        
        div(style = "height:40px", "Choose between Best, Worst and Medium, which scenario to display")
        
    
      ),
      column(class = "myCol2",
        width = 8,
        div(style = "height:20px"),
        withSpinner(plotlyOutput("plot"), type = getOption("spinner.type", default = 7))
      ),
    
      #tags$head(tags$style("
      #  .myCol1{height:600px;background-color: LightPink;}")
      #),
      
      
      column(class = "myCol3",
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
                        min = 0.8,
                        max = 1.5,
                        step = 0.1,
                        value = 1.3  #,
                        #icon = icon("percent")
        ),
        
        div(style = "height:40px", "Disposal rate for converting sitting days to disposals"),
        
        knobInput(
          inputId = "knob1",
          label = "Receipts Confidence Interval",
          value = 0, min = 0, max = 20,
          #height = "85px",
          height = "80px",
          angleArc = 180, angleOffset = 270,
          fgColor = "cornflowerblue",
          post = "%"
        ),
        
        div(style = "height:40px", "Adjust confidence interval with this widget"),
        
        rHandsontableOutput("hot", height = "25%"),
        
        div(style = "height:60px", "rhandsontable where overall annual figures may be edited by the user"),
        
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
      
      # Replace this in css script when i know how
      #tags$head(tags$style("
      #  .myCol2{height:900px;background-color: LightBlue;}")
      #),
      
      
      column(width = 8,
             
        incrementButton("test"),
        
        tags$div(),
        
        tags$div(title="Click here to slide through years",
                 sliderInput("slider_year", "YEAR:", 
                             min = 2001, max = 2011, value = 2009, 
                             format="####", locale="us"
                 )
        ),
        
        tags$input(
          type = "text",
          id = "text_input",
          placeholder = "Filter..."
        ),
          
        tableOutput("table")
        
      )
    )
  )
)
