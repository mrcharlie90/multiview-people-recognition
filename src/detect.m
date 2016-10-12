% Compute the people detection in a set of images
% images_path : path to the image
% output_dir : path where to store the results
% det_number : detection number
function bbs_dir = detect(input_image, output_dir, det_number)
    % Pre-trained models
    detectors = {
        '../toolbox/detector/models/AcfCaltech+Detector.mat' 
        '../toolbox/detector/models/AcfInriaDetector.mat' % <-- best small 
        '../toolbox/detector/models/LdcfCaltechDetector.mat' 
        '../toolbox/detector/models/LdcfInriaDetector.mat' % <-- best big
        };
    
    % Detector loading
    detector_path = detectors{det_number};
    detector = load(detector_path);
    detector = detector.detector;
    
    % Checking if the output dir exists
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    [pathstr, filename, ext] = fileparts(input_image);
    
    bbs_dir = [output_dir filename '/'];
    
    if ~exist(bbs_dir, 'dir')
        mkdir(bbs_dir);
    end
    
    % Read the image and detect people
    img = imread(input_image);
    bbs = acfDetect(img, detector);
    
    % Thresholding: 
    % bbs = bbs(bbs(:,5) > 50.0, :)
    
    % Save the image
    img_out = bbApply('embed', img, bbs, 'col', [0 255 0]);
    out_name = [output_dir filename '_dect' ext];
    out_bbs_name = [bbs_dir filename '_bbs'];
    imwrite(img_out, out_name);
    save(out_bbs_name, 'bbs');
    
    % Crop and save patches
    [patches, bb] = bbApply('crop', img, bbs);

    patches_size = size(patches);
    for i=1:patches_size(1)
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

