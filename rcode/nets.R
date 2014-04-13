# set up workspace
rm(list=ls())
setwd('~/github/olympifier')
# install.packages('nnet', repo='http://cran.revolutionanalytics.com/')
library(nnet)


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
# formula = sport.factor ~ Age + Height + Weight + Female

ideal = class.ind(trnClass)
dim(ideal)
summary(ideal)
head(ideal)

summary(trnClass)

# model
?nnet
?class.ind
sportANN = nnet(trnData, ideal,
  size=30,
  MaxNWts=1500,
  softmax=TRUE,
  # censored=TRUE,
  skip=TRUE,
  maxit=1000)
# save(sportANN, file="rcode/sportANN.rda")
load("rcode/sportANN.rda")
# todo: look at entropy

# training set predicitons
trnPred = predict(sportANN, trnData, type="class")
table(trnPred, trnClass)
1-mean(trnPred == trnClass)

# test set predictions
tstPred = predict(sportANN, tstData, type="class")
table(tstPred, tstClass)
1-mean(tstPred == tstClass)

sportANNmatrix = table(tstClass, tstPred)


