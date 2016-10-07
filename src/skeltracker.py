import subprocess as subp
import os.path

class SkeletalTracker:
    """Class used for computing a skeleton of one person inside an image"""
    def __init__(self, path):
        self.path = path

    def skeletonize(self, params, input_image, output_dir):
        st_path = os.path.abspath(self.path)
        command = [st_path] # pose_demo.py
        print input_image
        command.append(input_image)

        for param in params:
            command.append(param)


        subp.call(command)
