# tidydata

Coursera Excercise for "Getting and Cleaning Data"

## Runnign the script

```R
# Run this command at the root of the project to be able to acces the experiment data
# The output file 'tidy_data.txt' will be generated there as well
Rscript run_analysis.R
```
## What the script does?

The script first reads the information that is the same for both `train` and `test` data, such as the features and activity labels.

Afterwards, it creates a function, `tidy_data()` that produces a tidy data table containing the relevant test information (i.e. DataType - train or test, Subject ID, Activity, and the average and standard deviation features). This data presents legible column names, with the Activity names legible as well. The data is returned as a data.table structure.

A function was created since the same behaviour is repeated twice, for both `train` and `test` data.

Afterwards, with both tidy `train` and `test` data generated, both results are merged into one single table. This is referent to step 4 in the assignment.

Finally, with the single tidy table, the mean of each numerical column (i.e. all of them except Subject and Activity, since Type is removed) is calculated, and a second table with such means is generated, representing the mean of each subject performing each activity. This is the output that is generated.
 