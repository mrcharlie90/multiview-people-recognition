import matlab.engine


class Toolbox:
    """ A wrapper class for toolbox/detector """

    def __init__(self, detector_path):
        self.detector_path = detector_path

    def detect(self, in_image, out_folder):
        eng = matlab.engine.start_matlab()
        #eng.detect(video_folder, numdetector, 1, nargout=0)
