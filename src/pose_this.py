#
# Edited by MP on 03/10/2016
# ver. 1.0
#

import os
import subprocess
import argparse

##### Parsing #####
parser = argparse.ArgumentParser(usage='pose_this.py <in_video> <out_video>',
                                 description='Take a video with people moving and output \
                                 a video with skeletons of them.')
parser.add_argument('-i', metavar='Vin', nargs='?', default='videoin.avi',
                    help='input video file name')
parser.add_argument('-o', metavar='Vout', nargs='?', default='videoout.avi',
                    help='output video file name')
parser.add_argument('--version', action='version', version='%(prog)s 1.0')

args = parser.parse_args()
### End Parsing ###

##### Functions #####
def file_name(path):
    ''' Extract a filename from a given path, without extension. '''
    splitting = vin.split('/')
    return splitting[len(splitting) - 1].split('.')[0]

def create_dir(name):
    ''' Create a directory.'''
    try:
        os.mkdir(name)
    except OSError:
        print 'Directory ' + name + ' already exists.'
### End Functions ###

##### Main #####
vin = args.i
vout = args.o
results_path = '../res'

video_name = file_name(vin)


create_dir(results_path)
create_dir(results_path + '/' + video_name)

# Call FFmpeg and convert the video in images stored in ../res/video_name
subprocess.call(['ffmpeg', '-hide_banner',
                 '-i', vin, '-r', '1',
                 results_path + '/' + video_name + '/' + video_name + '-%03d.png'])

# Process each image with the detector



### End Main ###

