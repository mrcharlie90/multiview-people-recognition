% Compute the people detection in a set of images
% images_path : path to the images
% det_number : detection number
function ret = detect(images_path, det_number)
    
    detectors = {
        '../toolbox/detector/models/AcfCaltech+Detector.mat' 
        '../toolbox/detector/models/AcfInriaDetector.mat' 
        '../toolbox/detector/models/LdcfCaltechDetector.mat' 
        '../toolbox/detector/models/LdcfInriaDetector.mat'
        };
    
    detector_path = detectors{det_number};
    detector = load(detector_path);
    detector = detector.detector;
    
    % Get the images
    imagefiles = dir([images_path '*.png']);      
    nfiles = length(imagefiles);
    
    % Detect people
    for i=1:nfiles
        % Create a directory with the same 
        % filename of the image
        splits = strsplit(imagefiles(i).name, '.');
        filename = splits{1};
        dir_name = [images_path filename];
        % mkdir(dir_name); % TODO: later use
        
        % Read the image, detect people
        % and store the result in an image with 
        % *_dect.png as suffix
        img = imread([images_path imagefiles(i).name]);
        bbs = acfDetect(img, detector);
        out_img = bbApply('embed', img, bbs, 'col', [0 255 0]);
        figure(1)
        imshow(out_img);
        % bbApply('draw', bbs, 'g');
        
        k = waitforbuttonpress
        
    end
    
    %im(I); bbApply('draw', bbs, 'g');
    % bbs = acfDetect(I, detector);
    % [patches, B] = bbApply('crop', I, bbs)
end

