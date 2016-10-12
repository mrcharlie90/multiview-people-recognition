% Apply the detector algorithm to all images (with extension in_ext)
% contained into the in_path directory. Select the specific model by
% choosing from 'acf' (aggregated channel features) and 'chk' (checkerboard 
% filtered channel features)
% 
% example:
% detector_parallel('../data/terrace/', '../res/terrace/', 'png', 'chk', 10, 90);
%
function detector_parallel(in_path, out_path, in_ext, mode, padding, thresh)
%     in_path = '../data/terrace/';
%     in_ext = 'png';
%     out_path = '../res/terrace/';
%     mode = 'chk';
    
    if ~exist(in_path, 'dir')
        display('Invalid input folder.');
    end
    
     % Checking if the output dir exists
    if ~exist(out_path, 'dir')
        mkdir(out_path);
    end
    
    filePattern = fullfile(in_path, ['*.' in_ext]);
    theFiles = dir(filePattern);
    
    poolobj = gcp('nocreate');
    if size(poolobj) == 0
        poolobj = parpool;
    end
    % Parallel detection
    parfor i=1:length(theFiles)
        baseFileName = theFiles(i).name;
        fullFileName = fullfile(in_path, baseFileName);
        detector(fullFileName, out_path, mode, padding, thresh);
    end
    delete(poolobj);
end