require 'paths'
require 'io'
paths.dofile('util.lua')

-- function view()
-- 	local gt_paths = load_files('../data/campus/Camera1', 'png')
-- 	local res_path = '../data/campus/Camera0/'

-- 	local centers_paths = load_files(paths.concat(res_path, 'anewell'), '_c.t7')
-- 	local scales_paths = load_files(paths.concat(res_path, 'anewell'), '_s.t7')
-- 	local hms_paths = load_files(paths.concat(res_path, 'anewell'), '_hm.t7')
-- 	local kphms_paths = load_files(paths.concat(res_path, 'anewell'), '_kphm.t7')
-- 	local kpimgs_paths = load_files(paths.concat(res_path, 'anewell'), '_kpimg.t7')
-- 	local bbs_paths = load_files(res_path)

-- 	print('|GTs| = ' .. #gt_paths)
-- 	print('|centers_paths| = ' .. #centers_paths)
-- 	print('|scales_paths| = ' .. #scales_paths)
-- 	print('|hms_paths| = ' .. #hms_paths)
-- 	print('|kphms_paths| = ' .. #kphms_paths)
-- 	print('|kpimgs_paths| = ' .. #kpimgs_paths)


-- 	assert(#gt_paths == #centers_paths 
-- 		and #centers_paths == #scales_paths 
-- 		and #scales_paths == #hms_paths 
-- 		and #hms_paths == #kphms_paths 
-- 		and #kphms_paths == #kpimgs_paths)

-- 	for i = 1, #gt_paths do
-- 		print('Checking ' .. gt_paths[i])
-- 		local img = image.load(gt_paths[i])

-- 		centers = torch.load(centers_paths[i])
-- 		scales = torch.load(scales_paths[i])
-- 		hms = torch.load(hms_paths[i])
		
-- 		print('|centers| = ' .. #centers)
-- 		print('|scales| = ' .. #scales)
-- 		assert(#centers == #scales and #scales == hms:size(1))
-- 		for j = 1, #centers do
-- 			print('Checking skeleton ' .. j)

-- 			local preds_hm, preds_img, max = getPreds(hms[j], centers[j], scales[j])
-- 			preds_hm:mul(4)
			

-- 			local img_crop = crop(img, centers[j], scales[j], 0, 256)
-- 			local img_out = drawOutput(img_crop, hms[j], preds_hm[1], max)
-- 			--print(preds_img, preds_hm, max)

-- 			--local img_out = drawSkeleton(img, hms[j], preds_img[1])
-- 			--local img_out = drawSkeletonPoints(img, hms[j], preds_img[1], max)
-- 			w = image.display{image=img_out, win=w}

-- 			local key = io.read()
-- 		end
-- 	end

-- end

function view1(filename, prefix)
	local img_path = '../data/campus/Camera0'
	local anewell_path = paths.concat(img_path, 'anewell')

	centers = torch.load(paths.concat(anewell_path, filename .. '_c.t7'))
	scales = torch.load(paths.concat(anewell_path, filename .. '_s.t7'))
	poses = torch.load(paths.concat(anewell_path, filename .. '.t7'))
	heatmaps = torch.load(paths.concat(anewell_path, filename .. '_hm.t7'))
	img = image.load(paths.concat(img_path, prefix .. filename .. '.png'))

	print(scales)
	print(centers)
	print(poses)

	drawSkeletonPoints(img, hms, coords, max)

	w = image.display{image=img, win=w}
end

view1('00170', 'campus4-c0-')