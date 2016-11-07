function detector(in, out, det_number, padding, thresh)
% Detect people in a given image. 
% usage:
% detector('../data/campus/Camera0/campus4-c0-00096.png', '../res/campus/Camera0/', 5, 10, 80.0);
%

% Future params
% in = '../data/campus/Camera0/campus4-c0-00096.png';
% out = '../res/campus/Camera0/';
% det_number = 5;
% padding = 10;
% thresh = 80.0;

if det_number <= 4
    mode = 'acf';
else
    mode = 'chk';
end

% Pre-trained models
toolbox_path = '../toolbox/detector/models/';
chk_path = '../filtered-channel-features/models_Caltech/';

% Detectors paths
detectors = {
    fullfile(toolbox_path, 'AcfCaltech+Detector.mat')
    fullfile(toolbox_path, 'AcfInriaDetector.mat')% <-- best small 
    fullfile(toolbox_path, 'LdcfCaltechDetector.mat')
    fullfile(toolbox_path, 'LdcfInriaDetector.mat')% <-- best big
    fullfile(chk_path, 'Checkerboards', 'CheckeboardsDetector.mat')
    fullfile(chk_path, 'RotatedFilters', 'RotatedFiltersDetector.mat')
    };

% Detector loading
detector_path = detectors{det_number};
detector = load(detector_path);
detector = detector.detector;

% Checking if the output dir exists
if ~exist(out, 'dir')
    error('Directory is not valid.');
end

crops_dir = fullfile(out, 'crops');
if ~exist(crops_dir, 'dir')
    mkdir(crops_dir);
end


% Matches ddddd.png or dddddd.png names
[~, filename, ext] = fileparts(in);
newname = regexp(filename, '(\d{6}|\d{5})$', 'match');
newname = newname{1};

% Read the image and detect people
img = imread(in);
bbs = acfDetect(img, detector);

% padding
pad = zeros(size(bbs));
%pad(:,1:2) = -padding;
pad(:,3:4) = padding;
bbs = bbs + pad;

% Thresh the score
bbs = bbs(bbs(:,5) > thresh, :);

% Crop and save patches
[crops, rect] = bbApply('crop', img, bbs);

% Save the image
img_out = bbApply('embed', img, rect, 'col', [0 255 0]);
det_image_name = fullfile(crops_dir, strcat(newname, '.jpeg'));
imwrite(img_out, det_image_name);

% Save bbs
bbs_name = fullfile(crops_dir, newname);
save(bbs_name, 'rect');

end % detector
    
%% TODO: remove    
    % Remove overlapping rectangles
%     [rows cols] = size(bbs);
%     w = 3; % width 
%     h = 4; % height
%     selection = ones(rows, 1);
%     for i=1:rows
%         for j=i+1:rows
%             ratio = bboxOverlapRatio(bbs(i,1:4),bbs(j,1:4));
%             if ratio > 0.40
%                 if (bbs(i,w) * bbs(i, h)) > (bbs(j, w) * bbs(j,h))
%                     selection(j) = 0;
%                 else
%                     selection(i) = 0;
%                 end
%             end
%         end
%     end
%     
%     % Select only one between overlapping rects
%     bbs = bbs(selection>0, :);
    

% Rectangle tuning <---
% bb
% imshow(img);
% hold on;
%bbs(1,1)
%bbs(1,2)
% rectangle origin
%plot(bb(1,1),bb(1,2),'r.','MarkerSize',20) 
% complete rectangle
% rectangle('Position',bb(1,1:4), 'EdgeColor','r')



