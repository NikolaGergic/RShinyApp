library(shiny)
library(shinythemes)
library(leaflet)

shinyUI(fluidPage(
  
  tags$script(HTML(
    "document.body.style.backgroundColor = 'cadetblue';"
  )),
  tags$script(HTML(
    "document.body.style.fontFamily = 'Verdana';"
  )),


  
  theme = shinytheme("superhero"),
  themeSelector(),
  
  
  
  titlePanel("Računanje visinskih razlika"),
  tags$b("Nikola Gergić Master Rad"),
  
  sidebarLayout(
    sidebarPanel(
      
      numericInput(inputId = "x", "Unesite koordinatu X: ", value = 0),
      numericInput(inputId = "y", "Unesite koordinatu Y: ", value = 0),
      numericInput(inputId = "z", "Unesite koordinatu Z: ", value = 0),
      fileInput(inputId = "filemap", label = "Upload vector file. Choose shapefile:",
                multiple = TRUE, accept = c('.shp','.dbf','.sbn','.sbx','.shx','.prj')),
      radioButtons(inputId = "radio", label = h3("Izaberite prikaz:"),
                   choices = list("Prikaz mape sa markerima" = 1, "Prikaz mape sa linijom" = 2, "Prikaz profila terena"=3, "Prikaz mape"=4 ), 
                   selected = 4),
      p("Napravljeno korišćenjem ", a("R Shiny", href = "http://shiny.rstudio.com"),"."),
      img(src = "https://www.bu.edu/library/files/2016/03/RShiny-logo.png", width = "70px", height = "70px")
      
      
      
      
      
    ),
    
    mainPanel(
      
      leafletOutput("mymap", height = 550),
      p("Visina iz DEM-a je:"),
      verbatimTextOutput("e1"),
      p("Visinska razlika je: "),
      verbatimTextOutput("h"),
      p("Profil terena: "),
      plotlyOutput("myhist")
      
     
      
      
      
    ))
))