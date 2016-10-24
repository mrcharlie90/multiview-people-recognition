require 'nn'
require 'image'
require 'paths'
require 'torch'
paths.dofile('util.lua')
paths.dofile('img.lua')
paths.dofile('pose_estimation.lua')

--[[local main_path = '/Users/mauro/Desktop/testing/data/shelf/shelf_camera2/anewell'
local file = '0001'
local hm = torch.load(paths.concat(main_path, file .. '_hm.t7'))
local centers = torch.load(paths.concat(main_path, file .. '_c.t7'))
local scales = torch.load(paths.concat(main_path, file .. '_s.t7'))

local img = image.load('/Users/mauro/Documents/pycharm/multiview-people-recognition/data/shelf/Camera2/img_000300.png')
i=2
print(#centers, #scales, hm:size(1))
local cropped_img = crop(img, centers[i], scales[i], 0, 256)
local preds_hm, preds_img, max = getPreds(hm[i], centers[i], scales[i])
preds_hm:mul(4) -- Change to input scale
--image.display(cropped_img)
local img_out = drawSkeletonPoints(img, hm[i], preds_img[1], max)
--local img_out = drawOutput(cropped_img, hm[i], preds_hm[1], max)
image.display(img_out)--]]


function view()
	local images_paths = load_files('/Users/mauro/Documents/pycharm/multiview-people-recognition/data/shelf/Camera2', 'png')
	local res_path = '/Users/mauro/Desktop/testing/data/shelf/shelf_camera2/'
	local centers_paths = load_files(paths.concat(res_path, 'anewell'), 'c.t7')
	local scales_paths = load_files(paths.concat(res_path, 'anewell'), 's.t7')
	local hms_paths = load_files(paths.concat(res_path, 'anewell'), 'hm.t7')
	local bbs_paths = load_files(res_path)



	local matio = require('matio')
	
	for i = 1, #bbs_paths do
		local tmp = matio.load(bbs_paths[i]))	
		
		
		
	end

	

	--[[print(#images_paths)
	print(#centers_paths)
	print(#scales_paths)
	print(hms_paths)--]]
	--[[for i = 1, #images_paths do
		--print('image: ', images_paths[i])
		local img = image.load(images_paths[i])
		local centers = torch.load(centers_paths[i])
		local scales = torch.load(scales_paths[i])
		local hms = torch.load(hms_paths[i])

		
		assert(#centers == #scales and #scales == hms:size(1))
		

		
	end]]--


		
end

view()