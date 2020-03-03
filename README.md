# DeepHistology
A pan-cancer platform for mutation prediction from routine histology. This project has been submitted to a peer-reviewed journal.

## Main scripts and their input arguments

### autoDeepLearn

Argument | Default Value | Description
--- | --- | ---
experiment | '' |  which experiment to load
gpuDev     | 1 | GPU Device (1 or greater)
maxBlockNum | 1000 | number of blocks
trainFull | false | train on full dataset after xval
modelTemplate | shufflenet512 | which pretrained model
backwards | false | for each experiments, work backwards
binarizeQuantile | [] | split HI LO at this quantile (between 0 and 0.5), mean if empty
foldxval | 3 | if cross validation is used, this is the fold, default 3
aggregateMode | majority | how to pool block predictions per patient, 'majority', 'mean' or 'max'
saveTileTable | false | save a table for all tile predictions for viz
tableModeClini | XLSX | file format of clinical table, XLSX or CSV
hyper | default | set of hyperparameters, default, lowresource or verylowresource
valSet | [] | validation set proportion of training set to stop training early
filterBlocks |  | can be NORMALIZED or STROMA or TUMOR for specific training tasks
subsetTargetsBy | [] | subset the patients by a variable
subsetTargetsLevel | [] | subset the patients by this level in the variable
skipExistingTargets | false |  skip target prediction if result file exists
forgiveError | false | ignore errors during training and go on to the next task

### autoDeploy

Argument | Default Value | Description
--- | --- | ---
trainedModelID | [] | use a previously trained model for deployment
trainedModelFolder | [] |  path to previously trained model for deployment
    
### autoVisualize

Argument | Default Value | Description
--- | --- | ---
doPlot | false | show the ROC curve on screen
doPrint | false |  save the ROC to PDF and Imgs to PNG
plotThreshold  | false | plot the operating threshold on top
exportBlockPred | false |  save CSV file for maps
exportTopTiles | 0 | save top tiles
topPatients | 3 |  showcase tiles from these patients
plotFontSize | 12 |  font size for plots    
saveFormat | v6  | version of results file (debug only)   
plotAUCthreshold | 0.75 |  detailed visualization only for high performance targets
onlyExplicitTargets | true |  visualize only targets specified in experiment file
debugMode | false |  debug mode

## License
See separate License file which applies to all files within this repository unless noted otherwise. Please note that some functions in the subroutine folder are from third party sources and have their own license included in the file.
