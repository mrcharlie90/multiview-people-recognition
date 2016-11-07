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
	print ('---->' + str(poses.shape))

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
	#print('frame: ',int(frame))	
	#print('person: ',int(person))
	return int(frame), poses, n_poses


def read_pose(path, mode):
	if mode == 0:
		return read_mat_pose(path)
	else:
		return read_torch_pose(path)

def print_pose(img, points, color):
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

def pck(images_path, gt_path, camera, n_persons, n_keypoints, mappings):
	# Paths settings
	#images_path = 'campus/Camera0/' 
	belagiannis_path = os.path.join(images_path, 'belagiannis')
	anewell_path = os.path.join(images_path, 'anewell')

	# Future params
	#camera = 0
	#n_persons = 3
	#n_keypoints = 14

	# Load GT
	#gt_path = 'campus/actorsGT.mat'
	gt = sio.loadmat(gt_path)
	gt = gt['actor2D'][0]

	#mappings = [0, 1, 2, 3, 4, 5, 10, 11, 12, 13, 14, 15, 8, 9]

	files = [[],[]]
	files[0] = glob.glob(os.path.join(belagiannis_path, '*.mat'))
	
	# Matching only pose files (like 00001.t7)
	trexp = re.compile('.+\d{5}\.t7')
	files[1] = [f for f in glob.glob(os.path.join(anewell_path, '*.t7')) if trexp.match(f)]
	
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
			#print('FRAME = ' + str(frame))
			# Required variables
			corrected_kps = np.zeros(shape=(n_keypoints, 1))
			tot_poses = 0
				

			# Compute keypoints for each person
			for j in range(0, n_persons):
				real_pose = gt[j][frame,0][0,camera]
				
				if real_pose.size != 0:
					assert(real_pose.shape[0] == n_keypoints)
					pose = []
					if m == 0:
						if len(poses.shape) == 3:
							pose = poses[:, 0:2, j]
						else:
							pose = poses[:, 0:2]
					else:	
						pose = poses[j, :, 0:2]

					corrected_kps += corrected_keypoints(pose, real_pose[:, 0:2], mappings)
					tot_poses += 1
				

			value = sum(corrected_kps) 
			if value == 0:
				accuracy[m][i] = 0
			else:
				accuracy[m][i] = value / (tot_poses * n_keypoints)
			
			print('{}: {}\n'.format(frame, accuracy[m][i]))	
			i += 1
			

		print('{} {}'.format(skel_name[m], np.mean(accuracy[m])))
	print('\n')


#pck2()
mappings = [0,1,2,3,4,5,-1,-1,12,13,6,7,8,9,10,11]
mappings_iaslab = [14,13,12,9,10,11,8,-1,1,0,7,6,5,2,3,4]
pck('../data/campus/Camera0/', '../data/campus/actorsGT.mat', 0, 3, 14, mappings) 
#pck('../data/iaslab/gianluca_sync/Camera0/', '../data/iaslab/gianluca_sync/actorsGT.mat', 0, 1, 15, mappings_iaslab) 
#pck('../data/iaslab/gianluca_sync/Camera1/', '../data/iaslab/gianluca_sync/actorsGT.mat', 1, 1, 15, mappings_iaslab) 
# pck('../data/iaslab/gianluca_sync/Camera2/', '../data/iaslab/gianluca_sync/actorsGT.mat', 2, 1, 15, mappings_iaslab) 
# pck('../data/shelf/Camera0/', '../data/shelf/actorsGT.mat', 0, 4, 14, mappings)
# pck('../data/shelf/Camera1/', '../data/shelf/actorsGT.mat', 1, 4, 14, mappings)
# pck('../data/shelf/Camera2/', '../data/shelf/actorsGT.mat', 2, 4, 14, mappings)
# pck('../data/shelf/Camera3/', '../data/shelf/actorsGT.mat', 3, 4, 14, mappings)


pck2()

