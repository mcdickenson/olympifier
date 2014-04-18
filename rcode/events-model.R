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
athletes = athletes[which(athletes$Sport=="Athletics"),]
athletes = athletes[which(athletes$Event!="Women's Triathlon"),]
athletes$sport.factor = as.factor(athletes$Sport)
athletes$event.factor = as.factor(athletes$FirstEvent)
length(unique(athletes$event.factor))
sort(unique(athletes$event.factor))


# set up training and test sets
features = c("Age", "Height", "Weight", "Female")
target = "event.factor"
summary(athletes$kfold)
trnData = athletes[athletes$kfold <= 5, features]
tstData = athletes[athletes$kfold >  5, features]
trnClass = athletes[athletes$kfold <= 5, target]
tstClass = athletes[athletes$kfold >  5, target]
# some models need it this way:
formula = event.factor ~ Age + Height + Weight + Female
data = cbind(trnData, trnClass)
colnames(data)[5] = target
# run models

################################
# hierarchical clustering
# models = c("EII", "VEV", "VII", "EEE", "VVV")
# models = c("VEV", "EEE", "VVV")
# mclust = Mclust(trnData, G=47, modelNames=models)
# summary(mclust) # EII

# athletesMclust = MclustDA(trnData, trnClass,
#   modelType="MclustDA",
#   modelNames="EII")
# save(athletesMclust, file="rcode/athletesMclust.rda")
# load("rcode/athletesMclust.rda")

# trnPred = predict(athletesMclust, trnData, type="class")$classification
# table(trnPred, trnClass)
# 1-mean(trnPred == trnClass)

# tstPred = predict(athletesMclust, tstData, type="class")$classification
# table(tstPred, tstClass)
# 1-mean(tstPred == tstClass)

################################
# party - conditional inference tree
athletesCIT = ctree(formula, data=data)
save(athletesCIT, file="rcode/athletesCIT.rda")
load("rcode/athletesCIT.rda")

trnPred = predict(athletesCIT)
table(trnPred, trnClass)
1-mean(trnPred == trnClass)

tstPred = predict(athletesCIT, newdata=tstData)
table(tstPred, tstClass)
1-mean(tstPred == tstClass)

################################
# evtree
athletesEV = evtree(formula, data=data)
save(athletesEV, file="rcode/athletesEV.rda")
load("rcode/athletesEV.rda")

trnPred = predict(athletesEV, trnData)
table(trnPred, trnClass)
1-mean(trnPred == trnClass)

tstPred = predict(athletesEV, tstData)
table(tstPred, tstClass)
1-mean(tstPred == tstClass)

################################
# random forest 
athletesRF = randomForest(formula, data=data)
save(athletesRF, file="rcode/athletesRF.rda")
load("rcode/athletesRF.rda")

trnPred = predict(athletesRF, trnData)
table(trnPred, trnClass)
1-mean(trnPred == trnClass)

tstPred = predict(athletesRF, tstData)
table(tstPred, tstClass)
1-mean(tstPred == tstClass)

################################
# neural net
ideal = class.ind(trnClass)
athletesANN = nnet(trnData, ideal,
  size=50,
  MaxNWts=3000,
  softmax=TRUE,
  # censored=TRUE,
  skip=TRUE,
  maxit=1000)
save(athletesANN, file="rcode/athletesANN.rda")
load("rcode/athletesANN.rda")

trnPred = predict(athletesANN, trnData, type="class")
table(trnPred, trnClass)
1-mean(trnPred == trnClass)

tstPred = predict(athletesANN, tstData, type="class")
table(tstPred, tstClass)
1-mean(tstPred == tstClass)

athletesANNmatrix = table(tstClass, tstPred)


