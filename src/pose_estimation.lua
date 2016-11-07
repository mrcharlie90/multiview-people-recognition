
require 'image'
require 'paths'
paths.dofile('util.lua')
paths.dofile('img.lua')


-- Load images and rects
function load_files(path, ext)
	-- Create empty table to store file names:
	files = {}

	-- Go over all files in directory. We use an iterator, paths.files().

	for file in paths.files(path, ext) do
		table.insert(files, paths.concat(path,file))
	end

	if #files == 0 then
	   error('given directory doesn\'t contain any files of type: ' .. ext)
	end

	-- We sort files alphabetically, it's quite simple with table.sort()
	table.sort(files, function (a,b) return a < b end)

	return files
end

-- Function used to return the center and the scale of bbs*.mat (matlab file)
-- If the size of bbs is nx5 it returns:
-- tensor bbs of size nx5
-- center coordinates of size nx2 (table)
-- scale value [nx1] that depends on the area of the bb (table)
function load_bbs_data(path, value)
	-- library to load matlab files
	local matio = require 'matio'

	-- Load 
	local tensors = matio.load(path)
	
	--local bbs = tensors['bb']
	local bbs = tensors['rect']
	local centers = {}
	local scales = {}

	local zero_tensor = torch.Tensor(1,1):zero()
	if bbs:sum() == 0 then
		return zero_tensor
	end

	-- Computing centers and scales for each bbs
	if pcall(function()
			for i=1,bbs:size(1) do

			local x, y = bbs[i][1], bbs[i][2]
			local w, h = bbs[i][3], bbs[i][4]
			--local score = bbs[i][5]

			local area = w * h
			--print(area)
			local order = math.floor(math.log10(area))
			local scale = order / value -- put 4 on area with small people. 1 instead
			scales[i] = scale
			--print(scale)

			centers[i] = {}
			centers[i][1] = math.floor(x + w/2)
			centers[i][2] = math.floor(y + h/2)
			--print(center)
			end 
			end) 
	then
		return bbs, centers, scales
	else
		return zero_tensor
	end
end


function pose_estimation(images_path, crops_path, value, rexp)
	-- Future params
	--[[local images_path = 'data/campus/Camera0'; 
	local crops_path = 'data/campus/Camera0/crops';
	local value = 4
	local rexp = '%d%d%d%d%d';--]]

	-- Store resutls in crops parent folder
	local res_path = paths.dirname(crops_path)
	res_path = paths.concat(res_path, 'anewell');

	-- Check if the res path exists
	if not paths.dirp(res_path) then
		paths.mkdir(res_path)
	end

	-- Load images and rects
	local images = load_files(images_path, 'png')
	local rects = load_files(crops_path, 'mat')

	-- The detector MUST produce always the same number of bbs as images
	assert(#images == #rects)

	-- Loading model
	local m = torch.load('umich-stacked-hourglass.t7') 

	-- For each detection compute the skel
	for i = 1, #rects do
		-- Loading bbs
		local bbs, centers, scales = load_bbs_data(rects[i], value)

		-- Check if sum bbs not 0
		if bbs:sum() ~= 0 then
			-- Naming settings
	        local newname = string.match(images[i], rexp)
	        local n_persons = bbs:size(1)
	        local poses = torch.Tensor(n_persons, 16, 4):zero()
			local heatmaps = torch.Tensor(n_persons, 16, 64, 64):zero()
	        
	        print(newname);

	        -- Image used to put skels
        	local img = image.load(images[i])
        	local img_out = img;
        	for j = 1, n_persons  do
        		if bbs[j]:sum() ~= 0 then
        			-- Cropping
        			local cropped_img = crop(img, centers[j], scales[j], 0, 256)

        			--ti = os.clock()
					----------------------------------------------------------
					out = m:forward(cropped_img:view(1,3,256,256):cuda())
					cutorch.synchronize()
					----------------------------------------------------------
					--tf = os.clock()
					--print(string.format("time: %.5f\n", tf-ti))

					local hm = out[2][1]:float()
					hm[hm:lt(0)] = 0

					-- Get predictions (hm and img refer to the coordinate space)
					-- preds_hm: coordinates relative to the heatmap
					-- preds_img: coordinates relative to the original image
					local preds_hm, preds_img, max = getPreds(hm, centers[j], scales[j])
					preds_hm:mul(4) -- Change to input scale

					-- Computing occlusion
					local occlusion_th = 0.75
					local occlusion_mask = max:ge(occlusion_th):reshape(16,1):double()

					-- Storing results
					poses[j]:sub(1,16,1,2):copy(preds_img)
					poses[j]:sub(1,16,3,3):copy(occlusion_mask)
					poses[j]:sub(1,16,4,4):copy(max)

					heatmaps[j]:copy(hm)
					-- Drawing output
					img_out = drawSkeleton(img_out, hm, preds_img[1])
					--local img_out = drawOutput(cropped_img, hm, preds_hm[1])
        		end
        	end
        	--image.display(img_out)
        	
        	-- Saving results
			local out_name = paths.concat(res_path, newname)
			
			torch.save(out_name .. '_hm.t7', heatmaps)
			torch.save(out_name .. '_c.t7', centers)
			torch.save(out_name .. '_s.t7', scales)
			torch.save(out_name .. '.t7', poses)
			image.save(out_name .. '.jpeg', img_out)
			print('done!')
		end
	end
end

-- pose_estimation('data/campus/Camera0', 'res/campus/Camera0/crops', 4, '%d%d%d%d%d')
-- pose_estimation('data/campus/Camera1', 'res/campus/Camera1/crops', 4, '%d%d%d%d%d')--
-- pose_estimation('data/campus/Camera2', 'res/campus/Camera2/crops', 4, '%d%d%d%d%d')
--pose_estimation('data/shelf/Camera0', 'res/shelf/Camera0/crops', 1, '%d%d%d%d%d%d')
--pose_estimation('data/shelf/Camera0', 'res/shelf/Camera0/crops', 1, '%d%d%d%d%d%d')
-- pose_estimation('data/shelf/Camera1', 'res/shelf/Camera1/crops', 1, '%d%d%d%d%d%d')
-- pose_estimation('data/shelf/Camera2', 'res/shelf/Camera2/crops', 1, '%d%d%d%d%d%d')
-- pose_estimation('data/shelf/Camera3', 'res/shelf/Camera3/crops', 1, '%d%d%d%d%d%d')
 --pose_estimation('data/shelf/Camera4', 'data/shelf/Camera4/crops', 1, '%d%d%d%d%d%d')

-- pose_estimation('data/iaslab/gianluca_sync/Camera0', 'res/iaslab/gianluca_sync/Camera0/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/gianluca_sync/Camera1', 'res/iaslab/gianluca_sync/Camera1/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/gianluca_sync/Camera2', 'res/iaslab/gianluca_sync/Camera2/crops', 1, '%d%d%d%d%d')

pose_estimation('data/iaslab/marco_sync/Camera0', 'data/iaslab/marco_sync/Camera0/crops', 1, '%d%d%d%d%d')
pose_estimation('data/iaslab/marco_sync/Camera1', 'data/iaslab/marco_sync/Camera1/crops', 1, '%d%d%d%d%d')
pose_estimation('data/iaslab/marco_sync/Camera2', 'data/iaslab/marco_sync/Camera2/crops', 1, '%d%d%d%d%d')

-- pose_estimation('data/iaslab/matteol_sync/Camera0', 'data/iaslab/matteol_sync/Camera0/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/matteol_sync/Camera1', 'data/iaslab/matteol_sync/Camera1/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/matteol_sync/Camera2', 'data/iaslab/matteol_sync/Camera2/crops', 1, '%d%d%d%d%d')

-- pose_estimation('data/iaslab/matteom_sync/Camera0', 'data/iaslab/matteom_sync/Camera0/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/matteom_sync/Camera1', 'data/iaslab/matteom_sync/Camera1/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/matteom_sync/Camera2', 'data/iaslab/matteom_sync/Camera2/crops', 1, '%d%d%d%d%d')

-- pose_estimation('data/iaslab/nicola_sync/Camera0', 'data/iaslab/nicola_sync/Camera0/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/nicola_sync/Camera1', 'data/iaslab/nicola_sync/Camera1/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/nicola_sync/Camera2', 'data/iaslab/nicola_sync/Camera2/crops', 1, '%d%d%d%d%d')

-- pose_estimation('data/iaslab/stefanog_sync/Camera0', 'data/iaslab/stefanog_sync/Camera0/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/stefanog_sync/Camera1', 'data/iaslab/stefanog_sync/Camera1/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/stefanog_sync/Camera2', 'data/iaslab/stefanog_sync/Camera2/crops', 1, '%d%d%d%d%d')

-- pose_estimation('data/iaslab/stefanom_sync/Camera0', 'data/iaslab/stefanom_sync/Camera0/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/stefanom_sync/Camera1', 'data/iaslab/stefanom_sync/Camera1/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/stefanom_sync/Camera2', 'data/iaslab/stefanom_sync/Camera2/crops', 1, '%d%d%d%d%d')

-- pose_estimation('data/iaslab/matteom_sync/Camera0', 'res/iaslab/matteom_sync/Camera0/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/matteom_sync/Camera1', 'res/iaslab/matteom_sync/Camera1/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/matteom_sync/Camera2', 'res/iaslab/matteom_sync/Camera2/crops', 1, '%d%d%d%d%d')

-- pose_estimation('data/iaslab/nicola_sync/Camera0', 'res/iaslab/nicola_sync/Camera0/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/nicola_sync/Camera1', 'res/iaslab/nicola_sync/Camera1/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/nicola_sync/Camera2', 'res/iaslab/nicola_sync/Camera2/crops', 1, '%d%d%d%d%d')

-- pose_estimation('data/iaslab/stefanog_sync/Camera0', 'res/iaslab/stefanog_sync/Camera0/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/stefanog_sync/Camera1', 'res/iaslab/stefanog_sync/Camera1/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/stefanog_sync/Camera2', 'res/iaslab/stefanog_sync/Camera2/crops', 1, '%d%d%d%d%d')

-- pose_estimation('data/iaslab/stefanom_sync/Camera0', 'res/iaslab/stefanom_sync/Camera0/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/stefanom_sync/Camera1', 'res/iaslab/stefanom_sync/Camera1/crops', 1, '%d%d%d%d%d')
-- pose_estimation('data/iaslab/stefanom_sync/Camera2', 'res/iaslab/stefanom_sync/Camera2/crops', 1, '%d%d%d%d%d')

