# set up workspace
rm(list=ls())
setwd('~/github/olympifier')
# install.packages('mclust', repo='http://cran.revolutionanalytics.com/')
library(mclust)
library(RColorBrewer)


# load data
athletes = read.csv('data/athletes-clean.csv', header=TRUE, as.is=TRUE)
dim(athletes)
head(athletes)
athletes = athletes[-which(athletes$Sport=="Athletics"),]
athletes$sport.factor = as.factor(athletes$Sport)
athletes$event.factor = as.factor(athletes$FirstEvent)
length(unique(athletes$sport.factor))


# set up training and test sets
features = c("Age", "Height", "Weight", "Female")
target = "sport.factor"
summary(athletes$kfold)
trnData = athletes[athletes$kfold <= 5, features]
tstData = athletes[athletes$kfold >  5, features]
trnClass = athletes[athletes$kfold <= 5, target]
tstClass = athletes[athletes$kfold >  5, target]
dim(trnData)
formula = sport.factor ~ Age + Height + Weight + Female

# find best model
models = c("EII", "VII", "EEE", "VVV", "VEV")
tab = matrix(NA, nrow=length(models), ncol=3)
rownames(tab) = models
colnames(tab) = c("BIC", "10-fold CV", "Test error")
for(i in seq(models)){
  print(models[i])
  mod = MclustDA(trnData, trnClass,
    modelType="MclustDA", modelNames=models[i])
  tab[i,1] = mod$bic 
  tab[i,2] = cv.MclustDA(mod, nfold=10, verbose=FALSE)$error
  pred = predict(mod, tstData)
  tab[i,3] = classError(pred$classification, tstClass)$errorRate
}
tab
# best: "VEV"

sportMclust = MclustDA(trnData, trnClass,
  modelType="MclustDA",
  modelNames="VEV")
save(sportMclust, file="rcode/sportMclust.rda")
load("rcode/sportMclust.rda")

# training set prediction
trnPred = predict(sportMclust, trnData, type="class")$classification
table(trnPred, trnClass)
1-mean(trnPred == trnClass)

# test set predictions
tstPred = predict(sportMclust, tstData, type="class")$classification
table(tstPred, tstClass)
1-mean(tstPred == tstClass)
