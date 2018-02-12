library(shiny)
library(networkD3)

data(MisLinks)
data(MisNodes)
server <- function(input, output) {
  
  
  output$force <- renderForceNetwork({
    focus_competences=input$competences
    if(is.null(focus_competences))
      return(NULL)
    filter_col=c(1,2,unname(unlist(sapply(focus_competences,function(x)grep(x,names(bullo))))))
    bullo=bullo[-1,filter_col]
    bullo=bullo%>%
      apply(2,as.character)
    not_empty_competence=apply(bullo,2,function(x)sum(!x==""))
    not_empty_competence=names(not_empty_competence[not_empty_competence>0])
    not_empty_competence=setdiff(not_empty_competence,c("symbole","nom"))
    build_graph=function(nm){
      ind=which(bullo[,nm]=="1")
      src=bullo[ind,"nom"]
      target=rep(nm,length(src))
      networkData <- data.frame(source=src, target,value=1)
      return(networkData)}
    networkData=do.call("rbind",lapply(not_empty_competence,FUN = build_graph))
    nodes_src=networkData%>%data.table()%>%.[,list(group="personne",size=10),by="source"]
    setnames(nodes_src,"source","name")
    nodes_tgt=networkData%>%data.table()%>%.[,list(group="competence",size=.N),by="target"]
    setnames(nodes_tgt,"target","name")
    nodes_tgt[grepl("connait",nodes_tgt$name),"group"]="connait"
    nodes_tgt[grepl("interet",nodes_tgt$name),"group"]="interet"
    nodes_tgt[grepl("expert",nodes_tgt$name),"group"]="expert"
    
    nodes=rbind(nodes_src,nodes_tgt)
    nodes$ID=1:nrow(nodes)-1
    networkData=merge(networkData,nodes[,c("name","ID")],by.x="source",by.y="name")
    setnames(networkData,"ID","sourceID")
    networkData=merge(networkData,nodes[,c("name","ID")],by.x="target",by.y="name")
    setnames(networkData,"ID","targetID")
    
    
    add_link_interet_connait=data.frame(source=sprintf("%s.interet",nm_competences),target=sprintf("%s.connait",nm_competences),value=3)
    add_link_interet_expert=data.frame(source=sprintf("%s.interet",nm_competences),target=sprintf("%s.expert",nm_competences),value=5)
    add_link=rbind(add_link_interet_connait,add_link_interet_expert)
    add_link=merge(add_link,nodes[,c("name","ID")],by.x="source",by.y="name",all.x)
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
                 opacity=.7,charge = -100,zoom = T)
  
  })
  
}

