library(rvest)
library(data.table)
library(dplyr)
if(!"bulloterie_etalab.RData"%in%list.files()){
  
  if(!"bulloterie_etalab.txt"%in%list.files()){
  doc=read_html("https://pad.etalab.studio/s/r1fzFRaQE")
  doc%>%
    html_nodes("#doc")%>%
    html_text()%>%
    writeLines(con = "bulloterie_etalab.txt")
  }
  
bulletalab=readLines("bulloterie_etalab.txt")
bulletalab=strsplit(bulletalab,split = "( \\| )|( : )")
separation=which(lapply(bulletalab,length)==0)
separation=separation[1]
ids=bulletalab[1:(separation-1)]
ids=unlist(ids)
ids=t(matrix(ids,nrow=2))
ids=data.table(ids)
setnames(ids,names(ids),c("symbole","nom"))
ids$symbole=tolower(ids$symbole)
bull=bulletalab[(separation+1):length(bulletalab)]
bull=lapply(bull,tm::stripWhitespace)
bull <- bull[!bull==" "]
bull <- lapply(bull,function(x)x[!x%in%c(" ","")])
bull <- lapply(bull,function(x)gsub("^ ","",x))
bull <- lapply(bull,function(x)gsub(" $","",x))
names(bull) <- lapply(bull,function(x)paste0(x[1],".",x[2]))
bull <- lapply(bull,function(x){
  if(length(x)>2)x[3:length(x)]else c("")})
bull_vec=unlist(bull)
bull_sp=data.table(name=names(bull_vec),id=bull_vec)
bull_sp$id=tolower(bull_sp$id)
bull_sp$name=gsub("[0-9]","",bull_sp$name)
bull=dcast(bull_sp,formula = id~ name)
setnames(bull,"id","symbole")
# test de cohérence, est-ce que des symboles sont passés à la trappe ?
anti_join(bull,ids,by="symbole")$symbole
bullo=merge(ids,bull,by="symbole")
bullo=as.data.frame(bullo)
nm_competences=setdiff(names(bullo),c("symbole","nom"))
nm_competences=gsub("\\.expert","",nm_competences)
nm_competences=gsub("\\.interet","",nm_competences)
nm_competences=gsub("\\.connait","",nm_competences)
nm_competences=unique(nm_competences)
concepts=c("interet","connait","expert")
save(bullo,concepts,nm_competences,file = "bulloterie_etalab.RData")
}


load("bulloterie_etalab.RData")
