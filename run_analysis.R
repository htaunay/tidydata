################################################
### Getting and Cleaning Data Course Project ###
################################################

library(data.table)
num_subjects = 30
data_folder = "UCI\ HAR\ Dataset"

features_file <- paste(data_folder, "/features.txt", sep="")
features_file_exists <- file.exists(features_file)
if( is.na(features_file_exists) || !features_file_exists ) {
	print(paste0("Features file not found: ", features_file))
	return(FALSE)
}

features <- read.table(features_file)
mean_and_std_ids <- grep("-mean()|-std()", features[,2])
mean_and_std_names <- features[mean_and_std_ids,2]
	
activity_file <- paste(data_folder, "/activity_labels.txt", sep="")
activity_file_exists <- file.exists(activity_file)
if( is.na(activity_file_exists) || !activity_file_exists ) {
	print(paste0("Activity file not found: ", activity_file))
	return(FALSE)
}

activities <- read.table(activity_file)

tidy_data <- function(dir, experiment_type) {

	dir <- paste("./", dir, sep="")
	dir_exists <- file.info(dir)$isdir
	if( is.na(dir_exists) || !dir_exists ) {
		print(paste0("Invalid directory given: ", dir))
		return(FALSE)
	}

	experiment_dir <- paste(dir, "/", experiment_type, sep="")
	exp_dir_exists <- file.info(experiment_dir)$isdir
	if( is.na(exp_dir_exists) || !exp_dir_exists ) {
		print(paste0("Invalid experiment type given: ", experiment_type))
		return(FALSE)
	}

	X_file <- paste(experiment_dir, "/X_", experiment_type, ".txt", sep="")
	X_file_exists <- file.exists(X_file)
	if( is.na(X_file_exists) || !X_file_exists ) {
		print(paste0("Experiment data file not found: ", X_file))
		return(FALSE)
	}

	X_set <- read.table(X_file)

	X_reduced_set <- X_set[,mean_and_std_ids]
	colnames(X_reduced_set) <- mean_and_std_names

	subjects_file <- 
		paste(experiment_dir, "/subject_", experiment_type, ".txt", sep="")
	subjects_file_exists <- file.exists(subjects_file)
	if( is.na(subjects_file_exists) || !subjects_file_exists ) {
		print(paste0("Subjects file not found: ", subjects_file))
		return(FALSE)
	}

	subjects <- (read.table(subjects_file))[,1]

	Y_file <- paste(experiment_dir, "/Y_", experiment_type, ".txt", sep="")
	Y_file_exists <- file.exists(Y_file)
	if( is.na(Y_file_exists) || !Y_file_exists ) {
		print(paste0("Experiment data not found: ", Y_file))
		return(FALSE)
	}

	Y_set <- (read.table(Y_file))
	for(i in activities[,1]) {
		Y_set[Y_set$V1 == i,] <- toString(activities[i,2])
	}
	Y_set <- Y_set[,1]

	type_vector = rep(experiment_type, length(Y_set))

	final_data_set <- cbind(type_vector, subjects,Y_set,X_reduced_set)
	colnames(final_data_set)[1] <- "Type"
	colnames(final_data_set)[2] <- "Subject"
	colnames(final_data_set)[3] <- "Activity"

	return(final_data_set)
}

test_data <- tidy_data(data_folder, "test")
train_data <- tidy_data(data_folder, "train")

complete_data <- rbind(test_data, train_data)

get_avgs <- function(data, activity, subject) {
	subset <- data[which(data$Activity == activity & data$Subject == subject),]
	non <- subset[1,1:3]
	non$Type <- NULL
	means <- colMeans(subset[,4:ncol(subset)])

	avgs <- means[1]
	for(i in 2:length(means)) {
		avgs <- cbind(avgs, means[i])
	}

	colnames(avgs) <- mean_and_std_names
	avgs <- cbind(non,avgs)

	return(avgs)
}

avg_data <- c()
for(i in 1:num_subjects) {
	for(j in activities[,1]) {
		subset <- get_avgs(complete_data, toString(activities[j,2]), i)
		if(length(avg_data) == 0) {
			avg_data <- subset
		}
		else {
			avg_data <- rbind(avg_data, subset)
		}
	}
}

write.table(avg_data, "tidy_data.txt", row.name=FALSE)
