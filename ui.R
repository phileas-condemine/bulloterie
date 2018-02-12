ui <- shinyUI(fluidPage(
  
  titlePanel("Shiny networkD3 "),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId="competences", label = "Selectionner des compétences", choices = nm_competences,multiple=T)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Force Network", forceNetworkOutput("force"))
      )
    )
  )
))
