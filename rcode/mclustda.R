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


# set up models
features = c("Age", "Height", "Weight", "Female")
target = "sport.factor"
summary(athletes$kfold)
trnData = athletes[athletes$kfold <= 5, features]
tstData = athletes[athletes$kfold >  5, features]
trnClass = athletes[athletes$kfold <= 5, target]
tstClass = athletes[athletes$kfold >  5, target]
dim(trnData)
dim(tstData)

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

# try again
sport.mclust = Mclust(trnData)
summary(sport.mclust)
summary(sport.mclust, parameters=TRUE)
plot(sport.mclust)

plot.new()
dev.off()

# try again
sportBIC = mclustBIC(trnData)
plot(sportBIC, legendArgs=list(x="topleft"))
sportBIC = mclustBIC(trnData, G=1:30)
summary(sportBIC, trnData)

sportModel = summary(sportBIC, data=trnData)
sportModel

# try again
defaultPrior(trnData, G=26, modelName="VII")
sportBICprior = mclustBIC(trnData, prior=priorControl())


# try with noise
set.seed(0)
sportNoiseInit = sample(c(TRUE, FALSE), 
  size=nrow(trnData),
  replace=TRUE,
  prob=c(1,1)
)
sportNbic = mclustBIC(trnData,
  initialization=list(noise=sportNoiseInit))
sportNsummary = summary(sportNbic, trnData)
sportNsummary