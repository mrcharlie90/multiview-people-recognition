gt_path = '../data/campus/';
actorsGT = load(fullfile(gt_path, 'actorsGT.mat'));
actorsGT = actorsGT.actor2D
cameras = {'Camera0' 'Camera1' 'Camera2'};
camera_index = 1;
pattern = fullfile(gt_path,cameras{camera_index}, '*.png');
images_paths = dir(pattern)

for i=1:length(images_paths)
    splitting = strsplit(images_paths(i).name, {'-', '.'});
    num = str2num(splitting{3});
    
    frames = actorsGT{camera_index};
    
    frames{num + 1}
    break;
end