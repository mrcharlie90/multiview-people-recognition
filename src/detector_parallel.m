function detector_parallel(in, out, start, stop, det_num, padding, thresh)
% Apply the detection function on a set of images 
% contained into one folder (png).
% usage:
% detector_parallel('../data/campus/Camera0/', '../res/campus/Camera0/', 170, 1787, 5, 10, 80.0)

% Directory check
if ~exist(in, 'dir')
    error('Input folder is not valid.');
end

crops_dir = fullfile(out, 'crops');
if ~exist(crops_dir, 'dir')
    mkdir(crops_dir);
end

pattern = fullfile(in, '*.png');
files = dir(pattern);

% Parallel detections
assert(start < stop)
n = length(files);
if stop > n
    stop = n;
end
if start <= 0
    start = 1;
end
display(['Paralell detection at ' in]);
rect = zeros(1, 5);
for i=1:start
    % Matches ddddd.png or dddddd.png names
    newname = regexp(files(i).name, '(\d{6}|\d{5})', 'match');
    newname = newname{1};
    zeroname = fullfile(crops_dir, newname);
    save(zeroname, 'rect');
end

for i=stop:n
    % Matches ddddd.png or dddddd.png names
    newname = regexp(files(i).name, '(\d{6}|\d{5})', 'match');
    newname = newname{1};
    zeroname = fullfile(crops_dir, newname);
    save(zeroname, 'rect');
end


parfor i=start:stop 
    img_path = fullfile(in, files(i).name);
    detector(img_path, out, det_num, padding, thresh);
end

fprintf(' --> Done!\n');
end