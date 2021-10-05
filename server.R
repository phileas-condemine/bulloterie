library(shiny)
library(networkD3)

data(MisLinks)
data(MisNodes)
server <- function(input, output,session) {
  
  observeEvent(input$data_source,{
    print(input$data_source)
    if(input$data_source=="eig2018"){
      source("prep_bullo_eig18.R")
    }else if(input$data_source=="mentors2019") {
      source("prep_bullo_mentor19.R")
    } else if(input$data_source=="etalab") {
      source("prep_bullo_etalab.R")
    } else if(input$data_source=="eig2019") {
      source("prep_bullo_airtable.R")
    }
    
    
    # source("circlePackeR.R")
    req(bullo);req(nm_competences);
    updateSelectInput(session,inputId="competences", label = "Ajout de compétences", 
                      choices = nm_competences,selected = sample(nm_competences,4))
    updateSelectInput(session,inputId="personnes",label="Recherche par nom_AKA",
                      choices=bullo$nom,selected=NULL#sample(bullo$nom,1)
                      )
    updateSelectInput(session,inputId="interet",label="Rapport au domaine",selected="tous",
                      choices=c(concepts,"tous"))
    })

  
  
  output$force <- renderForceNetwork({
  req(bullo);req(nm_competences);
    focus_competences=input$competences
    # focus_competences=setdiff(nm_competences,"C++")
    
    noms_=input$personnes
    # noms_="Christian"
    interest=input$interet
    print(input$personnes)
    print(input$competences)
    # interest="interet"
    if(length(noms_)>0){
      autres_competences=bullo%>%
        filter(nom%in%noms_)%>%{
          if(interest=="tous"){
            .[,grep(pattern = paste0(concepts,collapse="|"),names(.))] } else
        .[,grep(pattern = interest,names(.))]
          }%>%
        sapply(sum)%>%.[.>0]%>%
        names%>%
        gsub(pattern = paste0("\\.",concepts,collapse="|"),
             replacement = "")

    focus_competences=c(focus_competences,autres_competences)%>%
      unique

    }
    if (length(focus_competences)==0|is.null(focus_competences))
      return(NULL)
    to_keep_cols=unname(unlist(sapply(focus_competences,function(x)grep(x,names(bullo),fixed = T))))
    filter_col=c(1,2,to_keep_cols)
    print(filter_col)
    filter_col=names(bullo)[filter_col]
    bullo_current=bullo[,filter_col]
    not_empty_competence=sapply(bullo[,3:ncol(bullo)],sum)[to_keep_cols-2]#Pour éviter les erreurs lorsqu'on a une seule colonne qui est alors vue comme un vecteur
    print(not_empty_competence)
    not_empty_competence=names(not_empty_competence[not_empty_competence>0])
    # not_empty_competence=setdiff(not_empty_competence,c("symbole","nom"))
    if(length(not_empty_competence)==0)
      return(NULL)
    build_graph=function(nm){
      ind=which(bullo_current[,nm]==1)# "1"
      src=bullo_current[ind,][["nom"]]
      target=rep(nm,length(src))
      networkData <- data.frame(source=src, target,value=1)
      return(networkData)}
    networkData=do.call("rbind",lapply(not_empty_competence,FUN = build_graph))
    nodes_src=networkData%>%data.table()%>%.[,list(group="personne",size=10),by="source"]
    setnames(nodes_src,"source","name")
    nodes_tgt=networkData%>%data.table()%>%.[,list(group="competence",size=.N),by="target"]
    setnames(nodes_tgt,"target","name")
    for (concept in concepts){
      nodes_tgt[grepl(concept,nodes_tgt$name),"group"]=concept
    }
    # nodes_tgt[grepl("connait",nodes_tgt$name),"group"]="connait"
    # nodes_tgt[grepl("interet",nodes_tgt$name),"group"]="interet"
    # nodes_tgt[grepl("expert",nodes_tgt$name),"group"]="expert"
    
    nodes=rbind(nodes_src,nodes_tgt)
    nodes$ID=1:nrow(nodes)-1
    nodes[nodes$name%in%input$personnes,"size"] <- 100
    
    networkData=merge(networkData,nodes[,c("name","ID")],by.x="source",by.y="name")
    setnames(networkData,"ID","sourceID")
    networkData=merge(networkData,nodes[,c("name","ID")],by.x="target",by.y="name")
    setnames(networkData,"ID","targetID")

    # add_link_interet_connait=data.frame(source=sprintf("%s.interet",nm_competences),
    #                                     target=sprintf("%s.connait",nm_competences),value=3)
    # add_link_interet_expert=data.frame(source=sprintf("%s.interet",nm_competences),
    #                                    target=sprintf("%s.expert",nm_competences),value=5)
    add_link=NULL
    for(i_concept in 1:(length(concepts)-1)){
      for (concept2 in concepts[(i_concept+1):length(concepts)]){
        add_link=rbind(add_link,
                       data.frame(source=paste(nm_competences,concepts[i_concept],sep="."),
                                  target=paste(nm_competences,concept2,sep="."),value=3))
      }
    }
    # add_link=rbind(add_link_interet_connait,add_link_interet_expert)
    add_link=merge(add_link,nodes[,c("name","ID")],by.x="source",by.y="name")
    setnames(add_link,"ID","sourceID")
    add_link=merge(add_link,nodes[,c("name","ID")],by.x="target",by.y="name")
    setnames(add_link,"ID","targetID")

    networkData=rbind(networkData,add_link)
    links=networkData[,c("sourceID","targetID","value")]
    forceNetwork(Links = links,
                 Nodes=nodes,
                 NodeID="name",
                 Group="group",
                 Source="sourceID",
                 Target="targetID",
                 Value="value",
                 Nodesize="size",
                 fontSize = 16,
                 colourScale = JS("d3.scaleOrdinal(d3.schemeCategory10);"),
                 legend=T,
                 opacityNoHover = 1,
                 opacity=.7,charge = -150,zoom = T)

  })
}




