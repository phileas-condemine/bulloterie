ui <- shinyUI(fluidPage(
  
  titlePanel("Shiny networkD3 "),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId="competences", label = "Ajout de compétences", choices = nm_competences,multiple=T),
      div(id="personne_interet",style="border:1px solid #d3d3d3;background-color:#e5e5e5;",
          selectInput(inputId="personnes",label="Recherche par nom_AKA",choices=bullo$nom,multiple = T),
          selectInput(inputId="interet",label="Expertise/Connaissance/Interêt",choices=c("interet","connait","expert"))
      )
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Force Network", forceNetworkOutput("force"))
      )
    )
  )
))
