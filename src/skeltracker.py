import subprocess as subp
import os.path
import argparse
import numpy as np
import scipy
import glob

os.environ['GLOG_minloglevel'] = '2'  # comment when debugging

import caffe
from estimate_pose import estimate_pose

class SkeletalTracker:
    """Class used for computing a skeleton of one person inside an image"""
    def __init__(self, path):
        self.path = path

    def skeletonize(self, input_image, params):
        """ Compute the skeleton of the person in the image """
        args = self.compute_parser_arguments(params)
        print args
        model_def = '../models/ResNet-152.prototxt'
        model_bin = '../models/ResNet-152.caffemodel'

        images = []
        dest_folder = None
        if os.path.isfile(input_image):
            image_name = os.path.split(input_image)[1]
            suffix = image_name.split('.')[1]
            if suffix == args.folder_image_suffix:
                images = [input_image]
                dest_folder = os.path.split(input_image)[0]
            else:
                print "Skeletonize: not a valid image file."
        elif os.path.isdir(input_image):
            images = glob.glob(os.path.join(input_image, "*.png"))
            dest_folder = input_image

        # Selecting cpu/gpu mode
        if args.use_cpu:
            caffe.set_mode_cpu()
        else:
            caffe.set_mode_gpu()
            caffe.set_device(args.gpu)

        for img_path in images:
            image = scipy.misc.imread(img_path)

            if image.ndim == 2:
                print "WARNING: Image in grayscale! This may deteriorate performance!"
                image = np.dstack((image, image, image))
            else:
                image = image[:, :, ::-1]  # BGR format needed

            # Deepcut-cnn skeletal tracker algorithm
            pose = estimate_pose(image, model_def, model_bin, args.scales)

            print pose
            # Saving results
            file_name = os.path.split(img_path)[1]
            file_name = file_name.split('.')[0]
            out_name = os.path.join(dest_folder, file_name + '.npz')
            np.savez_compressed(out_name, pose=pose)

            print 'Pose estimated, resutls stored in ', out_name

    def skeldraw(self, input_image, out_path, bbs, npzetas):
        """ Draw the skeleton in the given image """
        scipy.misc.imread(input_image)

    def compute_parser_arguments(self, params):
        parser = argparse.ArgumentParser()
        parser.add_argument('--out_name',
                            help='The result location to use. By default, use `image_name`_pose.npz.',
                            default=None)
        parser.add_argument('--scales',
                            nargs='*',
                            type=float,
                            help='The scales to use, comma-separated. The most confident will be stored. Default: 1.',
                            default=[1.])
        parser.add_argument('--visualize',
                            help='Whether to create a visualization of the pose. Default: True.',
                            default=False)
        parser.add_argument('--folder_image_suffix',
                            help='The ending to use for the images to read, if a folder is specified. Default: .png.',
                            default='png')
        parser.add_argument('--use_cpu',
                            action='store_true',
                            help='Use CPU instead of GPU for predictions.',
                            default=False)

        parser.add_argument('--gpu',
                            help='GPU device id.',
                            default=0)
        return parser.parse_args(params)