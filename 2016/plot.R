# set up workspace
setwd('~/github/olympifier/2016')
library(mclust)
library(RColorBrewer)
library(stringr)

# load data
athletes = read.csv('data/usa2016_clean.csv', header=TRUE, as.is=TRUE)
# athletes = read.csv('data/usa2016_with_images_clean.csv', header=TRUE, as.is=TRUE)

# tranform height into inches
athletes$height_feet = strtoi(str_split_fixed(athletes$height, '-', 2)[,1])
athletes$height_inches = strtoi(str_split_fixed(athletes$height, '-', 2)[,2])
athletes$height_converted = athletes$height_feet * 12 + athletes$height_inches

# transform dob into age
athletes$dob = as.Date(athletes$dob, format="%m/%d/%Y")
olympics_start = as.Date("8/5/2016", format="%m/%d/%Y")
athletes$age = olympics_start - athletes$dob
athletes$age = as.numeric(athletes$age, units="days")/365
athletes$age = ifelse(athletes$age > 100, NA, athletes$age)

# output data for shiny
# athletes$height = athletes$height_converted
# athletes$weight = as.numeric(athletes$weight)
# want.cols = c('sport', 'name', 'height', 'weight', 'age', 'link', 'img')
# want.rows = complete.cases(athletes[,want.cols])
# athletes = athletes[want.rows, want.cols]
# write.csv(athletes, file="data/athletes_shiny.csv", row.names=FALSE)

# transform gender into 1/0
athletes$female = ifelse(athletes$gender=="W", 1, 0)

# subset into complete cases
want.cols = c('name', 'sport', 'height_converted', 'weight', 'age', 'female')
want.rows = complete.cases(athletes[,want.cols])
dim(athletes) # 554 observations
athletes = athletes[want.rows, want.cols]
dim(athletes) # 518 observations

# add colors and symbols
athletes$color = NA
athletes$symbol = NA
sports = sort(unique(athletes$sport))
colors = rep(brewer.pal(6,"Set1"),times=5)
symbols = rep(c(21,22,23,24,25),each=6)
symbols = rep(c(7,9,10,12,13), each=6)

sports.colors.symbols = cbind(sports, colors[1:length(sports)], symbols[1:length(sports)])
colnames(sports.colors.symbols) = c("sport", "color", "symbol")

for(i in 1:nrow(sports.colors.symbols) ){
  sport  = sports.colors.symbols[i, "sport"]
  color  = sports.colors.symbols[i, "color"]
  symbol = sports.colors.symbols[i, "symbol"]
  athletes$color  = ifelse(athletes$sport==sport, color, athletes$color)
  athletes$symbol = ifelse(athletes$sport==sport, symbol, athletes$symbol)
}


# visualize
athletes$height = athletes$height_converted
athletes$weight = strtoi(athletes$weight)
features = c("age", "height", "weight")
target = "sport"
male   = athletes[which(athletes$female==0),]
female = athletes[which(athletes$female==1),]
dim(female)

crossPlot = function(subset){
  clPairs(data = subset[, features],
    classification = subset[, target],
    colors = subset$color,
    symbols = as.numeric(subset$symbol)
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

png("graphics/crossplot-male.png")
crossPlot(male)
dev.off()

png("graphics/crossplot-female.png")
crossPlot(female)
dev.off()

png("graphics/crossplot-legend.png")
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



png('graphics/combined-plot.png', width=480, height=960)
par(mfrow=c(1,7)) 
crossPlot(male)
crossPlot(female)
# plot.new()
# legend("left",
  # legend = sports.colors.symbols[,'sport'],
  # col    = sports.colors.symbols[,'color'],
  # pch    = as.numeric(
            # sports.colors.symbols[,'symbol']
          # ),
  # cex=0.8
# )
dev.off()



write.csv(athletes, file="data/athletes_mod.csv", row.names=FALSE)

# min and max of each value
athletes[which(athletes$height_converted==min(athletes$height_converted)), ]
athletes[which(athletes$height_converted==max(athletes$height_converted)), ]

athletes$weight = as.numeric(athletes$weight)
summary(athletes$weight)
athletes[which(athletes$weight==94), ]
athletes[which(athletes$weight==348), ]

athletes[which(athletes$age==min(athletes$age)), ]
athletes[which(athletes$age==max(athletes$age)), ]


