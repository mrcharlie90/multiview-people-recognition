poolobj = gcp('nocreate');
if size(poolobj) == 0
    poolobj = parpool;
end

% detector_parallel('../data/campus/Camera0', '../res/campus_camera0', 'png', 5, 10, 80);
% detector_parallel('../data/campus/Camera1', '../res/campus_camera1', 'png', 5, 10, 80);
% detector_parallel('../data/campus/Camera2', '../res/campus_camera2', 'png', 5, 10, 80);

folders = {'gianluca_sync', 'marco_sync', 'matteol_sync', 'matteom_sync', 'nicola_sync', 'stefanog_sync', 'stefanom_sync'};
l = length(folders);
for i=1:l
    name = fullfile('../data/iaslab/', folders{i}, 'Camera0');
    dst = fullfile('../res/iaslab/', [folders{i} '_camera0']);
    detector_parallel(name, dst, 'png', 5, 10, 100);
    name = fullfile('../data/iaslab/', folders{i}, 'Camera1');
    dst = fullfile('../res/iaslab/', [folders{i} '_camera1']);
    detector_parallel(name, dst, 'png', 5, 10, 100);
    name = fullfile('../data/iaslab/', folders{i}, 'Camera2');
    dst = fullfile('../res/iaslab/', [folders{i} '_camera2']);
    detector_parallel(name, dst, 'png', 5, 10, 100);
end

%detector_parallel('../data/shelf/Camera0', '../res/shelf_camera0', 'png', 5, 10, 70);
%detector_parallel('../data/shelf/Camera1', '../res/shelf_camera1', 'png', 5, 10, 80);
%detector_parallel('../data/shelf/Camera2', '../res/shelf_camera2', 'png', 5, 10, 70);
%detector_parallel('../data/shelf/Camera3', '../res/shelf_camera3', 'png', 5, 10, 80);
%detector_parallel('../data/shelf/Camera4', '../res/shelf_camera4', 'png', 5, 10, 80);

delete(poolobj);