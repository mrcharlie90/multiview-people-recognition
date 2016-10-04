# multiview-people-recognition

The aim of this program is to simply acquire camera recordings and successively dectect and extract people body pose.
For each person pose annotations are added to the output videos.

## Requirements
  * MATLAB (tested with 2015b) 
  * Python 2.7
  * FFmpeg (http://ffmpeg.org)

##  Setup

- Clone the repository
   ```
     $ git clone https://github.com/mrcharlie90/multiview-people-recognition.git --recursive
   ```

- Open MATLAB and install toolbox
   ```
    > addpath(genpath('path/to/toolbox/')); 
    > savepath;
    > toolboxCompile; 
   ```
- Install matlab engine for python
   
   ```
    $ cd "matlabroot/extern/engines/python"
    $ python setup.py install
   ```

   ```
     issue: sementation fault 11
     sol: export
     /usr/local/Cellar/python/2.7.12/Frameworks/Python.framework/Versions/2.7/lib/
     to the DYLD_LIBRARY_PATH
    ```

### work in progress...stay tuned!

