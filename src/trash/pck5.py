
import os
import glob
import numpy as np 
import scipy.io as sio
import torchfile
import cv2
import cv2.cv as cv
import re

def read_torch_pose(path):
	''' Reads a toch file. Return the frame number, poses and the number of poses '''
	poses = torchfile.load(path)
	src, file = os.path.split(path)
	frame = file.split('.')[0]

	n_poses = poses.shape[0]
	return int(frame), poses, n_poses

def read_mat_pose(path):
	''' Reads a mat file. Return the frame number, poses and the number of poses'''
	poses = sio.loadmat(path)
	poses = poses['poses']

	src, file = os.path.split(path)
	frame = file.split('.')[0]

	n_poses = 1
	if len(poses.shape) == 3:
		n_poses = poses.shape[2]
	
	return int(frame), poses, n_poses

def read_pose(path, mode):
	''' Reads a pose with the belagiannis mode or anewell mode '''
	if mode == 0:
		return read_mat_pose(path)
	else:
		return read_torch_pose(path)

def print_pose(img, points, color):
	''' Print pose keypoints on the specified image and return the image.   '''
	# Create a black image
	#img = np.zeros((400, 400, 3), np.uint8)
	scale = 0.8
	offset = 0
	font = cv.InitFont(1,1,scale,scale)
	i = 0

	if color == 'red':
		col = cv.Scalar(255, 0, 0)
	elif color == 'green':
		col = cv.Scalar(0, 255, 0)
	elif color == 'blue':
		col = cv.Scalar(0, 0, 255)
	elif color == 'white':
		col = cv.Scalar(255,255, 255)

	for point in points:
		x = int(point[0])
		y = int(point[1])
 
		cv.Circle(cv.fromarray(img), (x, y), 1, col, -1)
		# if(i >= 13 and i <= 15):
		# 	cv.PutText(cv.fromarray(img), str(i), (x + offset, y + offset), font, (0,0,255))
		i += 1

	#cv2.imshow('image',img)
	#cv2.waitKey(0)
	return img

def corrected_keypoints(pose, gt, mappings = None):
	'''Returns a vector of 0s and 1s marking the kp detected and the relative distance between kps.'''
	if not mappings:
		mappings = range(0, len(gt)-1)

	assert(len(mappings) == len(pose))

	# Scale = max(height, width)	
	# height and width of the bounding box
	scale = (gt.max(0) - gt.min(0) + 1).max(0)
	thresh = 0.1

	dist = np.zeros(shape=(pose.shape[0],1))

	for i in range(0, len(mappings)):
		if mappings[i] != -1:
			kp1 = pose[i,:]
			kp2 = gt[mappings[i], :]
			dist[i] = np.linalg.norm(kp1 - kp2)
		else:
			dist[i] = -1
		
	# 1 if the keypoint is correct, 0 otherwise
	dist = dist[dist != -1]
	corrected_kps = np.zeros((dist.shape[0], 1))
	corrected_kps[dist <= thresh * scale] = 1

	return corrected_kps, dist

def get_pose(poses, n_poses, index, mode):
	''' Returns the '''
	pose = []
	# Belagiannis
	if mode == 0:
		if n_poses == 1:
			pose = poses[:, 0:2]
		else:
			pose = poses[:, 0:2, index]
	else:
		pose = poses[index, :, 0:2]

	return pose

def get_distances(gts, n_persons, poses, n_poses, mappings, mode):
	distances = np.zeros(shape=(n_persons, n_poses))

	for i in range(0, n_persons):
		for j in range(0, n_poses):
			pose = get_pose(poses, n_poses, j, mode)
			c_kps, dists = corrected_keypoints(pose, gts[i, :,:], mappings)
			distances[i, j] = np.mean(dists)
	return distances

def pck(images_path, gt_path, camera, n_persons, n_keypoints, mappings):
	'''Computes the pck over the poses detected in the specified path. Saves the results into a file.'''
	
	# Paths settings
	belagiannis_path = os.path.join(images_path, 'belagiannis')
	anewell_path = os.path.join(images_path, 'anewell')

	# Load GT
	gt = sio.loadmat(gt_path)
	gt = gt['actor2D'][0]

	# Load files
	files = [[],[]]
	files[0] = glob.glob(os.path.join(belagiannis_path, '*.mat'))
	
	trexp = re.compile('.+\d{5}\.t7')  # match only pose files (like 00001.t7)
	files[1] = [f for f in glob.glob(os.path.join(anewell_path, '*.t7')) if trexp.match(f)]
	
	# accuracy[i] stores pck for the i-th frame
	accuracy = [[],[]]
	accuracy[0] = np.zeros(shape=(len(files[0]), 1))
	accuracy[1] = np.zeros(shape=(len(files[1]), 1))

	print(images_path)
	skel_name = ['Belagiannis', 'Anewell']
	for m in [0,1]:
		i = 0
		for file in files[m]:
			# Read the pose
			frame, poses, n_poses = read_pose(file, m)

			# Required variables
			corrected_kps = np.zeros(shape=(n_keypoints, 1))
			tot_poses = 0
			
			# Compute keypoints for each person
			for j in range(0, n_persons):
				real_pose = gt[j][frame,0][0,camera]
				
				if real_pose.size != 0:
					assert(real_pose.shape[0] == n_keypoints)
					pose = get_pose(poses, n_poses, j, m)

					c_kps, dists = corrected_keypoints(pose, real_pose[:, 0:2], mappings)
					corrected_kps += c_kps
					tot_poses += 1
				
			value = sum(corrected_kps) 
			if value == 0:
				accuracy[m][i] = 0
			else:
				accuracy[m][i] = value / (tot_poses * n_keypoints)
			i += 1
			
		print('{} {}'.format(skel_name[m], np.mean(accuracy[m])))
	print('\n')

def matching_check(order_by_dist, pose, gt, c_kps):
		print order_by_dist
		print('pose[{}]'.format(order_by_dist[idx][2]))
		print pose
		print('gt[{}]'.format(order_by_dist[idx][0]))
		print gt[order_by_dist[idx][0],:,:]
		print('c_kps')
		print c_kps

def pck2(images_path, gts_path, camera, n_persons, n_keypoints, mappings):
	''' Computes pck on the results given by the detector '''
	# Paths settings
	belagiannis_path = os.path.join(images_path, 'belagiannis')
	anewell_path = os.path.join(images_path, 'anewell')

	#Load GT
	gts = sio.loadmat(gts_path)
	gts = gts['actor2D'][0]

	# Load files
	files = [[],[]]
	files[0] = glob.glob(os.path.join(belagiannis_path, '*.mat'))

	trexp = re.compile('.+\d{5}\.t7')  # match only pose files (like 00001.t7)
	files[1] = [f for f in glob.glob(os.path.join(anewell_path, '*.t7')) if trexp.match(f)]

	# accuracy[i] stores pck for the i-th frame 
	accuracy = [[],[]]
	accuracy[0] = np.zeros(shape=(len(files[0]), 1))
	accuracy[1] = np.zeros(shape=(len(files[1]), 1))

	skel_name = ['Belagiannis', 'Anewell']
	print(images_path)
	for m in [0]:
		# False posistives
		fp = 0
		n_imgs = 0
		
		# For each image
		i = 0
		for file in files[m]:
			# Read the pose
			frame, poses, n_poses = read_pose(file, m)

			# Create the ground truth: set pose to zeros
			# if the subject is not present in the frame
			gt = np.zeros(shape=(n_persons, n_keypoints, 2))
			n_gts = 0
			for k in range(0, n_persons):
				tmp = gts[k][frame,0][0,camera]
				if tmp.shape[1] != 0:
					gt[k, :,:] = tmp[:,:]
					n_gts += 1  # number of gts in the current frame
						
			#distances = get_distances(gt, n_persons, poses, n_poses, m)
			distances = get_distances(gt, n_persons, poses, n_poses, mappings, m)

			# Find poses indeces with the minimum distance
			pose_idxs = np.argmin(distances, axis=1)
			min_dists = np.amin(distances, axis=1)

			# Ground truth indeces 
			gt_idxs = np.arange(0, len(min_dists))

			# Make tuples of (gt_idx, dist, pose_idx) and sort by ascending distance
			order_by_dist = zip(gt_idxs, min_dists, pose_idxs)
			order_by_dist = sorted(order_by_dist, key=(lambda x: x[1]))

			corrected_kps = np.zeros(shape=(n_keypoints, 1))

			# For each pose detected			
			tot_poses = 0
			idx = 0
			p = 0
			while idx < len(order_by_dist) and p < min(n_gts, n_poses):
				pose = get_pose(poses, n_poses, order_by_dist[idx][2], m)
				real_pose = gt[order_by_dist[idx][0],:,:]
				if np.sum(real_pose) != 0:
					c_kps, dist = corrected_keypoints(pose, real_pose, mappings)	
					corrected_kps += c_kps
					tot_poses += 1
					p += 1
				idx += 1
			
			# Compute false positives	
			if n_gts < n_poses:
				fp += (n_poses - n_gts)
			
			# Compute accuracy
			value = sum(corrected_kps) 
			if value == 0:
				if n_gts == 0:
					# Not ground truths found
					accuracy[m][i] = -1
				else:
					accuracy[m][i] = 0
			else:
				accuracy[m][i] = value / (tot_poses * n_keypoints)
			
			i += 1
		
		print('{} {}'.format(skel_name[m], np.mean(accuracy[m][accuracy[m] != -1])))
		print('fppi = {0:.2f} '.format(float(fp) / float(i)))
	print('\n')

## Computing pck
if __name__ == "__main__":
	mappings = [0,1,2,3,4,5,-1,-1,12,13,6,7,8,9,10,11]
	mappings_iaslab = [14,13,12,9,10,11,8,-1,1,0,7,6,5,2,3,4]
	pck('../data/campus/Camera0/', '../data/campus/actorsGT.mat', 0, 3, 14, mappings) 
	pck('../data/campus/Camera1/', '../data/campus/actorsGT.mat', 1, 3, 14, mappings) 
	pck('../data/campus/Camera2/', '../data/campus/actorsGT.mat', 2, 3, 14, mappings) 

	pck('../data/shelf/Camera0/', '../data/shelf/actorsGT.mat', 0, 4, 14, mappings) 
	pck('../data/shelf/Camera1/', '../data/shelf/actorsGT.mat', 1, 4, 14, mappings) 
	pck('../data/shelf/Camera2/', '../data/shelf/actorsGT.mat', 2, 4, 14, mappings) 
	pck('../data/shelf/Camera3/', '../data/shelf/actorsGT.mat', 3, 4, 14, mappings) 
	pck('../data/shelf/Camera4/', '../data/shelf/actorsGT.mat', 4, 4, 14, mappings) 

	# names = ['gianluca', 'marco', 'matteol', 'matteom', 'nicola', 'stefanog', 'stefanom']
	# cams = ['0', '1', '2']
	# for name in names:
	# 	for cam in cams:
	# 		pck('../data/iaslab/' + name + '_sync/Camera' + cam + '/', 
	# 			'../data/iaslab/' + name + '_sync/actorsGT.mat', int(cam), 1, 15, mappings_iaslab) 


	print '-------------- new ---------------------------'
	pck2('../res/campus/Camera0/', '../data/campus/actorsGT.mat', 0, 3, 14, mappings)
	pck2('../res/campus/Camera1/', '../data/campus/actorsGT.mat', 1, 3, 14, mappings)
	pck2('../res/campus/Camera2/', '../data/campus/actorsGT.mat', 2, 3, 14, mappings)




