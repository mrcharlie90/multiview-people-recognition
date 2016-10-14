import subprocess as subp
import os.path
import argparse
import numpy as np
import scipy.misc
import glob

os.environ['GLOG_minloglevel'] = '2'  # comment when debugging

import caffe
import matlab.engine
from estimate_pose import estimate_pose

class SkeletalTracker:
    """Class used for computing a skeleton of one person inside an image"""
    def __init__(self, path):
        self.path = path
        self.eng = None

    def skeletonize_keypoint(self, input_path, in_ext, use_cpu, visualize):
        """ Pose estimation based on [belagiannis2016] method """
        src_path = os.path.abspath('.')
        self.eng = matlab.engine.start_matlab()
        self.eng.addpath(src_path)
        self.eng.cd(src_path)
        self.eng.addpath(self.eng.genpath('../keypoint-matlab-demo'))

        self.eng.skeletonize_keypoint(input_path, in_ext, use_cpu, visualize, nargout=0)

    def skeletonize_cnn(self, input_path, in_ext, use_cpu, gpu, scales, visualize):
        """ Pose estimation based on [eldar2016] method"""

        model_def = '../models/ResNet-152.prototxt'
        model_bin = '../models/ResNet-152.caffemodel'

        images = []
        dest_folder = None
        if os.path.isfile(input_path):
            image_name = os.path.split(input_path)[1]
            suffix = image_name.split('.')[1]
            if suffix == in_ext:
                images = [input_path]
                dest_folder = os.path.split(input_path)[0]
            else:
                print "Skeletonize: not a valid image file -> ", input_path
        elif os.path.isdir(input_path):
            images = glob.glob(os.path.join(input_path, "*.png"))
            dest_folder = input_path

        # Selecting cpu/gpu mode
        if use_cpu:
            caffe.set_mode_cpu()
        else:
            caffe.set_mode_gpu()
            caffe.set_device(gpu)

        for img_path in images:
            image = scipy.misc.imread(img_path)

            if image.ndim == 2:
                print "WARNING: Image in grayscale! This may deteriorate performance!"
                image = np.dstack((image, image, image))
            else:
                image = image[:, :, ::-1]  # BGR format needed

            # Deepcut-cnn skeletal tracker algorithm
            pose = estimate_pose(image, model_def, model_bin, scales)

            # Saving results
            file_name = os.path.split(img_path)[1]
            file_name = file_name.split('.')[0]
            out_name = os.path.join(dest_folder, file_name + '.npz')
            np.savez_compressed(out_name, pose=pose)

            print 'Pose estimated, results stored in ', out_name

            if visualize:
                skel = image[:, :, ::-1].copy()
                # colors = [[255, 0, 0], [0, 255, 0], [0, 0, 255], [0, 245, 255], [255, 131, 250], [255, 255, 0],
                #          [255, 0, 0], [0, 255, 0], [0, 0, 255], [0, 245, 255], [255, 131, 250], [255, 255, 0],
                #          [0, 0, 0], [255, 255, 255]]
                color = [255, 0, 0]
                for p_idx in range(14):
                    self.skeldraw(skel, pose[0, p_idx], pose[1, p_idx], color)

                skel_folder = os.path.join(dest_folder, 'skel')
                if not os.path.exists(skel_folder):
                    os.mkdir(skel_folder)
                skel_name = os.path.join(skel_folder, file_name + '_skel.png')
                scipy.misc.imsave(skel_name, skel)

    def skeldraw(self, image, cx, cy, color):
        """ Draw the skeleton in the given image """
        r = 3  # radius
        alpha = 0.0  # transparency
        cx = int(cx)
        cy = int(cy)
        h, w, ch = image.shape
        lx = max(0, cx - r)  # left-x
        rx = min(cx + r, w)  # right-x
        ty = max(0, cy - r)  # top-y
        by = min(cy + r, h)  # bottom-y

        y, x = np.ogrid[-r:r, -r:r]
        index = x ** 2 + y ** 2 <= r ** 2
        try:
            image[ty:by, lx:rx][index] = (image[ty:by, lx:rx][index].astype('float32') * alpha
                                          + np.array(color).astype('float32')
                                          * (1.0 - alpha)).astype('uint8')
        except IndexError:
            print 'Index Error Catched.'

