function [miss,roc,gt,dt] = acfTest(test, varargin )
% Test aggregate channel features object detector given ground truth.
%
% USAGE
%  [miss,roc,gt,dt] = acfTest( pTest )
%
% INPUTS
%  pTest    - parameters (struct or name/value pairs)
%   .name     - ['REQ'] detector name
%   .imgDir   - ['REQ'] dir containing test images
%   .gtDir    - ['REQ'] dir containing test ground truth
%   .pLoad    - [] params for bbGt>bbLoad for test data (see bbGt>bbLoad)
%   .pModify  - [] params for acfModify for modifying detector
%   .thr      - [.5] threshold on overlap area for comparing two bbs
%   .mul      - [0] if true allow multiple matches to each gt
%   .reapply  - [0] if true re-apply detector even if bbs already computed
%   .ref      - [10.^(-2:.25:0)] reference points (see bbGt>compRoc)
%   .lims     - [3.1e-3 1e1 .05 1] plot axis limits
%   .show     - [0] optional figure number for display
%
% OUTPUTS
%  miss     - log-average miss rate computed at reference points
%  roc      - [nx3] n data points along roc of form [score fp tp]
%  gt       - [mx5] ground truth results [x y w h match] (see bbGt>evalRes)
%  dt       - [nx6] detect results [x y w h score match] (see bbGt>evalRes)
%
% EXAMPLE
%
% See also acfTrain, acfDetect, acfModify, acfDemoInria, bbGt
%
% Piotr's Computer Vision Matlab Toolbox      Version 3.40
% Copyright 2014 Piotr Dollar.  [pdollar-at-gmail.com]
% Licensed under the Simplified BSD License [see external/bsd.txt]

% get parameters
dfs={ 'name','REQ', 'imgDir','REQ', 'gtDir','REQ', 'pLoad',[], ...
  'pModify',[], 'thr',.5,'mul',0, 'reapply',0, 'ref',10.^(-2:.25:0), ...
  'lims',[3.1e-3 1e1 .05 1], 'show',0 };
[name,imgDir,gtDir,pLoad,pModify,thr,mul,reapply,ref,lims,show] = ...
  getPrmDflt(varargin,dfs,1);

% run detector on directory of images
bbsNm=[name 'Dets.txt'];
if(reapply && exist(bbsNm,'file')), delete(bbsNm); end
if(reapply || ~exist(bbsNm,'file'))
  detector = load([name 'Detector.mat']);
  detector = detector.detector;
  if(~isempty(pModify)), detector=acfModify(detector,pModify); end
  imgNms = bbGt('getFiles',{imgDir});
  acfDetect( imgNms, detector, bbsNm );
end

% run evaluation using bbGt
[~,dt] = bbGt('loadAll',gtDir,bbsNm,pLoad);


% regulation by aspect ratio
n=size(dt,2);
aspectRatio=0.41;
for i=1:n
    bb = dt{i};bb=bbApply('resize',bb,1,0,aspectRatio); dt{i}=bb;
end

for f=1:n, bb=dt{f}; dt{f}=bb(bb(:,4)>=40,:); end % filter out detections, the same as in code3.2.1

if(test)
    setIds=6:10;vidIds={0:18 0:11 0:10 0:11 0:11};
else
     setIds=5;vidIds={0:12};
end
% %load gt from vbb files
gt = loadGt( '/BS/shanshan-projects/work/Datasets/Caltech_Pedestrians/annotations/',setIds,vidIds,30,pLoad, aspectRatio, [5 5 635 475] );

[gt,dt] = bbGt('evalRes',gt,dt,thr,mul);
[fp,tp,score,miss] = bbGt('compRoc',gt,dt,1,ref);
miss=exp(mean(log(max(1e-10,1-miss)))); roc=[score fp tp];

% optionally plot roc
if( ~show ), return; end
figure(show); plotRoc([fp tp],'logx',1,'logy',1,'xLbl','fppi',...
  'lims',lims,'color','g','smooth',1,'fpTarget',ref);
title(sprintf('log-average miss rate = %.2f%%',miss*100));
savefig([name 'Roc'],show,'png');

end

function gt = loadGt( pth,setIds,vidIds,skip,pLoad, aspectRatio, bnds )
% Load ground truth of all experiments for all frames.
hr=[50 Inf]; vr=[0.65 Inf];ar=0;
gt=cell(1,100000); k=0; lbls={'person','person?','people','ignore'};
filterGt = @(lbl,bb,bbv) filterGtFun(lbl,bb,bbv,hr,vr,ar,bnds,aspectRatio);
fName=@(s,v) sprintf('%s/annotations/set%02i/V%03i',pth,s,v);
for s=1:length(setIds)
for v=1:length(vidIds{s})  
  A=vbb('vbbLoad',fName(setIds(s),vidIds{s}(v)));
  for f=skip-1:skip:A.nFrame-1
    bb = vbb('frameAnn',A,f+1,lbls,filterGt); ids=bb(:,5)~=1;
    bb(ids,:)=bbApply('resize',bb(ids,:),1,0,aspectRatio);
    k=k+1; gt{k}=bb;
  end
end
end
gt=gt(1:k); 

  function p = filterGtFun( lbl, bb, bbv, hr, vr, ar, bnds, aspectRatio )
    p=strcmp(lbl,'person'); h=bb(4); p=p & (h>=hr(1) & h<hr(2));
    if(all(bbv==0)), vf=inf; else vf=bbv(3).*bbv(4)./(bb(3)*bb(4)); end
    p=p & vf>=vr(1) & vf<=vr(2);
    if(ar~=0), p=p & sign(ar)*abs(bb(3)./bb(4)-aspectRatio)<ar; end
    p = p & bb(1)>=bnds(1) & (bb(1)+bb(3)<=bnds(3));
    p = p & bb(2)>=bnds(2) & (bb(2)+bb(4)<=bnds(4));
  end
end
