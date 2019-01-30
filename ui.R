ui <- shinyUI(fluidPage(
  
  titlePanel("Bulloterie"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId="data_source",label="Source de données",choices=c("mentors2019","etalab","eig2018")),
      selectInput(inputId="competences", label = "Ajout de compétences",multiple = T,choices=""),
      div(id="personne_interet",style="border:1px solid #d3d3d3;background-color:#e5e5e5;",
          selectInput(inputId="personnes",label="Recherche par nom_AKA",
                      multiple = T,choices=""),
          selectInput(inputId="interet",label="Rapport au domaine",choices="")
      ),
      div(id="references",
          tags$h3("Références"),
          tags$ul(
        tags$li(tags$a(href="http://movilab.org/index.php?title=La_Bulloterie",
                       "D'après l'idée originale de Sébastien Kurt")),
        tags$li(tags$a(href="https://github.com/phileas-condemine/bulloterie",
                       "Conception et implémentation de l'application"), " : par ",
                tags$a(href="mailto:phileas.condemine@gmail.com", "Philéas Condemine"))
      ))
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Force Network", forceNetworkOutput("force",height = 1000))
      )
    )
  )
))
