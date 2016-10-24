require 'nn'
require 'image'
require 'paths'
paths.dofile('util.lua')
paths.dofile('img.lua')

function load_files(path, ext)
	-- Create empty table to store file names:
	files = {}

	-- Go over all files in directory. We use an iterator, paths.files().
	for file in paths.files(path, ext) do
	   -- We only load files that match the extension
	   -- and insert the ones we care about in our table
	      table.insert(files, paths.concat(path,file))
	   
	end

	-- Check files
	if #files == 0 then
	   error('given directory doesn\'t contain any files of type: ' .. ext)
	end

	-- We sort files alphabetically, it's quite simple with table.sort()
	table.sort(files, function (a,b) return a < b end)

	return files
end

function load_images(path)
	return load_files(path, 'png')
end

function load_mats(path)
	return load_files(path, 'mat')
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
	local bbs = tensors['bb']
	local centers = {}
	local scales = {}

	-- Computing centers and scales for each bbs

	if pcall(function()
			for i=1,bbs:size(1) do

			local x, y = bbs[i][1], bbs[i][2]
			local w, h = bbs[i][3], bbs[i][4]
			local score = bbs[i][5]

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
		return nil
	end
end



function pose_estimation(dir1, dir2, value)
	--local mats_dir = 'data/detections/campus_camera0/'
	--local images_dir = 'data/campus/Camera0/'
	local mats_dir = dir1
	local images_dir = dir2
	print('mats: ' .. dir1 .. ' images: ' .. dir2)
	local m = torch.load('umich-stacked-hourglass.t7') 

	local images_paths = load_images(images_dir)
	local mats_paths = load_mats(mats_dir)

	-- Directory where files are been stored
	local anewell_path = paths.concat(mats_dir, 'anewell')
	if not paths.dirp(anewell_path) then
		paths.mkdir(anewell_path)
	end

	-- Same number if images and bbs required
	assert(#images_paths == #mats_paths, 'Irregular number of images and matrices')

	-- Go over the file list:
	local images = {}
	for i,path in ipairs(images_paths) do
	   -- load each image
	   table.insert(images, image.load(path))
	end

	-- Going through the images and computing the skeleton
	print('Computing skeletons...')
	
	for i,im in ipairs(images) do
		local bbs, centers, scales = load_bbs_data(mats_paths[i], value)
		-- Checking bbs is valid
		if bbs then
			-- Skeletons relative to the original image and relative to the heatmaps
			local skels_img = torch.Tensor(bbs:size(1), 16, 2)
			local skels_hm = torch.Tensor(bbs:size(1), 16, 2)
			local heatmaps = torch.Tensor(bbs:size(1), 16, 64, 64)

			-- Go through each bbs center, crop the 256x256 window of the subject
			-- and locate the skeleton
			local img_out = im
			for j=1,bbs:size(1) do
				local cropped_img = crop(im, centers[j], scales[j], 0, 256)
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
				local preds_hm, preds_img = getPreds(hm, centers[j], scales[j])
				preds = torch.Tensor(16,2)
				preds:copy(preds_img)
				preds_hm:mul(4) -- Change to input scale

				img_out = drawSkeleton(img_out, hm, preds_img[1])
				--local img_out = drawOutput(cropped_img, hm, preds_hm[1])
				--image.display(img_out)
				
				-- Store skeletons in a tenstor
				skels_img:sub(j,j):copy(preds_img)
				skels_hm:sub(j,j):copy(preds_hm)
				heatmaps:sub(j,j):copy(hm)
				--image.display(croppings)
				

			end -- endfor

			-- Saving results
			local out_name = paths.concat(anewell_path, string.format('%04d',i))

			torch.save(out_name .. '_kpimg.t7', skels_img)
			torch.save(out_name .. '_kphm.t7', skels_hm)
			torch.save(out_name .. '_hm.t7', heatmaps)
			torch.save(out_name .. '_c.t7', centers)
			torch.save(out_name .. '_s.t7', scales)
			image.save(out_name .. '.jpeg', img_out)
		end -- endif
	end -- endfor
	print('done!')
end

--pose_estimation('data/detections/campus_camera0/','data/campus/Camera0/', 4)
--[[pose_estimation('data/detections/campus_camera1/','data/campus/Camera1/', 4)
pose_estimation('data/detections/campus_camera2/','data/campus/Camera2/', 4)

pose_estimation('data/detections/shelf_camera0/','data/shelf/Camera0/', 1)
pose_estimation('data/detections/shelf_camera1/','data/shelf/Camera1/', 1)
pose_estimation('data/detections/shelf_camera2/','data/shelf/Camera2/', 1)
pose_estimation('data/detections/shelf_camera3/','data/shelf/Camera3/', 1)
pose_estimation('data/detections/shelf_camera4/','data/shelf/Camera4/', 1)

pose_estimation('data/detections/iaslab/gianluca_sync_camera0/','data/iaslab/gianluca_sync/Camera0/', 1)
pose_estimation('data/detections/iaslab/gianluca_sync_camera1/','data/iaslab/gianluca_sync/Camera1/', 1)
pose_estimation('data/detections/iaslab/gianluca_sync_camera2/','data/iaslab/gianluca_sync/Camera2/', 1)

pose_estimation('data/detections/iaslab/marco_sync_camera0/','data/iaslab/marco_sync/Camera0/', 1)
pose_estimation('data/detections/iaslab/marco_sync_camera1/','data/iaslab/marco_sync/Camera1/', 1)
pose_estimation('data/detections/iaslab/marco_sync_camera2/','data/iaslab/marco_sync/Camera2/', 1)

pose_estimation('data/detections/iaslab/matteol_sync_camera0/','data/iaslab/matteol_sync/Camera0/', 1)
pose_estimation('data/detections/iaslab/matteol_sync_camera1/','data/iaslab/matteol_sync/Camera1/', 1)
pose_estimation('data/detections/iaslab/matteol_sync_camera2/','data/iaslab/matteol_sync/Camera2/', 1)

pose_estimation('data/detections/iaslab/matteom_sync_camera0/','data/iaslab/matteom_sync/Camera0/', 1)
pose_estimation('data/detections/iaslab/matteom_sync_camera1/','data/iaslab/matteom_sync/Camera1/', 1)
pose_estimation('data/detections/iaslab/matteom_sync_camera2/','data/iaslab/matteom_sync/Camera2/', 1)

pose_estimation('data/detections/iaslab/nicola_sync_camera0/','data/iaslab/nicola_sync/Camera0/', 1)
pose_estimation('data/detections/iaslab/nicola_sync_camera1/','data/iaslab/nicola_sync/Camera1/', 1)
pose_estimation('data/detections/iaslab/nicola_sync_camera2/','data/iaslab/nicola_sync/Camera2/', 1)

pose_estimation('data/detections/iaslab/stefanog_sync_camera0/','data/iaslab/stefanog_sync/Camera0/', 1)
pose_estimation('data/detections/iaslab/stefanog_sync_camera1/','data/iaslab/stefanog_sync/Camera1/', 1)
pose_estimation('data/detections/iaslab/stefanog_sync_camera2/','data/iaslab/stefanog_sync/Camera2/', 1)

pose_estimation('data/detections/iaslab/stefanom_sync_camera0/','data/iaslab/stefanom_sync/Camera0/', 1)
pose_estimation('data/detections/iaslab/stefanom_sync_camera1/','data/iaslab/stefanom_sync/Camera1/', 1)
pose_estimation('data/detections/iaslab/stefanom_sync_camera2/','data/iaslab/stefanom_sync/Camera2/', 1)
--]]

 
