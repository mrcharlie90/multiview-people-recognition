import matlab.engine
import os.path


class Toolbox:
    """ A wrapper class for toolbox/detector """

    def __init__(self):
        """Open the engine and add paths"""
        src_path = os.path.abspath('.')

        self.eng = matlab.engine.start_matlab()
        self.eng.addpath(src_path)
        self.eng.cd(src_path)

    def detect(self, img_file, output_dir, mode='acf'):
        """ Detect people and returns the directory where cropped images are stored."""
        if self.eng is None:
            print "Error: matlab engine not running. Create Toolbox() object first."
            exit(-1)

        det_num = 0
        if mode == 'acf':
            self.eng.addpath(self.eng.genpath('../toolbox/'))
            det_num = 4
        elif mode == 'chk':
            self.eng.addpath(self.eng.genpath('../filtered-channel-features/'))
            det_num = 7
        else:
            print 'Invalid mode. Choone one from \'acf\' (Aggregated Channel Features) and \'chk\' ' \
                  '(Checkerboard Filtered Channel Features)'
            exit(-1)

        return self.eng.detector(img_file, output_dir, det_num, 10, 90.0, nargout=1)

    def detect_parallel(self, input_dir, output_dir, ext='png', mode='acf'):
        """ Detecting people given a directory of frames """
        if self.eng is None:
            print "Error: matlab engine not running. Create Toolbox() object first."
            exit(-1)

        det_num = 0
        if mode == 'acf':
            self.eng.addpath(self.eng.genpath('../toolbox/'))
            det_num = 4
        elif mode == 'chk':
            self.eng.addpath(self.eng.genpath('../filtered-channel-features/'))
            det_num = 7
        else:
            print 'Invalid mode. Choone one from \'acf\' (Aggregated Channel Features) and \'chk\' ' \
                  '(Checkerboard Filtered Channel Features)'
            exit(-1)

        self.eng.detector_parallel(input_dir, output_dir, ext, det_num, 10, 90.0, nargout=0)


    def close(self):
        """Close the engine"""
        self.eng.quit()
        self.eng = None

#    def detect(self, input_image, output_dir):






