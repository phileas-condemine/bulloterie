# install.packages("networkD3")
library(networkD3)
library(dplyr)
library(data.table)
bullo=read.csv2("Bulloterie EIG - Sheet4.csv",sep=",")
names(bullo)
nb_competences=round(ncol(bullo)/3)-1
nm_competences=names(bullo)[3*1:nb_competences]
grid_competences=expand.grid(nm_competences,c("interet","connait","expert"))
grid_competences<-grid_competences%>%arrange(Var1)%>%apply(1,function(x)paste(x,collapse = "."))
names(bullo)<-c("symbole","nom",grid_competences)
focus_competences=sample(nm_competences,10)
filter_col=c(1,2,unname(unlist(sapply(focus_competences,function(x)grep(x,names(bullo))))))
bullo=bullo[-1,filter_col]


bullo=bullo%>%
  apply(2,as.character)

grep(names(bullo))



not_empty_competence=apply(bullo,2,function(x)sum(!x==""))
not_empty_competence=names(not_empty_competence[not_empty_competence>0])
not_empty_competence=setdiff(not_empty_competence,c("symbole","nom"))

build_graph=function(nm){
ind=which(bullo[,nm]=="1")
src=bullo[ind,"nom"]
target=rep(nm,length(src))
networkData <- data.frame(source=src, target,value=1)
return(networkData)}
# nm=sample(not_empty_competence,1)
# build_graph(nm)
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
             opacity=.7,charge = -100)





