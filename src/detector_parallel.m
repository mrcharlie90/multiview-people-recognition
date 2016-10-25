function detector_parallel(in, out, start, stop, det_num, padding, thresh)
% Apply the detection function on a set of images 
% contained into one folder (png).
% usage:
% detector_parallel('../data/campus/Camera0/', '../res/campus/Camera0/', 170, 1787, 5, 10, 80.0)

% Directory check
if ~exist(in, 'dir')
    error('Input folder is not valid.');
end

pattern = fullfile(in, '*.png');
files = dir(pattern);

% Parallel detections
assert(start < stop)
n = length(files);
if stop > n
    stop = n;
end
if start < 0
    start = 0;
end
display(['Paralell detection at ' in]);
parfor i=start:stop
    img_path = fullfile(in, files(i).name);
    detector(img_path, out, det_num, padding, thresh);
end

fprintf(' --> Done!\n');
end