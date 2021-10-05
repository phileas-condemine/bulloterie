library(r2d3)
r2d3(data = jsonlite::read_json("flare.json"), d3_version = 4, script = "circlepacking_r2d3.js")
source("circlePackeR.R")
r2d3(data = data_Node, d3_version = 4, script = "circlepacker_v4.js")
r2d3(data = jsonlite::read_json("data_node.json"), d3_version = 5, script = "circlepacker_v4.js")

circlepackeR(jsonlite::fromJSON("data_node.json"))





x = list(data = jsonlite::toJSON(jsonlite::fromJSON("data_node.json"), auto_unbox = TRUE, 
                        dataframe = "rows"))

htmlwidgets::createWidget(name = "circlepackeR", x, package = "circlepackeR")
