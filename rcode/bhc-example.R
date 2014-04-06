require(graphics)
require(BHC)
require(affydata)
require(gcrma)

data(Dilution)
ai        <- compute.affinities(cdfName(Dilution))
Dil.expr  <- gcrma(Dilution,affinity.info=ai,type="affinities")
testData  <- exprs(Dil.expr)
keep      <- sd(t(testData))>0
testData  <- testData[keep,]
testData  <- testData[1:100,]
geneNames <- row.names(testData)

nGenes         <- (dim(testData))[1];
nFeatures      <- (dim(testData))[2];
nFeatureValues <- 4
##NORMALISE EACH EXPERIMENT TO ZERO MEAN, UNIT VARIANCE
for (i in 1:nFeatures){
    newData      <- testData[,i]
    newData      <- (newData - mean(newData)) / sd(newData)
    testData[,i] <- newData
}
##DISCRETISE THE DATA ON A GENE-BY-GENE BASIS
##(defining the bins by equal quartiles)
for (i in 1:nGenes){
  newData      <- testData[i,]
  newData      <- rank(newData) - 1
  testData[i,] <- newData
}
##PERFORM THE CLUSTERING
hc <- bhc(testData, geneNames, nFeatureValues=nFeatureValues)

%%NOW GENERATE THE ACTUAL PLOT
plot(hc, axes=FALSE)

##OUTPUT CLUSTER LABELS TO FILE
WriteOutClusterLabels(hc, "labels.txt", verbose=FALSE)
