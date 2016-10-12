% Detect people in a given image. It applies one of the following 
% pre-trained models to the input image, and extract an array of bounding
% boxes (bbs) where each row specify a rectangle [x y h w score]
% highlighting the person detected.
%
% images_path : path to the image
% output_dir : path where to store the results
% det_number : detection number
% padding : resize all rectangles detected adding this value
% thresh : selects rectangles with score >= thresh
%
% example:
% detector('../data/terrace/terrace1-c0-026.png', '../res/terrace', 'chk', 10, 90.0);
%
function bbs_dir = detector(input_image, output_dir, det_number, padding, thresh)
    % Pre-trained models
    detectors = {
        '../toolbox/detector/models/AcfCaltech+Detector.mat' 
        '../toolbox/detector/models/AcfInriaDetector.mat' % <-- best small 
        '../toolbox/detector/models/LdcfCaltechDetector.mat' 
        '../toolbox/detector/models/LdcfInriaDetector.mat' % <-- best big
        '../filtered-channel-features/models_Caltech/Checkerboards/CheckeboardsDetector.mat'
        '../filtered-channel-features/models_Caltech/RotatedFilters/RotatedFiltersDetector.mat'
        '../filtered-channel-features/models_Caltech/Checkerboards/Checkerboards_works.mat'
        };
    
    % Choosing detector
%     det_number = 0;
%     if strcmp(mode, 'acf') == 1
%         addpath(genpath('../toolbox/'));
%         det_number = 4;
%     elseif strcmp(mode, 'chk') == 1
%         addpath(genpath('../filtered-channel-features/'));
%         det_number = 7;
%     else
%         display('Invalid mode. Choose one from acf chk');
%         return;
%     end
    
    % Detector loading
    detector_path = detectors{det_number};
    detector = load(detector_path);
    detector = detector.detector;
    
    % Checking if the output dir exists
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    [pathstr, filename, ext] = fileparts(input_image);
    bbs_dir = [output_dir '/' filename '/'];
    
    if ~exist(bbs_dir, 'dir')
        mkdir(bbs_dir);
    end
    
    % Read the image and detect people
    img = imread(input_image);
    bbs = acfDetect(img, detector);
    
    % padding
    pad = zeros(size(bbs));
    %pad(:,1:2) = -padding;
    pad(:,3:4) = padding;
    bbs = bbs + pad;
    
    % Thresh
    bbs = bbs(bbs(:,5) > thresh, :);
    
    % Remove overlapping rectangles
    [rows cols] = size(bbs);
    w = 3; % width 
    h = 4; % height
    selection = ones(rows, 1);
    for i=1:rows
        for j=i+1:rows
            ratio = bboxOverlapRatio(bbs(i,1:4),bbs(j,1:4));
            if ratio > 0.50
                if (bbs(i,w) * bbs(i, h)) > (bbs(j, w) * bbs(j,h))
                    selection(j) = 0;
                else
                    selection(i) = 0;
                end
            end
        end
    end
    
    % Select only one between overlapping rects
    bbs = bbs(selection>0, :);
    
    % Save the image
    img_out = bbApply('embed', img, bbs, 'col', [0 255 0]);
    out_name = [output_dir '/' filename '_dect' ext];
    out_bbs_name = [bbs_dir filename '_bbs'];
    imwrite(img_out, out_name);
    save(out_bbs_name, 'bbs');
    
    % Crop and save patches
    [patches, bb] = bbApply('crop', img, bbs);
    
    for i=1:length(patches)
        patch_name = [bbs_dir filename '_crop' int2str(i) ext];
        imwrite(patches{i}, patch_name);
    end
    
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

end

