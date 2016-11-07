
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

	-- Zero tensor to 
	local 
	if bbs:sum() == 0 then
		return nil
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
		return nil
	end
end


function pose_estimation()
	-- Future params
	local images_path = '../data/campus/Camera0'; 
	local crops_path = '../data/campus/Camera0/crops';
	local value = 4
	-- rexp = '\d{5}';
	local rexp = '%d%d%d%d%d';
	local res_path = paths.concat(images_path, 'anewell');

	-- Check if the res path exists
	if not paths.dirp(res_path) then
		paths.mkdir(res_path)
	end

	-- Load images and rects
	local images = load_files(images_path, 'png')
	local rects = load_files(crops_path, 'mat')

	-- The detector MUST produce always the same number of bbs as images
	assert(#images == #rects)

	for i = 170, #rects do
		-- Loading bbs
		local bbs, centers, scales = load_bbs_data(rects[i], value)
		print(bbs,centers[1][1],scales[1])

		-- Check if sum bbs not 0
		if bbs:sum() ~= 0 then
			-- Naming settings
	        local newname = string.match(images[i], rexp)
	        local n_persons = bbs:size(1)
	        local poses = torch.Tensor(n_persons, 16, 4) 
	        local heatmaps = torch.Tensor(bbs:size(1), 16, 64, 64)

	        image = image.load(images[i])

	        print(newname);

	        -- Image used to put skels
        	img_out = image;
        	for j = 1, n_persons  do
        		if bbs[j]:sum() ~= 0 then
        			-- Cropping
        			local cropped_img = crop(im, centers[j], scales[j], 0, 256)

        			--ti = os.clock()
					----------------------------------------------------------
					--out = m:forward(cropped_img:view(1,3,256,256):cuda())
					--cutorch.synchronize()
					----------------------------------------------------------
					--tf = os.clock()
					--print(string.format("time: %.5f\n", tf-ti))

					local hm = out[2][1]:float()
					hm[hm:lt(0)] = 0

					-- Get predictions (hm and img refer to the coordinate space)
					-- preds_hm: coordinates relative to the heatmap
					-- preds_img: coordinates relative to the original image
					local preds_hm, preds_img, max = getPreds(hm, centers[j], scales[j])

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
        		end

        	end

		end

		break
	end
end

pose_estimation()


