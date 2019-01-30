
library(dplyr)
library(data.table)
library(rvest)
library(googlesheets)
# PREMIERE AUTHENTIFICATION
# ttt <- gs_auth()  
# saveRDS(ttt, "ttt.rds") 

if(!"data_eig2018.RData"%in%list.files()){
if (!"Bulloterie.xlsx"%in%list.files()){
  # FAIRE UN BOUTON POUR FORCER LE REFRESH ?
  gs_auth(token = "ttt.rds") # from .rds file
  gs_object=gs_url(x = "https://docs.google.com/spreadsheets/d/1nDuxSBvG_KjZ99PoN1R8w6HEFY_R2JugKLPB6FY42O0/edit?usp=sharing")
  gs_download(gs_object,to="Bulloterie.xlsx",overwrite=T)
}

bullo=readxl::read_xlsx("Bulloterie.xlsx")
bullo=bullo[-1,]
bullo=bullo%>%mutate_at(3:ncol(bullo),function(x){
  x[x=="1.0"]<-"1"
  x[is.na(x)]<-"0"
  as.numeric(x)
})


nb_competences=round(ncol(bullo)/3)-1
nm_competences=names(bullo)[3*1:nb_competences]
concepts=c("interet","connait","expert")
grid_competences=expand.grid(nm_competences,concepts)
grid_competences<-grid_competences%>%arrange(Var1)%>%apply(1,function(x)paste(x,collapse = "."))
names(bullo)<-c("symbole","nom",grid_competences)
save(bullo,nm_competences,concepts,file="data_eig2018.RData")
}

load("data_eig2018.RData")
