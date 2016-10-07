#
# Edited by MP on 03/10/2016
# ver. 1.0
#

import os
import argparse

from toolbox import Toolbox
from skeltracker import SkeletalTracker

##### Parsing #####
parser = argparse.ArgumentParser(usage='pose_this.py path/to/video.avi ',
                                 description='Take a video with people moving and output \
                                 a video with skeletons of them.')
parser.add_argument('in_path', help='input image or directory of images')
parser.add_argument('--img_ext', metavar='EXT', help='image extension', default='png')
parser.add_argument('--version', action='version', version='%(prog)s 1.0')
args = parser.parse_args()
### End Parsing ###




##### Main #####

in_path = args.in_path
img_ext = args.img_ext

imgs = []


# Save images' paths
try:
    for elem in list(os.listdir(in_path)):
        splitting = elem.split('.')
        if len(splitting) > 1 and splitting[1] == img_ext:
            imgs.append(os.path.join(in_path, elem))
except OSError:
    if os.path.isfile(in_path):
        file_name = os.path.basename(in_path)
        splitting = file_name.split('.')
        if len(splitting) > 1 and splitting[1] == img_ext:
            imgs.append(os.path.join(in_path))
    else:
        print 'You must give a valid file/directory name'
        exit(0)

splitting = None

# Path where to store results
res_path = '../res/'
if not os.path.exists(res_path):
    os.mkdir(res_path)

# Apply detection and pose estimation for each image
t = Toolbox()
st = SkeletalTracker("./pose/pose_demo.py")
# For each image specified do
for img in imgs:
    # Detection
    bbs_path = t.detect(img, res_path, 2)
    # For each people detected do pose estimation
    for patch in list(os.listdir(bbs_path)):
        patch_path = os.path.join(bbs_path, patch)
        if not os.path.isdir(patch_path):
            splitting = patch.split('.')

            if splitting[1] == img_ext:
                st.skeletonize(['--use_cpu'], patch_path, bbs_path)



# Close the matlab engine
t.close()





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
