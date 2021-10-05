library(rvest)
library(data.table)
library(dplyr)
if(!"bulloterie_eig2019.RData"%in%list.files()){
  
 

bullo=fread("Bulloterie EIG2019.csv",encoding="UTF-8")

ids=bullo[!Personnes=="",c("Symbole","Personnes")]
setnames(ids,names(ids),c("symbole","nom"))
ids$symbole=tolower(ids$symbole)

bullo2=bullo[Personnes=="",c("Symbole / Bulles","Compétences","Symbole")]

bull=strsplit(bullo2$Symbole,",")
names(bull) <- paste(bullo2$`Symbole / Bulles`,bullo2$`Compétences`,sep=".")



bull=lapply(bull,tm::stripWhitespace)
bull <- bull[!bull==" "]
bull <- lapply(bull,function(x)x[!x%in%c(" ","")])
bull <- lapply(bull,function(x)gsub("^ ","",x))
bull <- lapply(bull,function(x)gsub(" $","",x))
bull_vec=unlist(bull)
bull_sp=data.table(name=names(bull_vec),id=bull_vec)
bull_sp$id=tolower(bull_sp$id)
bull_sp$name=gsub("([0-9])+$","",bull_sp$name)
bull_sp$val=1
bull=dcast(bull_sp,formula = id ~ name,value.var = "val",fill = 0)
setnames(bull,"id","symbole")
# test de cohérence, est-ce que des symboles sont passés à la trappe ?
anti_join(bull,ids,by="symbole")$symbole
bullo=merge(ids,bull,by="symbole")
bullo=as.data.frame(bullo)
nm_competences=setdiff(names(bullo),c("symbole","nom"))
nm_competences=gsub("\\.Expert","",nm_competences)
nm_competences=gsub("\\.Interet","",nm_competences)
nm_competences=gsub("\\.Connait","",nm_competences)
nm_competences=unique(nm_competences)
concepts=c("Interet","Connait","Expert")
save(bullo,concepts,nm_competences,file = "bulloterie_eig2019.RData")
}


load("bulloterie_eig2019.RData")
