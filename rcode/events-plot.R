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


# load matrices
models = c("athletesCIT", "athletesEV", "athletesRF", "athletesANN")


################################
# plotting function
source("~/github/cs590ml/poster/heatmapNew.R")
colfunc = colorRampPalette(c("white", "steelblue"))
myHeatmap = function(matrix){

  # todo: gsub "Men's" and "Women's" in rownames and colnames
  rnames = rownames(matrix)
  cnames = colnames(matrix)
  rnames2 = gsub("Men's", "M", rnames)
  rnames2 = gsub("Women's", "W", rnames2)
  cnames2 = gsub("Men's", "M", cnames)
  cnames2 = gsub("Women's", "W", cnames2)
  rownames(matrix) = rnames2
  colnames(matrix) = cnames2

  heatmapNew(matrix[nrow(matrix):1,], Rowv=NA, Colv=NA,
    col=colfunc(100), 
    cexRow = 0.3 + 1/log10(nrow(matrix)),
    cexCol = 0.1 + 1/log10(ncol(matrix)),
    scale="row",
    xlab="Predicted Event",
    ylab="Actual Event",
    margins=c(7,1,10)
  )
}
# athletesANNmatrix
# myHeatmap(athletesANNmatrix)



################################
# get accuracy and plot

modelCheck = function(mname){
  cat("Model:", mname, "\n")
  mpath = paste("rcode/", mname, ".rda", sep="")
  cat(mpath, "\n")
  model = get(load(mpath))

  if(mname=="athletesANN"){
    type="class"
  } else {
    type="response"
  }

  if(mname=="athletesMclust"){
    trnPred = predict(model, trnData, type=type)$classification
    tstPred = predict(model, tstData, type=type)$classification
  } else {
    trnPred = predict(model, trnData, type=type)
    tstPred = predict(model, tstData, type=type)
  }

  # training data
  mtrx = table(trnClass, trnPred)
  filename = paste("graphics/", mname, "-trn.pdf", sep="")
  pdf(filename)
    myHeatmap(mtrx)
  dev.off()
  acc1 = mean(trnPred==trnClass)
  cat("\tTrain accuracy:", acc1, "\n")

  # test data
  mtrx = table(tstClass, tstPred)
  filename = paste("graphics/", mname, "-tst.pdf", sep="")
  pdf(filename)
    myHeatmap(mtrx)
  dev.off()
  acc2 = mean(tstPred==tstClass)
  cat("\tTest accuracy:", acc2, "\n")

  rat = acc2/acc1
  cat("\tRatio:", rat, "\n")
}

?heatmap
source("~/github/cs590ml/poster/heatmapNew.R")

for(m in models){
  modelCheck(m)
}

# todo: adjust heatmap to account for longer event names
# todo: or relabel "Men's" to "M" and "Women's" to "W"


