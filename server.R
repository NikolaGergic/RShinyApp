library(shiny)
library(leaflet)
library(raster)
library(rgdal)
library(plotly)

dem <- raster("C:/Users/nikola/Desktop/Nikola Gergic App/dem25.tif")



shinyServer(function(input, output){
  
  
  map <- reactive({
    req(input$filemap)
    # shpdf is a data.frame with the name, size, type and datapath of the uploaded files
    shpdf <- input$filemap
    
    # The files are uploaded with names 0.dbf, 1.prj, 2.shp, 3.xml, 4.shx
    # (path/names are in column datapath)
    # We need to rename the files with the actual names: fe_2007_39_county.dbf, etc.
    # (these are in column name)
    
    # Name of the temporary directory where files are uploaded
    tempdirname <- dirname(shpdf$datapath[1])
    
    # Rename files
    for(i in 1:nrow(shpdf)){
      file.rename(shpdf$datapath[i], paste0(tempdirname, "/", shpdf$name[i]))
    }
    
    # Now we read the shapefile with readOGR() of rgdal package
    # passing the name of the file with .shp extension.
    
    # We use the function grep() to search the pattern "*.shp$"
    # within each element of the character vector shpdf$name.
    # grep(pattern="*.shp$", shpdf$name)
    # ($ at the end denote files that finish with .shp, not only that contain .shp)
    map <- readOGR(paste(tempdirname, shpdf$name[grep(pattern = "*.shp$", shpdf$name)], sep = "/"))
    
  })
  

  
 
  myReactiveH <- reactive({
    
    T2 = matrix(c(as.numeric(input$x), as.numeric(input$y)), nrow = 1, ncol = 2)
    e2 = extract(dem, T2)
    h = as.numeric(input$z) - as.numeric(e2) 
    
  })
  
  

 
  
  output$h <- renderText({
    
    H <- myReactiveH();
    
  })
  #Za korisnikov unos X i Y vrsi se ekstrakcija Z koordinate iz DEM-a 
  
  myReactiveE <- reactive({
    
    T1 = matrix(c(as.numeric(input$x), as.numeric(input$y)), nrow = 1, ncol = 2)
    
    e = extract(dem, T1)
    
  })
  
  
  output$e1 <- renderText({
    
    E <- myReactiveE();
    
  })
  
  
  
  #Leaflet mapa na kojoj treba da budu prikazane deltaH
  output$mymap <- renderLeaflet({
    
   
    
    leaflet() %>% 
            addTiles()%>%
            setView(lng =20.457273, #479791
                    lat =44.787197, #4931730
                    zoom = 8)
    
    
  })

  
  observeEvent(input$radio, {
    if (input$radio == "1") {
      
      
      H1 <- myReactiveH();
      E1 <- myReactiveE();
      
      
      utm = CRS("+proj=utm +zone=34 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
      point = data.frame(name=1, lat=input$y, lon=input$x, dem=E1, dem_dif=H1)
      coordinates(point) <-~ lon + lat
      point@proj4string = utm
      point = spTransform(point, CRS("+proj=longlat +datum=WGS84"))
      
 
      leafletProxy(mapId = "mymap")%>% 
        clearShapes()%>%
        setView(lng =point@coords[1,1], 
                lat =point@coords[1,2], 
                zoom = 8) %>%
        addMarkers(point@coords[1,1], point@coords[1,2], label = paste("Visinska razlika je:", H1))
    } else if (input$radio == "2") {
      map <- map()
      data <- data()
      leafletProxy(mapId = "mymap", data = map)%>% 
        clearMarkers()%>%
        setView(lng =20.457273, 
                lat =44.787197, 
                zoom = 8)%>%
        addPolylines(color = "#03F", weight = 5, opacity = 1)
    } else if (input$radio == "4") {
   
      leafletProxy(mapId = "mymap")%>%
        clearMarkers()%>%
        clearShapes()%>%
        setView(lng =20.457273, 
                lat =44.787197, 
                zoom = 8)
      
    } else if (input$radio == "3") {
      
      output$myhist <- renderPlotly(
        
        {
        map1 <- map()
        map1 = spTransform(map1, dem@crs)
        visine = extract(dem,as(map1,"SpatialLines"), sp=TRUE)
        
        x <- (1:length(visine[[1]]))
        y <- (visine[[1]])             
        dataF <- data.frame(x, y)
        
        t <- list(
              family = "sans serif",
               size = 14,
                color = 'blue')
        ax <- list(
          title = "Redni broj piksela",
          zeroline = FALSE,
          showline = FALSE,
          showticklabels = TRUE,
          showgrid = TRUE,
          linecolor = toRGB("black"),
          gridcolor = toRGB("gray50")
        )
        ay <- list(
          title = "Visina[m]",
          zeroline = FALSE,
          showline = FALSE,
          showticklabels = TRUE,
          showgrid = TRUE,
          linecolor = toRGB("black"),
          gridcolor = toRGB("gray50")
        )
        
        p <- plot_ly(dataF, x = ~x, y = ~y, type = 'scatter', mode = 'lines')%>%
        layout(title = "Podužni profil terena", xaxis = ax, yaxis = ay, font=t)
        
       
        }
      )
      
    }
  }, ignoreInit = TRUE)
  
  
  
  
  
})