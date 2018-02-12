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

