
library(data.table)
library(dplyr)
library(reshape2)

#load general information about this database
labels <- read.table("./Dataset/activity_labels.txt")[,2]
feat <- read.table("./Dataset/features.txt")[,2]


#extract mean and deviation
meansd <- grepl("mean|std", feat)

#load test and training sets
testx <- read.table("./Dataset/test/X_test.txt")
testy <- read.table("./Dataset/test/y_test.txt")
trainx <- read.table("./Dataset/train/X_train.txt")
trainy <- read.table("./Dataset/train/y_train.txt")

#set names columns to keep just the relevant data for the X files
colnames(testx) <- feat
testx <- testx[,meansd]

colnames(trainx) <- feat
trainx <- trainx[,meansd]

#set activity labels for y files
testy$labels <- labels[testy$V1]
trainy$labels <- labels[trainy$V1]

#load subjects

test_sub <- read.table("./Dataset/test/subject_test.txt")
train_sub <- read.table("./Dataset/train/subject_train.txt")

#bind all test and train data

test_data <- cbind(test_sub, testy, testx)
train_data <- cbind(train_sub, trainy, trainx)

#bind all of the data 
data <- rbind(test_data, train_data)

#names for the first 3 columns
colnames(data)[1:3] <- c("Subject", "Activity ID", "Activity")

#names for the rest of the data 

names(data)
names(data) <-gsub("Acc", "Acceleration ", names(data))
names(data) <-gsub("Gyro", "Gyroscope ", names(data))
names(data) <-gsub("Mag", "Magnitude ", names(data))
names(data) <-gsub("^t", "Time ", names(data))
names(data) <-gsub("^f", "Frequency ", names(data))
names(data) <-gsub("-mean()", "Mean ", names(data), ignore.case = TRUE)
names(data)<-gsub(".std()", "STD ", names(data), ignore.case = TRUE)
names(data)<-gsub("meanFreq()", "Mean Frequency ", names(data), ignore.case = TRUE)
names(data)<-gsub("angle", "Angle ", names(data))
names(data)<-gsub("gravity", "Gravity ", names(data))
names(data)<-gsub("BodyBody|Body", "Body ", names(data))
names(data)<-gsub("Jerk", "Angular Velocity ", names(data))

#finding the means using the function aggregate

tidyData <- aggregate(x = data, by = list(data$Subject, data$Activity), FUN = "mean")
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]

#write new database

write.table(tidyData, file = "Tidy.txt", row.names = FALSE)
