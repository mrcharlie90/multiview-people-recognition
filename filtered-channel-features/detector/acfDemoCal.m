% Demo for aggregate channel features object detector on Caltech dataset.
%
% See also acfReadme.m
%
% Piotr's Computer Vision Matlab Toolbox      Version 3.40
% Copyright 2014 Piotr Dollar.  [pdollar-at-gmail.com]
% Licensed under the Simplified BSD License [see external/bsd.txt]

%% extract training and testing images and ground truth
clc;
CodePath = '/BS/shanshan-projects/work/CheckerBoards_LDCF_codebase';
addpath(genpath(CodePath));
versionstr = 'Checkerboards';

%% set up opts for training detector (see acfTrain)
traindataDir = '/BS/shanshan-projects/work/Datasets/Caltech_Pedestrians/train_10Hz';
testdataDir = '/BS/shanshan-projects/work/Datasets/Caltech_Pedestrians/test';
testgtDir = '/BS/shanshan-projects/work/Datasets/Caltech_Pedestrians/test/annotations';

opts=acfTrain(); opts.modelDs=[96 36]; opts.modelDsPad=[120 60];
opts.pPyramid.smooth=0;opts.pPyramid.pChns.pColor.smooth=0;opts.pPyramid.nApprox = 0;
opts.nWeak=[32 512 1024 2048 4096];

opts.pBoost.pTree.maxDepth=4; opts.pBoost.discrete=0;
opts.pBoost.pTree.fracFtrs=1; opts.nNeg=10000; opts.nAccNeg=50000;
opts.pPyramid.pChns.pGradHist.softBin=1; opts.pJitter=struct('flip',1);
opts.pPyramid.pChns.pGradHist.clipHog = Inf;
opts.pPyramid.nOctUp = 1;
    
opts.posGtDir=[traindataDir '/annotations'];
opts.posImgDir=[traindataDir '/images'];

opts.pPyramid.pChns.shrink=6; opts.stride=6;
opts.name=[CodePath 'models_Caltech/' versionstr '/Checkeboards'];
pLoad={'lbls',{'person'},'ilbls',{'people'},'squarify',{3,.41}};
opts.pLoad = [pLoad 'hRng',[50 inf], 'vRng',[1 1] ];
opts.cascThr = -1;

%% train detector (see acfTrain)
detector = acfTrain( opts );

%% modify detector (see acfModify)
pModify=struct('cascThr',-1,'cascCal',0.1,'nOctUp',1,'nPerOct',10);
detector=acfModify(detector,pModify);
save([opts.name 'Detector.mat'],'detector');

sprintf('time=\t'); fix(clock)
sprintf('\n');
%% run detector on a sample image (see acfDetect)
% imgNms=bbGt('getFiles',{[dataDir 'test/images']});
% I=imread(imgNms{1862}); tic, bbs=acfDetect(I,detector); toc
% figure(1); im(I); bbApply('draw',bbs); pause(.1);

%% test detector and plot roc (see acfTest)
vbbDir='/BS/shanshan-projects/work/Datasets/Caltech_Pedestrians/';
tstart = tic;[miss,~,gt,dt]=acfTest(1, vbbDir,'name',opts.name,'imgDir',testdataDir ,...
      'gtDir',testgtDir,'pLoad',[pLoad, 'hRng',[50 inf],...
      'vRng',[.65 1],'xRng',[5 635],'yRng',[5 475]],'show',2);telapsed = toc(tstart);
fid = fopen([opts.name 'Log.txt'],'a'); 
fprintf(fid,'\n test time=%f seconds = %f hours\n',telapsed, telapsed/3600);
fclose(fid);

sprintf('time=\t'); fix(clock)
sprintf('\n');
close all;
