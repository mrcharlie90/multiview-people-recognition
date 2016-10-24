function posehg_data()
bbs_dir = '../res/campus_camera0/'

pattern = fullfile(bbs_dir, '*.mat');
matfiles = dir(pattern);

for i=1:length(matfiles)
    [path filename ext] = fileparts(matfiles(i).name);
    bbs = load(matfiles(i).name);
    
    bbs = bbs.bbs;
    
    for j=1:size(bbs,1)
        x = bbs(j,1);
        y = bbs(j,2);
        w = bbs(j,3);
        h = bbs(j,4);
        center = [x + w/2 y + h/2] ;
        
        area = h*w;
        x = floor(log10(area));
        scale = x/4;
        data = [center + ]
    end    
end

end