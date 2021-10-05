library(data.table)
devtools::install_github("jeromefroe/circlepackeR")
# devtools::install_github("phileas-condemine/circlepackeR")
library(circlepackeR)
library(ggraph)
# We need to convert the network to a nested data frame. the data.tree library is our best friend for that:
library(data.tree)
# source("global.R")
# source("prep_bullo_etalab.R")
# source("prep_bullo_eig18.R")
source("prep_bullo_mentor19.R")

##### BULLO TO TREE ####

bullo_melt=melt(bullo[,setdiff(names(bullo),"symbole")])
bullo_melt=data.table(bullo_melt)
bullo_melt$variable=as.character(bullo_melt$variable)
bullo_melt=bullo_melt[value==1]
bullo_melt$value=NULL
setnames(bullo_melt,c("variable","nom"),c("from","to"))
split_concept=data.table(to=bullo_melt$from,from=bullo_melt$from,stringsAsFactors = F)
split_concept$from=gsub(paste(paste0("\\.",concepts),collapse="|"),"",split_concept$from)
root=data.table(to=split_concept$from,from="bulloterie",stringsAsFactors = F)
split_concept=split_concept[!from==to]
bullo_melt=rbind(root,split_concept,bullo_melt)
bullo_melt=bullo_melt%>%mutate_all(function(x)gsub("(\\.)|(\\/)","_",x))
bullo_melt=unique(bullo_melt)

#### TREE TO DFTREE ####



data_tree <- FromDataFrameNetwork(bullo_melt,"check")
# print(data_tree)
data_nested=ToDataFrameTree(data_tree, 
                            level1 = function(x) x$path[2],
                            level2 = function(x) x$path[3],
                            level3 = function(x) x$path[4],
                            level4 = function(x) x$path[5]
                            )[-1,-1]
data_nested=data_nested[,!sapply(data_nested,function(x)sum(is.na(x))==length(x))]
data_nested=na.omit(data_nested)

# Now we can plot it as seen before!
paste1=function(...){paste("roots",..., sep = "/")}
data_nested$pathString <- do.call("paste1",data_nested)
data_nested$value=1
data_Node <- as.Node(data_nested)


data_json=ToListExplicit(data_tree, unname = T,nameName = "name",childrenName="children")
data_json=jsonlite::toJSON(data_json,auto_unbox = TRUE)
# data_json=ToListSimple(data_Node, unname = T)
jsonlite::write_json(data_json,path = "data_node.json",auto_unbox=T)
data_json_read=jsonlite::read_json("data_node.json")


# devtools::install_github("phileas-condemine/circlepackeR")
library(circlepackeR)
viz_bullo <- circlepackeR(data_Node, size = "value",width = "1000px",height = "1000px")
# circlepackeR(jsonlite::toJSON(jsonlite::fromJSON("data_node.json"), auto_unbox = TRUE, 
#         dataframe = "rows"), size = "value",width = "1000px",height = "1000px")
library(htmlwidgets)
saveWidget(viz_bullo,file="viz_bullo_mentor.html")
