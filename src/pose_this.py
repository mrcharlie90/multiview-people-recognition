#
# Edited by MP on 03/10/2016
# ver. 1.0
#

import os
import numpy as np
import argparse
import glob

from toolbox import Toolbox
from skeltracker import SkeletalTracker

##### Parsing #####
parser = argparse.ArgumentParser(usage='pose_this.py path/to/video.avi ',
                                 description='Take a video with people moving and output \
                                 a video with skeletons of them.')
parser.add_argument('imgs_path', help='input image or directory of images')
parser.add_argument('--img_ext', metavar='EXT', help='image extension', default='png')
parser.add_argument('--out_dir', metavar='OUT_DIR', help='output directory name (not path) that will be places in ../res/.',
                    default='out')
parser.add_argument('--premodel', metavar='MODEL',
                    help='Choose from \'acf\' or \'chk\' for Aggregated Channel Features and Checkerboard '
                         'filtered channel features respectevely.',
                    default='acf')
parser.add_argument('--version', action='version', version='%(prog)s 1.0')
args = parser.parse_args()
### End Parsing ###




##### Main #####

imgs_path = args.imgs_path
img_ext = args.img_ext
out_dir_name = args.out_dir
mode = args.premodel

# Get images
imgs = []
if not os.path.isfile(imgs_path):
    imgs = glob.glob(os.path.join(imgs_path, '*.' + img_ext))

splitting = None

# Path where to store results
res_path = '../res/'
if not os.path.exists(res_path):
    os.mkdir(res_path)

out_path = os.path.join(res_path, out_dir_name)

# Apply detection and pose estimation for each image
t = None  # = Toolbox()
st = SkeletalTracker("./pose/pose_demo.py")

# Detection
if imgs:
    pass
    #t.detect_parallel(imgs_path, out_path, mode='chk')  # single file case
else:
    t.detect(imgs_path, out_path, 'chk')  # directory case

# Get detection resutls
det_imgs = glob.glob(os.path.join(out_path, "*.png"))
bbs_list = glob.glob(os.path.join(out_path, "*_bbs.mat"))
dirs = glob.glob(os.path.join(out_path, "*/"))
i = 1

# st.skeletonize('../res/terrace/2/1.png', ['--use_cpu'])  #, '--scales', '0.4', '0.3'])
for d in dirs:
    st.skeletonize(d, ['--use_cpu', '--scales', '0.4', '0.3'])
    npzetas = glob.glob(os.path.join(d, '*.npz'))

    # st.skeldraw(imgs_path,out_path, bbs_list, npzetas)
    i += 1
    if i == 3:
        exit(0)



# print imgs
# print det_imgs
# print dirs




# SEQUENTIAL SOLUTION
# rounds = 100
# i = 0
# For each image specified do
# for img in imgs:
#     # Detection
#     out_path = os.path.join(res_path, out_dir_name)
#     bbs_path = t.detect(img, out_path, mode=mode)
#     print bbs_path
#     # For each people detected do pose estimation
#     for patch in list(os.listdir(bbs_path)):
#         patch_path = os.path.join(bbs_path, patch)
#         if not os.path.isdir(patch_path):
#             splitting = patch.split('.')
#
#             if splitting[1] == img_ext:
#                 pass
#                 #st.skeletonize(['--use_cpu'], patch_path, bbs_path)
#     i += 1
#     if i == rounds:
#         break

# Close the matlab engine
#t.close()





### End Main ###

# parser.add_argument('-o', metavar='name', nargs='?', help='output video file name')
# parser.add_argument('-r', metavar='rate_value', nargs='?', default='1',
#                     help='I/O frame rate (see ffmpeg documentation)')
# parser.add_argument('-numdetector', metavar='number', nargs='?', default=2,
#                     help='detector number')
#
# parser.add_argument('')





##### Functions #####
# def file_name(path):
#     ''' Extract a filename from a given path, without extension. '''
#     splitting = vin.split('/')
#     return splitting[len(splitting) - 1].split('.')[0]
#
# def create_dir(name):
#     ''' Create a directory.'''
#     try:
#         os.mkdir(name)
#     except OSError:
#         pass
### End Functions ###



# video_name = file_name(vin)
# if not args.o:
#     vout = video_name + '_out.avi'
# else:
#     vout = args.o
#
# rate = args.r
# numdetector = args.numdetector
#
# results_path = '../res/'
# create_dir(results_path)
#
# video_folder = results_path + video_name + '/'
# create_dir(video_folder)
#
#
#
# # Call FFmpeg and convert the video in images stored in ../res/video_name
# print 'Converting video to images...'
# subprocess.call(['ffmpeg', '-hide_banner','-y',
#                  '-i', vin, '-r', rate,
#                   video_folder + video_name + '-%03d.png'])
# print 'done!'
#
#
#
#
#
#
# # Process each image with the detector
# print 'Detecting people...'
# eng = matlab.engine.start_matlab()
# eng.detect(video_folder, numdetector, 1, nargout=0)
# print 'done!'
#
# # Convert resulting images to video
# print 'Completing detection video...'
# video_out_folder = video_folder + 'video_out/'
# subprocess.call(['ffmpeg', '-hide_banner','-y',
#                  '-i', video_out_folder + video_name + '-%03d.png',
#                  '-r', rate, video_out_folder + vout])
# print 'done! Results stored in ' + video_out_folder
#
# # Computing skeletal tracking
#
#
#
#
#
# ### End Main ###
#
