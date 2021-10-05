# https://www.r-graph-gallery.com/338-interactive-circle-packing-with-circlepacker/
library(circlepackeR)         # devtools::install_github("jeromefroe/circlepackeR")


# create a nested data frame giving the info of a nested dataset:
data=data.frame(
  root=rep("root", 15),
  group=c(rep("group A",5), rep("group B",5), rep("group C",5)), 
  subgroup= rep(letters[1:5], each=3),
  subsubgroup=rep(letters[1:3], 5),
  value=sample(seq(1:15), 15)
)

# Change the format. This use the data.tree library. This library needs a column that looks like root/group/subgroup/..., so I build it
library(data.tree)
data$pathString <- paste("world", data$group, data$subgroup, data$subsubgroup, sep = "/")
population <- as.Node(data)

# Make the plot
circlepackeR(population, size = "value")

# You can custom the minimum and maximum value of the color range.
circlepackeR(population, size = "value", color_min = "hsl(56,80%,80%)", color_max = "hsl(341,30%,40%)")