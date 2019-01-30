
library(dplyr)
library(data.table)
library(rvest)

if(!"Bulloterie_mentors2019.RData"%in%list.files()){
download.file(url = "https://annuel.framapad.org/p/bulloterie_mentors/export/txt",
              destfile="Bulloterie_mentors2019.txt")  
bullmentors=readLines("Bulloterie_mentors2019.txt",encoding = "UTF-8")
bullmentors=strsplit(bullmentors,split = "( \\| )|( : )")
separation=which(lapply(bullmentors,length)==0)
ids=bullmentors[1:(separation-1)]
ids=unlist(ids)
ids=t(matrix(ids,nrow=2))
ids=data.table(ids)
setnames(ids,names(ids),c("symbole","nom"))
ids$symbole=tolower(ids$symbole)
bull=bullmentors[(separation+1):length(bullmentors)]
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
anti_join(bull,ids,by="symbole")$symbole
bullo=merge(ids,bull,by="symbole")
bullo=as.data.frame(bullo)
nm_competences=setdiff(names(bullo),c("symbole","nom"))
nm_competences=gsub("\\.expert","",nm_competences)
nm_competences=gsub("\\.interet","",nm_competences)
nm_competences=unique(nm_competences)
concepts=c("interet","expert")
save(bullo,concepts,nm_competences,file = "Bulloterie_mentors2019.RData")
}
load("Bulloterie_mentors2019.RData")