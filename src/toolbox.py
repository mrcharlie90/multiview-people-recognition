import matlab.engine


class Toolbox:
    """ A wrapper class for toolbox/detector """

    def __init__(self, detector_path):
        self.detector_path = detector_path
        self.eng = matlab.engine.start_matlab()
        self.eng.setup(nargout=0)

    def detect(self, in_image, out_folder):

