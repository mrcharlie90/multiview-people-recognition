% Compute the people detection in a set of images
% images_path : path to the images
% det_number : detection number
function detect(images_path, det_number)
    % Pre-trained models
    detectors = {
        '../toolbox/detector/models/AcfCaltech+Detector.mat' 
        '../toolbox/detector/models/AcfInriaDetector.mat' % <-- best
        '../toolbox/detector/models/LdcfCaltechDetector.mat' 
        '../toolbox/detector/models/LdcfInriaDetector.mat'
        };
    
    % Detector loading
    detector_path = detectors{det_number};
    detector = load(detector_path);
    detector = detector.detector;
    
    % Get the images
    imagefiles = dir([images_path '*.png']);      
    nfiles = length(imagefiles);
    
    % Output dirs
    video_out_path = [images_path 'video_out/'];
    imgs_out_path = [images_path 'imgs_out/'];
    if ~exist(video_out_path, 'dir') 
        mkdir(video_out_path);
    end
    
    if ~exist(imgs_out_path, 'dir') 
        mkdir(imgs_out_path);
    end
    
    % Detect people
    display('Detecting people...');
    for i=1:nfiles
        % Create a directory with the same 
        % filename of the image
        splits = strsplit(imagefiles(i).name, '.');
        file_name = splits{1};
        
        patches_dir = [imgs_out_path file_name '/'];
        if ~exist(patches_dir, 'dir')
            mkdir(patches_dir);
        end
        
        % Read the image, detect people
        % and store the result in an image with 
        % *_dect.png as suffix
        img = imread([images_path imagefiles(i).name]);
        bbs = acfDetect(img, detector);
        img_out = bbApply('embed', img, bbs, 'col', [0 255 0]);
        
        % Write out the frame
        frame_name = [video_out_path imagefiles(i).name];
        imwrite(img_out, frame_name);
       
        % Crop patches
        [patches, B] = bbApply('crop', img, bbs);
        
        % Save each people detected in imgs_out folder with the relative
        % coordinates
        if ~isempty(B) && ~isempty(patches)
            sz = size(B);
            for i=1:sz(1)
                current_B = B(i,:);
                
                mat_path = [patches_dir 'bb_' int2str(i) '.mat'];
                save(mat_path, 'current_B');
                
                patch_path = [patches_dir 'patch_' int2str(i) '.png'];
                imwrite(patches{i}, patch_path);
            end
        end
    end
    
    display('done!');
end

