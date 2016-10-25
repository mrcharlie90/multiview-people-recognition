function belagiannis(crops_path)
% Future params
%crops_path = '../data/iaslab/gianluca_sync/Camera0/crops';
res_path = fullfile(crops_path, 'belagiannis');
use_cpu = 1;

if ~exist(res_path,'dir')
    mkdir(res_path);
end

% Update these according to your requirements
USE_GPU = 1;
if use_cpu == 1
    USE_GPU = 0;
end

% Default paths
DEMO_BASEDIR = '../keypoint-matlab';
DEMO_MODEL_FN = fullfile(DEMO_BASEDIR,'data','keypoint-v2.mat');
MATCONVNET_DIR = fullfile(DEMO_BASEDIR, 'lib', 'matconvnet-custom');


% Setup matconvnet path variables
matconvnet_setup_fn = fullfile(MATCONVNET_DIR, 'matlab', 'vl_setupnn.m');
run(matconvnet_setup_fn) ;

% Initialize keypoint detector
keypoint_detector = KeyPointDetector(DEMO_MODEL_FN, MATCONVNET_DIR, USE_GPU);

pattern = fullfile(crops_path, '*.png');
images = dir(pattern);

% Foreach crop compute the skeleton
radius = ones(1, 16) * 3;
thresh = 7;
l = length(images)
for i=1:l
    display(images(i).name);
    % Getting the keypoints
    img_name = fullfile(crops_path, images(i).name);
    out_name = fullfile(res_path, images(i).name);
    if ~exist(out_name, 'file')
        [kpx, kpy, kpname, occlusion] = get_all_keypoints(keypoint_detector, img_name);
        plot_points = [kpx; kpy; radius]';

        % Reading the image and computing the occlusion
        img = imread(img_name);
        occlusion_marks = occlusion<=thresh;
        if(sum(occlusion_marks) ~= 0)
            img = insertShape(img, 'FilledCircle', plot_points(occlusion_marks,:), 'Color', 'red');
        end

        if(sum(~occlusion_marks) ~= 0)
            img = insertShape(img, 'FilledCircle', plot_points(~occlusion_marks,:), 'Color', 'green');
        end

        % Save results
        % [x y 0/1 confidence]
        pose = [kpx; kpy; occlusion_marks; occlusion]';

        imwrite(img, out_name);
        [~, name, ~] = fileparts(images(i).name);

        save_pose(fullfile(res_path, name), pose);
    else
        display('Exist!');
    end
end % main loop
save(fullfile(res_path, 'kpnames'), 'kpname');

end % end function