import os
import glob
import numpy as np 
import scipy.io as sio
import torchfile
import cv2
import cv2.cv as cv
import re


def read_torch_pose(path):
	''' Reads a torch file and return the relative frame, person number and the pose'''
	poses = torchfile.load(path)
	src, file = os.path.split(path)
	frame = file.split('.')[0]

	n_poses = poses.shape[0]
	return int(frame), poses, n_poses

def read_mat_pose(path):
	''' Reads a mat file and return the relative frame, person number and the pose'''
	poses = sio.loadmat(path)
	poses = poses['poses']

	src, file = os.path.split(path)
	frame = file.split('.')[0]

	n_poses = 1
	if len(poses.shape) == 3:
		n_poses = poses.shape[2]
	
	return int(frame), poses, n_poses


def read_pose(path, mode):
	if mode == 0:
		return read_mat_pose(path)
	else:
		return read_torch_pose(path)

def get_centers_distance(gt, pose):
	# c = [x_max - x_min, y_max - y_min]
	p_center = np.array([ pose.max(0)[0] - pose.min(0)[0], pose.max(0)[1] - pose.min(0)[1] ])
	gt_center = np.array([ gt.max(0)[0] - gt.min(0)[0], gt.max(0)[1] - gt.min(0)[1] ])

	return np.linalg.norm(p_center - gt_center)

def get_pose(poses, n_poses, index, mode):
	pose = []
	if n_poses == 1:
		pose = poses[:, 0:2]
	else:
		pose = poses[:, 0:2, index]
	
	if mode == 1:
		pose = poses[index, :, 0:2]

	return pose

def get_distances(gts,  n_persons, poses, n_poses, mode):

	# Will contains each pair of distances
	distances = np.zeros(shape=(n_persons, n_poses))

	
	for i in range(0, n_persons):
		for j in range(0, n_poses):
			pose = get_pose(poses, n_poses, j, mode)
			distances[i, j] = get_centers_distance(gts[i,:,:], pose)

	return distances

def get_distances2(gts, n_persons, poses, n_poses, mappings, mode):
	distances = np.zeros(shape=(n_persons, n_poses))

	for i in range(0, n_persons):
		for j in range(0, n_poses):
			pose = get_pose(poses, n_poses, j, mode)
			tmp = corrected_keypoints(pose, gts[i, :,:], mappings)
			distances[i, j] = np.sum(tmp)
	

def corrected_keypoints(pose, gt, mappings = None):
	'''Computes the pck between the pose candidate and the ground truth'''
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

	return corrected_kps

def pck2():
	# Paths settings
	images_path = '../res/shelf/Camera0/' 
	belagiannis_path = os.path.join(images_path, 'belagiannis')
	anewell_path = os.path.join(images_path, 'anewell')

	#Future params
	camera = 0
	n_persons = 4
	n_keypoints = 14

	#Load GT
	gts_path = '../data/shelf/actorsGT.mat'
	gts = sio.loadmat(gts_path)
	gts = gts['actor2D'][0]

	mappings = [0,1,2,3,4,5,-1,12,-1,13,6,7,8,9,10,11]

	files = [[],[]]
	files[0] = glob.glob(os.path.join(belagiannis_path, '*.mat'))

	# Matching only pose files (like 00001.t7)
	trexp = re.compile('.+\d{5}\.t7')
	files[1] = [f for f in glob.glob(os.path.join(anewell_path, '*.t7')) if trexp.match(f)]

	accuracy = [[],[]]
	accuracy[0] = np.zeros(shape=(len(files[0]), 1))
	accuracy[1] = np.zeros(shape=(len(files[1]), 1))

	skel_name = ['Belagiannis', 'Anewell']
	for m in [0]:
		print(skel_name[m])

		# False posistives
		fp = 0
		n_imgs = 0
		
		# For each image
		i = 0
		for file in files[m]:
			# Read the pose
			frame, poses, n_poses = read_pose(file, m)


			# Gourd truth poses and the total number 
			# (used for computing false positives)
			gt = np.zeros(shape=(n_persons, n_keypoints, 2))

			n_gts = 0
			for k in range(0, n_persons):
				tmp = gts[k][frame,0][0,camera]
				if frame == 566:
					print tmp
					print('\n')
				if tmp.shape[1] != 0:
					gt[k, :,:] = tmp[:,:]
					n_gts += 1
						
			#distances = get_distances(gt, n_persons, poses, n_poses, m)
			distances = get_distances2(gt, n_persons, poses, n_poses, mappings, m)
			if frame == 566:
				print 'Distances'
			print(distances)

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
			p = 0
			g = 0
			while p < len(order_by_dist) and g < n_gts:
				pose = get_pose(poses, n_poses, order_by_dist[p][2], m)
				real_pose = gt[order_by_dist[p][0],:,:]
				if np.sum(real_pose) != 0:
					if frame == 566:
						print order_by_dist
						print pose
						print gt[order_by_dist[p][0],:,:]
					corrected_kps += corrected_keypoints(pose, real_pose, mappings)	
					tot_poses += 1
					g += 1
				p += 1
				
			# for p in range(0, n_poses):
			# 	pose = get_pose(poses, n_poses, order_by_dist[p][2], m)
			# 	if frame == 566:
			# 		print order_by_dist
			# 		print pose
			# 		print gt[order_by_dist[p][0],:,:]

				
			
			value = sum(corrected_kps) 
			if value == 0:
				if n_gts == 0:
					accuracy[m][i] = -1
				else:
					accuracy[m][i] = 0
			else:
				accuracy[m][i] = value / (tot_poses * n_keypoints)
			print('n_gts = ' + str(n_gts))
			print('n_poses = ' + str(n_poses))
			print('{}: {}\n'.format(frame, accuracy[m][i]))	
			i += 1
			
			break
		print('{} {}'.format(skel_name[m], np.mean(accuracy[m][accuracy[m] != -1])))
	print('\n')
	


pck2()
