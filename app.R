require(shiny)
library(reticulate)
library(ggplot2)

egemaps.vars <- scan("egemaps.txt", character(), quote = "")
opensmile <- import("opensmile")
smile = opensmile$Smile(feature_set = opensmile$FeatureSet$eGeMAPSv02, feature_level = opensmile$FeatureLevel$Functionals, num_workers = 5)

ui <- fluidPage(
  titlePanel("Compare properties of subsets of WAVs"),
  sidebarLayout(
    sidebarPanel(
      fileInput("wavs", "Choose ZIP file with wavs", accept = ".zip"),
      fileInput("factors", "Choose factor file", accept = ".csv"),
      selectInput("factor", "Factor for subsetting", choices = ""),
      selectInput("property", "eGeMAPS property:", choices = egemaps.vars),
      checkboxInput("values", "Show eGeMAPS values", value = TRUE)
    ),
    mainPanel(
      plotOutput("plot"),
      tableOutput("values")
    )
  )
)

server <- function(input, output) {

  observeEvent(input$factors, {
    fs <- subset(factors(), select = -file)
    updateSelectInput(inputId = "factor", choices = colnames(fs))
  })

  tmp <- tempdir()

  factors <- reactive({
    req(input$factors)
    file <- input$factors
    ext <- tools::file_ext(file$datapath)
    validate(need(ext == "csv", "Please upload factors file"))
    read.csv(file$datapath)
  })

 egemaps <- reactive({
    req(input$wavs)
    file <- input$wavs
    ext <- tools::file_ext(file$datapath)
    validate(need(ext == "zip", "Please upload a zip file with wavs"))

    unzip(file$datapath, exdir = tmp)
    d <- smile$process_folder(tmp)
    unlink(tmp)

    fs <- py_to_r(attributes(d)$pandas.index$to_frame())[,1]
    d <- cbind(d, fs )
    colnames(d)[length(d)] <- "file"
    d$file <- sub(".*/","", d$file)
    d
  })

  egemaps.factored <- reactive({
    merge(egemaps(), factors(), by="file")
  })

  output$plot <- renderPlot({
    ggplot(egemaps.factored(), aes(x = get(input$property), color= get(input$factor))) + geom_density() +
      labs(x = input$property, color = input$factor)
  })

  output$values <- renderTable({
    if (input$values)
      egemaps.factored()
  })
}

runApp(
  shinyApp(ui, server),
  port = 8008, host = '0.0.0.0'
)
