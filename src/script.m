
%Detection script
% poolobj = gcp('nocreate');
% if size(poolobj) == 0
%     poolobj = parpool;
% end

% detector_parallel('../data/shelf/Camera0/', '../res/shelf/Camera0/', 0, 700, 5, 10, 80.0)
% detector_parallel('../data/shelf/Camera1/', '../res/shelf/Camera1/', 0, 700, 5, 10, 80.0)
% detector_parallel('../data/shelf/Camera2/', '../res/shelf/Camera2/', 0, 700, 5, 10, 80.0)
% 
% folders = {'gianluca_sync', 'marco_sync', 'matteol_sync', 'matteom_sync', 'nicola_sync', 'stefanog_sync', 'stefanom_sync'};
% l = length(folders);
% for i=2:l
%     src = fullfile('../data/iaslab/', folders{i}, 'Camera0')
%     dst = fullfile('../data/iaslab/', folders{i}, 'Camera0')
%     
%     detector_parallel(src, dst, 0, 100, 5, 10, 80.0)
% 
%     src = fullfile('../data/iaslab/', folders{i}, 'Camera1');
%     dst = fullfile('../data/iaslab/', folders{i}, 'Camera1');
%     detector_parallel(src, dst, 0, 100, 5, 10, 80.0)
%     
%     src = fullfile('../data/iaslab/', folders{i}, 'Camera2');
%     dst = fullfile('../data/iaslab/', folders{i}, 'Camera2');
%     detector_parallel(src, dst, 0, 100, 5, 10, 80.0)
% end

% detector_parallel('../data/shelf/Camera2/', '../res/shelf/Camera2/', 0, 700, 5, 10, 80.0)
% detector_parallel('../data/shelf/Camera3/', '../res/shelf/Camera3/', 0, 700, 5, 10, 80.0)
% detector_parallel('../data/shelf/Camera4/', '../res/shelf/Camera4/', 0, 700, 5, 10, 80.0)

% delete(poolobj);

% detector_parallel('../data/shelf/Camera0', '../res/shelf/Camera0', 0, 600, 5, 10, 80.0)
% detector_parallel('../data/shelf/Camera1', '../res/shelf/Camera1', 0, 600, 5, 10, 80.0)
% detector_parallel('../data/shelf/Camera2', '../res/shelf/Camera2', 0, 600, 5, 10, 80.0)
% detector_parallel('../data/shelf/Camera3', '../res/shelf/Camera3', 0, 600, 5, 10, 80.0)
% detector_parallel('../data/shelf/Camera4', '../res/shelf/Camera4', 0, 600, 5, 10, 80.0)
% 


% belagiannis('../data/iaslab/gianluca_sync/Camera0', '../res/iaslab/gianluca_sync/Camera0/crops')
% belagiannis('../data/iaslab/gianluca_sync/Camera1', '../res/iaslab/gianluca_sync/Camera1/crops')
% belagiannis('../data/iaslab/gianluca_sync/Camera2', '../res/iaslab/gianluca_sync/Camera2/crops')
% 
% belagiannis('../data/iaslab/marco_sync/Camera0', '../res/iaslab/marco_sync/Camera0/crops')
% belagiannis('../data/iaslab/marco_sync/Camera1', '../res/iaslab/marco_sync/Camera1/crops')
% belagiannis('../data/iaslab/marco_sync/Camera2', '../res/iaslab/marco_sync/Camera2/crops')

% belagiannis('../data/iaslab/matteol_sync/Camera0', '../res/iaslab/matteol_sync/Camera0/crops')
% belagiannis('../data/iaslab/matteol_sync/Camera1', '../res/iaslab/matteol_sync/Camera1/crops')
% belagiannis('../data/iaslab/matteol_sync/Camera2', '../res/iaslab/matteol_sync/Camera2/crops')
% 
belagiannis('../data/iaslab/matteom_sync/Camera0', '../res/iaslab/matteom_sync/Camera0/crops')
belagiannis('../data/iaslab/matteom_sync/Camera1', '../res/iaslab/matteom_sync/Camera1/crops')
belagiannis('../data/iaslab/matteom_sync/Camera2', '../res/iaslab/matteom_sync/Camera2/crops')


belagiannis('../data/iaslab/nicola_sync/Camera0', '../res/iaslab/nicola_sync/Camera0/crops')
belagiannis('../data/iaslab/nicola_sync/Camera1', '../res/iaslab/nicola_sync/Camera1/crops')
belagiannis('../data/iaslab/nicola_sync/Camera2', '../res/iaslab/nicola_sync/Camera2/crops')

belagiannis('../data/iaslab/stefanog_sync/Camera0', '../res/iaslab/stefanog_sync/Camera0/crops')
belagiannis('../data/iaslab/stefanog_sync/Camera1', '../res/iaslab/stefanog_sync/Camera1/crops')
belagiannis('../data/iaslab/stefanog_sync/Camera2', '../res/iaslab/stefanog_sync/Camera2/crops')

belagiannis('../data/iaslab/stefanom_sync/Camera0', '../res/iaslab/stefanom_sync/Camera0/crops')
belagiannis('../data/iaslab/stefanom_sync/Camera1', '../res/iaslab/stefanom_sync/Camera1/crops')
belagiannis('../data/iaslab/stefanom_sync/Camera2', '../res/iaslab/stefanom_sync/Camera2/crops')

