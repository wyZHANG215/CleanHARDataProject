## download data
library(data.table)
fileurl = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if (!file.exists('./data/UCI HAR Dataset.zip')){
  download.file(fileurl,'./data/UCI HAR Dataset.zip', mode = 'wb')
  unzip("./data/UCI HAR Dataset.zip", exdir = './data')
}

## read and convert data
features <- read.csv('./data/UCI HAR Dataset/features.txt', header = FALSE, sep = ' ')
str(features)
features <- as.character(features[,2])

data.train.x <- read.table('./data/UCI HAR Dataset/train/X_train.txt')
data.train.y <- read.csv('./data/UCI HAR Dataset/train/y_train.txt', header = FALSE, sep = ' ')
data.train.subject <- read.csv('./data/UCI HAR Dataset/train/subject_train.txt',header = FALSE, sep = ' ')

str(data.train.x)
str(data.train.y)
str(data.train.subject)

data.train <-  data.frame(data.train.subject, data.train.y, data.train.x)
names(data.train) <- c(c('subject', 'activity'), features)

data.test.x <- read.table('./data/UCI HAR Dataset/test/X_test.txt')
data.test.y <- read.csv('./data/UCI HAR Dataset/test/y_test.txt', header = FALSE, sep = ' ')
data.test.subject <- read.csv('./data/UCI HAR Dataset/test/subject_test.txt', header = FALSE, sep = ' ')

data.test <-  data.frame(data.test.subject, data.test.y, data.test.x)
names(data.test) <- c(c('subject', 'activity'), features)

## 1. Merges the training and the test sets to create one data set.
data.all <- rbind(data.train, data.test)

## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
select.mean_std <- grep('mean|std', features)
data.sub <- data.all[,c(1,2,select.mean_std + 2)]

## 3. Uses descriptive activity names to name the activities in the data set
## 1 WALKING
## 2 WALKING_UPSTAIRS
## 3 WALKING_DOWNSTAIRS
## 4 SITTING
## 5 STANDING
## 6 LAYING
activity.labels <- read.table('./data/UCI HAR Dataset/activity_labels.txt', header = FALSE)
activity.labels <- as.character(activity.labels[,2])
data.sub$activity <- activity.labels[data.sub$activity]

## 4. Appropriately labels the data set with descriptive variable names.
name.new <- names(data.sub)
name.new <- gsub("[(][)]", "", name.new)
name.new <- gsub("^t", "TimeDomain-", name.new)
name.new <- gsub("^f", "FrequencyDomain-", name.new)
name.new <- gsub("Acc", "Accelerometer", name.new)
name.new <- gsub("Gyro", "Gyroscope", name.new)
name.new <- gsub("Mag", "Magnitude", name.new)
name.new <- gsub("std", "StandardDeviation", name.new)
names(data.sub) <- name.new

## 5. From the data set in step 4, creates a second, independent tidy data 
##    set with the average of each variable for each activity and each subject.
data.tidy <- aggregate(data.sub[,3:81], by = list(activity = data.sub$activity, subject = data.sub$subject),FUN = mean)
## export file
write.table(x = data.tidy, file = "./data/data_tidy.txt", row.names = FALSE)


