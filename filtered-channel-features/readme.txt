In this code, Checkerboards detector is implemented based on Piotr Dollar's toolbox V3.40 (http://vision.ucsd.edu/~pdollar/toolbox/doc/).
This version is more adaptive to different filter banks with minor changes to the toolbox, but gives slightly worse performance and runs slower than the original implementation.
In this code, pre-shrink and post-shrink factors are both set to 1 as default, which can be changed easily as needed.
Changes only in:(1) acfDemoCal.m (2) acfTrain.m (3) acfTest.m

1. Compilation.
Run ./external/toolboxCompile.m to compile the toolbox.

2. Run our detector.
There is a pre-trained model stored in ./models_Caltech/Checkerboards/.
To run our detector on your data, you just run ./detector/acfDemoCal.m, but please make sure you specify the right paths to the code and test data in ./detector/acfDemoCal.m.
'CodePath': path to the code
'testdataDir': path to test images;
'testgtDir': path to test annotations (one txt file per image);
'vbbDir': path to original vbb files (used for evaluation). 

It is also possible to run our detector without evaluation and visualize the detections on a given image. 
See the section of "%% run detector on a set of images without evaluation" in ./detector/acfDemoCal.m.

3. Train your own model.
In ./detector/acfDemoCal.m, training procedure is followed by testing and evaluation.
If you want to train your own model, please specify the paths to your training data:
'opts.posImgDir': path to training images;
'opts.posGtDir': path to training annotations (one txt file per image);
and please also change the parameter of 'versionstr';otherwise, the pre-trained model will be loaded and the training procedure will be skipped.
The trained model, log file, test detections and evaluation curve will be saved in ./models_Caltech/[versionstr]/.

4. Use different types of filters.
In the function of 'chnsCorrelation' in ./detector/acfTrain.m, the pre-computed Checkerboards filters are loaded from a mat file. 
If you want to use different filter banks, you can either compute it here; or write your filters into a mat file and load it here. 
In commented lines below Checkerboards filters, we show examples for SquaresChnFtrs_filters and RotatedFilters (see details in the paper: http://www.cv-foundation.org/openaccess/content_cvpr_2016/papers/Zhang_How_Far_Are_CVPR_2016_paper.pdf).
The pre-trained model for RotatedFilters can be found in ./models_Caltech/RotatedFilters/.
Note for RotatedFilters, we used a post-shrink of 2 for the filtered feature map (please change the code accrodingly when you use our pre-trained model).
In principle, each detector can be accelerated by using a pre-shrink factor like what we did in the CVPR15_codebase.


