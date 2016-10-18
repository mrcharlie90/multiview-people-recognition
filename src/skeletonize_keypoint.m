function skeletonize_keypoint(in_path, in_ext, use_cpu, visualize)

% Update these according to your requirements
USE_GPU = 1;
if use_cpu == 1
    USE_GPU = 0;
end

% Default paths
DEMO_BASEDIR = '../keypoint-matlab';
DEMO_MODEL_FN = fullfile(DEMO_BASEDIR,'data','keypoint-v2.mat');
MATCONVNET_DIR = fullfile(DEMO_BASEDIR, 'lib', 'matconvnet-custom');

% Compile matconvnet
% if ~exist( fullfile(MATCONVNET_DIR, 'matlab', 'mex'), 'dir' )
%     disp('Compiling matconvnet ...')
%     addpath('./lib/matconvnet-custom/matlab');
%     if ( USE_GPU )
%         vl_compilenn('enableGpu', true);
%     else
%         vl_compilenn('enableGpu', false);
%     end
%     fprintf(1, '\n\nMatcovnet compilation finished.');
% end

% Setup matconvnet path variables
matconvnet_setup_fn = fullfile(MATCONVNET_DIR, 'matlab', 'vl_setupnn.m');
run(matconvnet_setup_fn) ;

% Check file/folder
[folder, ~, ~] = fileparts(in_path);
images = in_path;
if exist(in_path, 'dir')
    pattern = fullfile(in_path, ['*.' in_ext]);
    list = dir(pattern);
    images = cell(size(list));
    for i=1:size(images)
        images{i} = fullfile(in_path, list(i).name);
    end
    folder = in_path;
end
% Initialize keypoint detector
keypoint_detector = KeyPointDetector(DEMO_MODEL_FN, MATCONVNET_DIR, USE_GPU);
    
for k=1:size(images)
    
    % Detect keypoints
    img = images{k};
    [~, file_name, ext] = fileparts(img);
    fprintf(1, '\nDetecting keypoints in image : %s', img);
    
    % [kpx, kpy, kpname]
    tic;
    [kpx, kpy, kpname] = get_all_keypoints(keypoint_detector, img);
    toc;
    % Display the keypoints
    if visualize 
        out_name = fullfile(folder,'skel');
        if ~exist(out_name, 'dir')
            mkdir(out_name);
        end
        in_img = imread(img);
        radius = ones(1, 16) * 3;
        plot_points = [kpx; kpy; radius]';
        skel = insertShape(in_img, 'FilledCircle', plot_points, 'Color', 'red');
        out_name = fullfile(folder, 'skel', [file_name '_skel' ext]);
        imwrite(skel, out_name);
    end
    
    % Save results
    pose = [kpx; kpy];
    
    out_name = fullfile(folder, file_name);
    save(out_name, 'pose');
    
    fprintf(' --> Done!');
end
fprintf('\n');
end % function
