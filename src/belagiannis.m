function belagiannis(images_path, crops_path)
% Future params
images_path = '../data/campus/Camera0'; 
crops_path = '../data/campus/Camera0/crops';

res_path = fullfile(crops_path, 'belagiannis');
use_cpu = 1;

if ~exist(res_path,'dir')
    mkdir(res_path);
end

pattern = fullfile(images_path, '*.png');
images = dir(pattern);
pattern = fullfile(crops_path, '*.mat');
rects = dir(pattern);

assert(length(images) == length(rects));
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

radius = ones(1, 16) * 3;
thresh = 7;
for i=1:length(rects)
    bbs = load(fullfile(crops_path, rects(i).name));
    bbs = bbs.rect;
    
    if(sum(bbs) ~= 0)
        % Naming settings
        newname = regexp(images(i).name, '(\d{5}|\d{6})', 'match');
        newname = newname{1};
       
        n_persons = size(bbs, 1);
        poses = zeros(16, 4, n_persons);
        image = imread(fullfile(images_path, images(i).name));
        display(sprintf('%s...', images(i).name));
        for j=1:n_persons
            % Cropping
            img_skels = image;
            img_cropped = imcrop(image, bbs(j,:));
           
            % Getting the keypoints
            out_image_name = fullfile(res_path, strcat(newname, '.jpeg'));
            if ~exist(out_image_name, 'file')
                [kpx, kpy, kpname, occlusion] = get_all_keypoints(keypoint_detector, img_cropped);
                plot_points = [kpx + bbs(j,1); kpy + bbs(j,2); radius]';

                % Reading the image and computing the occlusion
                occlusion_marks = occlusion<=thresh;
                if(sum(occlusion_marks) ~= 0)
                    img_skels = insertShape(img_skels, 'FilledCircle', plot_points(occlusion_marks,:), 'Color', 'red');
                end

                if(sum(~occlusion_marks) ~= 0)
                    img_skels = insertShape(img_skels, 'FilledCircle', plot_points(~occlusion_marks,:), 'Color', 'green');
                end

                % Save results
                % [x y 0/1 confidence]
                poses(:,:,j) = [kpx; kpy; occlusion_marks; occlusion]';
                save(fullfile(res_path, newname), 'poses');
            else
                sprintf('Exists!\n');
            end
            break
        end
        imwrite(img_skels, out_image_name);
        display(sprintf('Done!\n'));
    end       
end % end function