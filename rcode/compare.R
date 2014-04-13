# set up workspace
rm(list=ls())
setwd('~/github/olympifier')
library(evtree)
library(mclust)
library(nnet)
library(party)
library(RColorBrewer)
library(randomForest)


# load data
athletes = read.csv('data/athletes-clean.csv', header=TRUE, as.is=TRUE)
dim(athletes)
head(athletes)
athletes = athletes[-which(athletes$Sport=="Athletics"),]
athletes$sport.factor = as.factor(athletes$Sport)
athletes$event.factor = as.factor(athletes$FirstEvent)
length(unique(athletes$sport.factor))
sort(unique(athletes$sport.factor))


# set up training and test sets
features = c("Age", "Height", "Weight", "Female")
target = "sport.factor"
summary(athletes$kfold)
trnData = athletes[athletes$kfold <= 5, features]
tstData = athletes[athletes$kfold >  5, features]
trnClass = athletes[athletes$kfold <= 5, target]
tstClass = athletes[athletes$kfold >  5, target]
dim(trnData)

################################
# compare models

# hc/mclust

# party

# evtree

# random forest 

# neural net
# sportANN = nnet(trnData, ideal,
#   size=30,
#   MaxNWts=1500,
#   softmax=TRUE,
#   # censored=TRUE,
#   skip=TRUE,
#   maxit=1000)
# save(sportANN, file="rcode/sportANN.rda")
load("rcode/sportANN.rda")
