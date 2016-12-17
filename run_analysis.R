## R script called run_analysis.R that does the following:

## Merges the training and the test sets to create one data set.
## Extracts only the measurements on the mean and standard deviation for each measurement.
## Uses descriptive activity names to name the activities in the data set
## Appropriately labels the data set with descriptive variable names.
## From the data set in step 4, creates a second, independent tidy data set 
## with the average of each variable for each activity and each subject.

## create the directory for the data
if(!file.exists("./data")){dir.create("./data")}

## download the data file
fileURL <-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile="./data/UCI_HAR_Dataset.zip")

## unzip data files into the /data directory
unzip(zipfile="./data/UCI_HAR_Dataset.zip",exdir="./data")

## read features table to name columns during reading the test and train data
features <- read.table("./data/UCI HAR Dataset/features.txt")

## read test .txt data files into table variables in parallel naming columns
x_test<-read.table("./data/UCI HAR Dataset/test/X_test.txt", col.names = features$V2)
y_test<-read.table("./data/UCI HAR Dataset/test/y_test.txt", col.names = "activityID")
subject_test<-read.table("./data/UCI HAR Dataset/test/subject_test.txt", col.names="subjectID")

## read train .txt data files into table variables in parallel naming columns
x_train <-read.table("./data/UCI HAR Dataset/train/X_train.txt", col.names = features$V2)
y_train <-read.table("./data/UCI HAR Dataset/train/y_train.txt", col.names = "activityID")
subject_train <-read.table("./data/UCI HAR Dataset/train/subject_train.txt", col.names="subjectID")

## read activity labels to match with activity ID - requirement for a tidy data set
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt", col.names = c("activityID", "activityType"))

## Extract only the measurements on the mean and standard deviation for each measurement
test_mean_std <- x_test[grep("mean()|std()", colnames(x_test))]
train_mean_std <- x_train[grep("mean()|std()", colnames(x_train))]

## Add Activity ID and Subject ID as columns to the data set (separately for test and train)
train_set<- cbind(subject_train, y_train, train_mean_std)
test_set<- cbind(subject_test, y_test, test_mean_std)

## merge the test and train data sets across common columns
merged_set <- merge(train_set, test_set, all=TRUE)

## Change activity ID to names - tidy set requirement, human readable format, factor type
merged_set$activityID = factor(merged_set$activityID, labels = activity_labels$activityType)

## Create a second, independent tidy data set with the average of 
## each variable for each activity and each subject
tidy_set <- aggregate(. ~subjectID + activityID, merged_set,mean)

## write the tidy data set to a file
write.table(tidy_set, "tidy_set.txt", row.name=FALSE)