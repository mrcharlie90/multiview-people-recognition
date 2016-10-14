#
# Edited by MP on 03/10/2016
# ver. 1.0
#

import os
import argparse
import glob

from toolbox import Toolbox
from skeltracker import SkeletalTracker

""" Parsing """
parser = argparse.ArgumentParser(usage='pose_this.py path/to/video.avi ',
                                 description='Multi-people pose estimation: apply a detection algorithm based on '
                                             'Aggregated Channel Features [ACF] to one or a set of images and estimates '
                                             'the relative pose.')
parser.add_argument('imgs_path', help='Input image or a directory of images.')
parser.add_argument('--img_ext', help='Image extension.', default='png')
parser.add_argument('--detmodel', help='Choose one from \'acf\' (Aggregated Channel Features) or \'chk\' (Checkerboard'
                                       ' Filtered Channel Features) respectevely.', default='chk')
parser.add_argument('--out_dir',
                    help='Output directory name (not path) that will be places in the result directory.',
                    default='out')
parser.add_argument('--st',
                    type=int,
                    help='Choose one skeletal tracker among Belagiannis(1) and Deepcut(2)',
                    default=1)
parser.add_argument('--visualize',
                    action='store_true',
                    help='Whether to create a visualization of the pose. Default: True.',
                    default=False)
parser.add_argument('--scales',
                    nargs='*',
                    type=float,
                    help='The scales to use, comma-separated. The most confident will be stored. Default: 1.',
                    default=[1.])
parser.add_argument('--use_cpu',
                    action='store_true',
                    help='Use CPU instead of GPU for predictions.',
                    default=False)
parser.add_argument('--gpu_id',
                    help='GPU device id to use.',
                    default=0)
parser.add_argument('--version', action='version', version='%(prog)s 1.0')
args = parser.parse_args()

imgs_path = args.imgs_path
img_ext = args.img_ext
out_dir = args.out_dir
detmodel = args.detmodel
visualize = args.visualize
use_cpu = args.use_cpu
scales = args.scales
gpu_id = args.gpu_id
st = args.st
""" End Parsing """

""" Main """
# Get images
imgs = []
if not os.path.isfile(imgs_path):
    imgs = glob.glob(os.path.join(imgs_path, '*.' + img_ext))

splitting = None

# Path where to store results
res_path = '../res/'
if not os.path.exists(res_path):
    os.mkdir(res_path)

out_path = os.path.join(res_path, out_dir)

# Apply detection and pose estimation for each image
t = Toolbox()


# Detection
if imgs:
    t.detect_parallel(imgs_path, out_path, mode=detmodel)  # single file case
else:
    t.detect(imgs_path, out_path, detmodel)  # directory case

# Get detection resutls
det_imgs = glob.glob(os.path.join(out_path, "*.png"))
bbs_liskeltracker = glob.glob(os.path.join(out_path, "*_bbs.mat"))
dirs = glob.glob(os.path.join(out_path, "*/"))

# One image testing
# skeltracker.skeletonize('../res/terrace/2/1.png', ['--use_cpu'])  #, '--scales', '0.4', '0.3'])
skeltracker = SkeletalTracker("./pose/pose_demo.py")
i = 1
for folder in dirs:
    if st == 1:
        skeltracker.skeletonize_keypoint(folder, img_ext, use_cpu, visualize)
    elif st == 2:
        skeltracker.skeletonize_cnn(folder, img_ext, use_cpu, gpu_id, scales, visualize)

    # npzetas = glob.glob(os.path.join(d, '*.npz'))
    i += 1
    if i == 10:
        exit(0)

"""" End Main """

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







# parser.add_argument('-o', metavar='name', nargs='?', help='output video file name')
# parser.add_argument('-r', metavar='rate_value', nargs='?', default='1',
#                     help='I/O frame rate (see ffmpeg documentation)')
# parser.add_argument('-numdetector', metavar='number', nargs='?', default=2,
#                     help='detector number')
#
# parser.add_argument('')





""" Functions """
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
""" End Functions """



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
# """ End Main """
#
