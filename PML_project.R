# Packages and libraries

if (!require(tidyr)){
  install.packages("tidyr")
  library(tidyr)
  }
if (!require(dplyr)){
  install.packages("dplyr")
  library(dplyr)
}
if (!require(ggplot2)){
  install.packages("ggplot2")
  library(ggplot2)
}
if (!require(caret)){
  install.packages("caret")
  library(caret)
}
if (!require(glmnet)){
  install.packages("glmnet")
  library(glmnet)
}
if (!require(ranger)){
  install.packages("ranger")
  library(ranger)
}
if (!require(VIM)){
  install.packages("VIM")
  library(VIM)
}
if (!require(randomForest)){
  install.packages("randomForest")
  library(randomForest)
}


# download the datasets
train_url <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
test_url <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"

train_file <- paste(getwd(),"train_data.csv", sep = "/")
test_file <- paste(getwd(),"test_data.csv",sep = "/")

if (!file.exists(train_file)){
  download.file(url=train_url,
                destfile = train_file)
}

if (!file.exists(test_file)){
  download.file(url=test_url,
                destfile = test_file)
}

# Importing Data

training <- read.csv("train_data.csv", 
                     na.strings = c('#DIV/0!','','NA'),
                     stringsAsFactors = F
                     )
testing <- read.csv("test_data.csv",
                    na.strings = c('#DIV/0!','','NA'),
                    stringsAsFactors = F
                    )

# Understanding the datasets. 
View(training)
View(testing)

str(training)
str(testing)

summary(training)
summary(testing)

# training data: change variable class
training$new_window <- as.factor(training$new_window)
training$kurtosis_yaw_belt <- as.numeric(training$kurtosis_yaw_belt)
training$skewness_yaw_belt <- as.numeric(training$skewness_yaw_belt)
training$kurtosis_yaw_dumbbell <- as.numeric(training$kurtosis_yaw_dumbbell)
training$skewness_yaw_dumbbell <- as.numeric(training$skewness_yaw_dumbbell)
training$cvtd_timestamp <- as.factor(training$cvtd_timestamp)

# testing data: change variable class
testing$new_window <- as.factor(testing$new_window)
testing$kurtosis_yaw_belt <- as.numeric(testing$kurtosis_yaw_belt)
testing$skewness_yaw_belt <- as.numeric(testing$skewness_yaw_belt)
testing$kurtosis_yaw_dumbbell <- as.numeric(testing$kurtosis_yaw_dumbbell)
testing$skewness_yaw_dumbbell <- as.numeric(testing$skewness_yaw_dumbbell)
testing$cvtd_timestamp <- as.factor(testing$cvtd_timestamp) 

# The plot shows several variables with high proportions of missing data, with some variables nearly missing entirely.
png('training_missing_plot.png', width = 640, height = 480, units = "px" )
training_missing_plot <- aggr(training)
dev.off()

# How much data is missing?
sum(is.na(training))/(dim(training)[1]*dim(training)[2])

# Missing values fraction by column / variable
missCol <- apply(training, 2, function(x) sum(is.na(x)/length(x)))

# Distribution of missing variables
png('missing_variables_hist.png',
    width = 720, height = 640, units = 'px')
hist(missCol, main = "Missing Data by Variable")
dev.off()

missIndCol <- which(missCol > 0.9)
length(missIndCol)

# Remove variables
## remove missing variables from training and test set
train_missing_values <- training[, -missIndCol]
test_missing_values <- testing[,-missIndCol]

## remove raw count variable and raw time stamps
train_clean <- train_missing_values[,-c(1,3,4)]
test_clean <- test_missing_values[,-c(1,3,4)]

# The plot shows several variables with high proportions of missing data, with some variables nearly missing entirely.
png('train_clean_missing_plot.png', width = 640, height = 480, units = "px" )
train_clean_missing_plot <- aggr(train_clean)
dev.off()

# Complete Cases
sum(!complete.cases(train_clean))

# Fit a Random Forest
modFor  <- train(classe~., 
                 data = train_clean, 
                 method = "rf", 
                 trControl = trainControl(method = "cv", number = 10, verboseIter = FALSE), 
                 na.action = na.pass)


modFor

getTrainPerf(modFor)


prediction_test <- predict(modFor,
                           newdata = test_clean)

prediction_test

png('randomForest_accuracy.png', width = 640, height = 640, units = 'px')
plot(modFor, main="RF Model Accuracy by number of predictors" ,cex=4)
dev.off()







