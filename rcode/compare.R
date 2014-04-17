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
# some models need it this way:
formula = sport.factor ~ Age + Height + Weight + Female
data = cbind(trnData, trnClass)

models = c("sportMclust", "sportCIT", "sportEV", "sportRF", "sportANN")

################################
# hc/mclust
# sportMclust = MclustDA(trnData, trnClass,
#   modelType="MclustDA",
#   modelNames="VEV")
# save(sportMclust, file="rcode/sportMclust.rda")
load("rcode/sportMclust.rda")

trnPred = predict(sportMclust, trnData, type="class")$classification
table(trnPred, trnClass)
1-mean(trnPred == trnClass)

tstPred = predict(sportMclust, tstData, type="class")$classification
table(tstPred, tstClass)
1-mean(tstPred == tstClass)

################################
# party - conditional inference tree
# sportCIT = ctree(formula, data=data)
# save(sportCIT, file="rcode/sportCIT.rda")
load("rcode/sportCIT.rda")

trnPred = predict(sportCIT)
table(trnPred, trnClass)
1-mean(trnPred == trnClass)

tstPred = predict(sportCIT, newdata=tstData)
table(tstPred, tstClass)
1-mean(tstPred == tstClass)

################################
# evtree
# sportEV = evtree(formula, data=data)
# save(sportEV, file="rcode/sportEV.rda")
load("rcode/sportEV.rda")

trnPred = predict(sportEV, trnData)
table(trnPred, trnClass)
1-mean(trnPred == trnClass)

tstPred = predict(sportEV, tstData)
table(tstPred, tstClass)
1-mean(tstPred == tstClass)

################################
# random forest 
# sportRF = randomForest(formula, data=data)
# save(sportRF, file="rcode/sportRF.rda")
load("rcode/sportRF.rda")

trnPred = predict(sportRF, trnData)
table(trnPred, trnClass)
1-mean(trnPred == trnClass)

tstPred = predict(sportRF, tstData)
table(tstPred, tstClass)
1-mean(tstPred == tstClass)

################################
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

trnPred = predict(sportANN, trnData, type="class")
table(trnPred, trnClass)
1-mean(trnPred == trnClass)

tstPred = predict(sportANN, tstData, type="class")
table(tstPred, tstClass)
1-mean(tstPred == tstClass)

sportANNmatrix = table(tstClass, tstPred)


################################
# compare models

# todo: make a list of models
#       iterate over them to get:
#       BIC
#       training error
#       test error
#       make a table

# todo: make a list of matrices
#       iterate over them to:
#       add colsums and rowsums
#       add col and row % accurate
#       add total accuracy

# todo: save matrices for plotting
