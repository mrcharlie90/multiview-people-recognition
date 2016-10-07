import matlab.engine
import os.path


class Toolbox:
    """ A wrapper class for toolbox/detector """

    """Open the engine and add paths"""
    def __init__(self):
        src_path = os.path.abspath('.')
        toolbox_path = os.path.abspath('../toolbox/')
        self.eng = matlab.engine.start_matlab()
        self.eng.addpath(self.eng.genpath(toolbox_path))
        self.eng.addpath(src_path)
        self.eng.cd(src_path)

    def detect(self, input_image, output_dir, detector_number=2):
        if self.eng is None:
            print "Error: matlab engine not running. Create Toolbox() object first."
            exit(-1)

        """ Detect people and returns the directory where cropped images are stored."""
        return self.eng.detect(input_image, output_dir, detector_number, nargout=1)

    """Close the engine"""
    def close(self):
        self.eng.quit()
        self.eng = None

#    def detect(self, input_image, output_dir):






