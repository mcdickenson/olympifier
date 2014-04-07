# set up workspace
setwd('~/github/olympifier')
library(mclust)
library(RColorBrewer)

# load data
athletes = read.csv('data/athletes.tsv', sep="\t", header=TRUE, as.is=TRUE)
colnames(athletes)[4] = "Height"
colnames(athletes)[6] = "Female"
# collapse a couple of narrow categories 
athletes$Sport = ifelse(grepl("Cycling", athletes$Sport), "Cycling", athletes$Sport)
athletes$Sport = ifelse(grepl("Athletics", athletes$Sport), "Athletics", athletes$Sport)
# sort(unique(athletes$Sport))
# sort(unique(athletes$Event))
# todo: may need to remove/collapse dressage (has horse names)
# todo: deal with those who participate in multiple events (how?)

# subset data
want.cols = c("Age", "Height", "Weight", "Female", "Gold", "Silver", "Bronze", "Total", "Sport", "Event")
want.rows = complete.cases(athletes[,c("Age", "Height", "Weight", "Sport", "Event")])

athletes = athletes[want.rows, want.cols]
dim(athletes) # 9,038 x 10

# add colors and symbols
athletes$Color = NA 
athletes$Symbol = NA 
sports = sort(unique(athletes$Sport))
colors = rep(brewer.pal(7,"Set1"),times=4)
symbols = rep(c(15,16,17,18),each=7)

sports.colors.symbols = cbind(sports, colors[1:length(sports)], symbols[1:length(sports)])
colnames(sports.colors.symbols) = c("sport", "color", "symbol")

for(i in 1:nrow(sports.colors.symbols) ){
  sport  = sports.colors.symbols[i, "sport"]
  color  = sports.colors.symbols[i, "color"]
  symbol = sports.colors.symbols[i, "symbol"]
  athletes$Color  = ifelse(athletes$Sport==sport, color, athletes$Color)
  athletes$Symbol = ifelse(athletes$Sport==sport, symbol, athletes$Symbol)
}

# set up cross-validation
nums = rep(1:10, times=1000)
set.seed(123)
kfold = matrix(NA, nrow=10000, ncol=10)
for(i in 1:10){
  kfold[,i] = sample(chars)
}
colnames(kfold) = paste("kfold", 1:10, sep="")
athletes = cbind(athletes, kfold[1:nrow(athletes),])
dim(athletes)

# visualize
features = c("Age", "Height", "Weight")
target = "Sport"
male   = athletes[which(athletes$kfold1==1 & athletes$Female==0),]
female = athletes[which(athletes$kfold1==1 & athletes$Female==1),]
dim(female)

crossPlot = function(subset){
  clPairs(data = subset[, features], 
    classification = subset[, target],
    colors = subset$Color,
    symbols = as.numeric(subset$Symbol)
  )
}


pdf("graphics/crossplot-male.pdf")
crossPlot(male)
dev.off()

pdf("graphics/crossplot-female.pdf")
crossPlot(female)
dev.off()

pdf("graphics/crossplot-legend.pdf")
plot.new()
legend("left", 
  legend = sports.colors.symbols[,'sport'],
  col    = sports.colors.symbols[,'color'],
  pch    = as.numeric(
            sports.colors.symbols[,'symbol']
          ),
  cex=0.8
)
dev.off()

write.csv(athletes, file="data/athletes-mod.csv", row.names=FALSE)


