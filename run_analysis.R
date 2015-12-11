if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

##Unzip DataSet to /data directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")

library(dplyr)
library(data.table)
library(tidyr)

## Read the subject files
dataSubjectTrain <- tbl_df(read.table(file.path("~/Desktop/Data/UCI HAR Dataset", "train", "subject_train.txt")))
dataSubjectTest  <- tbl_df(read.table(file.path("~/Desktop/Data/UCI HAR Dataset", "test" , "subject_test.txt" )))

# Read activity files
dataActivityTrain <- tbl_df(read.table(file.path("~/Desktop/Data/UCI HAR Dataset", "train", "Y_train.txt")))
dataActivityTest  <- tbl_df(read.table(file.path("~/Desktop/Data/UCI HAR Dataset", "test" , "Y_test.txt" )))

#Read data files
dataTrain <- tbl_df(read.table(file.path("~/Desktop/Data/UCI HAR Dataset", "train", "X_train.txt" )))
dataTest  <- tbl_df(read.table(file.path("~/Desktop/Data/UCI HAR Dataset", "test" , "X_test.txt" )))

## 1. Merging data
alldataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
setnames(alldataSubject, "V1", "subject")
alldataActivity<- rbind(dataActivityTrain, dataActivityTest)
setnames(alldataActivity, "V1", "activityNum")

dataTable <- rbind(dataTrain, dataTest)

dataFeatures <- tbl_df(read.table(file.path("~/Desktop/Data/UCI HAR Dataset", "features.txt")))
setnames(dataFeatures, names(dataFeatures), c("featureNum", "featureName"))
colnames(dataTable) <- dataFeatures$featureName

activityLabels<- tbl_df(read.table(file.path("~/Desktop/Data/UCI HAR Dataset", "activity_labels.txt")))
setnames(activityLabels, names(activityLabels), c("activityNum","activityName"))

alldataSubjAct<- cbind(alldataSubject, alldataActivity)
dataTable <- cbind(alldataSubjAct, dataTable)

## 2. Extract only mean and std dev
dataFeaturesMeanStd <- grep("mean\\(\\)|std\\(\\)",dataFeatures$featureName,value=TRUE)
dataFeaturesMeanStd <- union(c("subject","activityNum"), dataFeaturesMeanStd)
dataTable<- subset(dataTable,select=dataFeaturesMeanStd) 

## 3. Use descriptive activity names to name the activities 
dataTable <- merge(activityLabels, dataTable , by="activityNum", all.x=TRUE)
dataTable$activityName <- as.character(dataTable$activityName)
dataAggr<- aggregate(. ~ subject - activityName, data = dataTable, mean)
dataTable<- tbl_df(arrange(dataAggr,subject,activityName))

## 4. Appropriately labels the data set with descriptive variable names
1. leading t or f is based on time or frequency measurements.
2. Body = related to body movement.
3. Gravity = acceleration of gravity
4. Acc = accelerometer measurement
5. Gyro = gyroscopic measurements
6. Jerk = sudden movement acceleration
7. Mag = magnitude of movement
8. mean and SD are calculated for each subject for each activity for each mean and SD measurements. The units given are g???s for the accelerometer and rad/sec for the gyro and g/sec and rad/sec/sec for the corresponding jerks.

head(str(dataTable),2)

## 5. create a second independent tidy data set with the average of each variable for each activity and each subject
write.table(dataTable, "TidyData.txt", row.name=FALSE)

