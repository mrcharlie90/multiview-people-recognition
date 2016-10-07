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
%     % Get the images
%     imagefiles = dir([images_path '*.png']);      
%     nfiles = length(imagefiles);
%     
%     % Output dirs
%     video_out_path = [images_path 'video_out/'];
%     imgs_out_path = [images_path 'imgs_out/'];
%     if ~exist(video_out_path, 'dir') 
%         mkdir(video_out_path);
%     end
%     
%     if ~exist(imgs_out_path, 'dir') 
%         mkdir(imgs_out_path);
%     end
%     
%     % Detect people
%     for i=1:nfiles      
%         % Read the image and detect people
%         img = imread([images_path imagefiles(i).name]);
%         bbs = acfDetect(img, detector);
%         
%         if crop 
%             % Create a directory with the same 
%             % filename of the image
%             splits = strsplit(imagefiles(i).name, '.');
%             file_name = splits{1};
% 
%             patches_dir = [imgs_out_path file_name '/'];
%             if ~exist(patches_dir, 'dir')
%                 mkdir(patches_dir);
%             end
%         
%             % Crop patches
%             [patches, B] = bbApply('crop', img, bbs);
%         
%             % Save each people detected in imgs_out folder with the relative
%             % coordinates
%             if ~isempty(B) && ~isempty(patches)
%                 sz = size(B);
%                 for i=1:sz(1)
%                     current_B = B(i,:);
% 
%                     mat_path = [patches_dir 'bb_' int2str(i) '.mat'];
%                     save(mat_path, 'current_B');
% 
%                     patch_path = [patches_dir 'patch_' int2str(i) '.png'];
%                     imwrite(patches{i}, patch_path);
%                 end
%             end
%         else
%             img_out = bbApply('embed', img, bbs, 'col', [0 255 0]);
%         
%             % Write out the frame
%             frame_name = [video_out_path imagefiles(i).name];
%             imwrite(img_out, frame_name);
%        
%         end
%             
%         
%     end
    
end

