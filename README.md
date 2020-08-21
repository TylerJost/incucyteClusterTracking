# incucyteClusterTracking
Tracks clusters over time in Incucyte incubator. 

## Image Processing

Once the cell masks have been determined from the incucyte software, images can be downloaded to your computer. Make sure the image masks, not the direct images themselves, are downloaded. The accepted file name formatting is:

```ExperimentName_WellLetter_1_date```

For example:
```GH2003_B6_1_2020y02m03d_15h55m```

This format should be explicitly followed (specifically the date) in order to use the code provided. Files should be stored all together in one folder. To find cell centroids, use the script ```imagePlate.m```. Specify the location of the folder with all of the images for the plate, as well as the desired save location. On the first run, specify that you want to view the images within the ```plate2pic``` function:

```centroidCell{wellFile} = cellCountProcessed(wellFiles(wellFile),'view');```

Centroid files are saved in the .mat file format, with 3 variables per file.

| Variable  | Contents |
| ------------- | ------------- |
| centroidCell  | A cell array where each container is an nx2 vector of x/y locations within the well as determined by the Incucyte processing definition. Each container corresponds to a scan  |
| centroidCount  | An nx1 vector specifying the number of cells per scan |
| wellDates  | A cell array where each container contains the time of the scan in a ```datetime``` format as DD-MMM-YYYY hh:mm:ss| 


## Cluster Tracking
Cluster tracking, in this algorithm, is perhaps as much art as science. To get an initial feeling for what type of clusters are necessary, use the script ```checkWellMultipleclusters.m```. You will need to adjust 4 variables. 

### DBSCAN Variables
DBSCAN is the clustering algorithm used to find clusters of cells. You can read about it [here](https://en.wikipedia.org/wiki/DBSCAN). It requires two parameters: ```epsilon``` and ```minpts```. Epsilon can be thought of as a radius, which will sweep outwards and determine what points are part of the cluster and what points are not. Minpts is mostly self explanatory, as each cluster must have a minimum number of points which can be reached with epsilon. 

### Other Variables
There are two other variables which can be used to help more accurately track clusters. ```absMin``` is the absolute minimum number of cells in a cluster. This is primarily used for calibration of when tracking will start, as described in the next section. The final variable is ```sizeI```, which determines the increase of the polygon in which each cluster is tracked. 

### Calibration
The typical flow for cells within a well is to grow up, lose overall density after treatment, then form clusters as they grow. Eventually the overall density of cells in the well will greatly increase. 

This flow is problematic because the algorithm searches for dense clusters of cells. If the entire well is densely populated with cells, clusters will not be correctly identified. Therefore, a calibration process is required to know when there are actually clusters. This is done with a long seires of conditional logic in ```autoCalibrateAnalysisStart```. Each cluster needs a minimum number of cells, as determined by ```absMin```. This can be highly dependent on the cell type and conditions, and should be adjusted as needed. 

When choosing ```epsilon```, the calibration script can step in and help. Occasionally a well will have a less dense well. To counter this, the calibration step aims to find an epsilon value which finds clusters which are not too large of a percentage of the cell by increasing the epsilon value incrementally. 

### Tracking Over Time
The mechanics behind the cluster tracking is in the function ```trackClusters```. Once calibration is complete, this will incorporate that information and track the clusters over time. Briefly this works as follows:

* Mark a polygon around the area of the determined clusters for the next time point. 
* Use the identified variables to find a new cluster. 
  * Recall that the polygon will be larger than the cluster, as determined by ```sizeI```. 
* The DBSCAN algorithm will inevitably find many clusters, most of which are not actual clusters. However, if a cluster is large enough relative to the previous cluster, it will split and count as two clusters. 
* The algorithm continues until it can no longer find a cluster. 

### Troubleshooting for Better Cluster Tracking
While one parameter set might work for one well, it likely won't work for all wells. It is important to find the ideal set of parameters which works for the most wells (obviously). Once you are happy with a set of parameters (or think you are), a practice run should be performed on all wells in the plate. This is done using ```runRapidValidation```. To validate your parameter set, use the set of images in the "wellsSnapshot" folder which should be created. Adjust any necessary parameters and readjust per the table below.

Finally, to fully validate and determine how satisfied you are with your parameter set, you should generate videos using ```Video Maker.ipynb```. 

| Variable  | Adjustments |
| ------------- | ------------- |
| epsilon  | Increase for less dense clusters, decrease for denser clusters.  |
| minpts | Increase when clusters are not tracking for long enough. Typically, this is used for less dense clusters which end prematurely. |
| absMin  | Adjust rarely when calibration is not working properly. This is a case by case basis. |
| sizeI | Increase when clusters are not tracking for long enough, typically near the end when they are close to disappearing but need a stronger push. |



## Tracking an Entire Plate
Calibrating for each plate is the most difficult part, and once the ideal parameters are deter
