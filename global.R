# install.packages("networkD3")
library(networkD3)
library(dplyr)
library(data.table)
library(googlesheets)

# PREMIERE AUTHENTIFICATION
# ttt <- gs_auth()  
# saveRDS(ttt, "ttt.rds") 
library(rvest)


# source("prep_bullo_eig18.R")
# source("prep_bullo_mentor19.R")


# bullo=bullo[,c(T,T,sapply(bullo[,3:ncol(bullo)],sum)>0)]# T, T pour sélectionner les 2 premières colonnes EIG et AKA
