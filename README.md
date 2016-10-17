# multiview-people-recognition

The aim of this program is to simply acquire camera recordings and successively dectect and extract people body pose.
For each person pose annotations are added to the output videos.

## Requirements
  * MATLAB (tested with 2015b) (better with Parallel Toolbox package)
  * Python 2.7

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
     sol: export /usr/local/Cellar/python/2.7.12/Frameworks/Python.framework/Versions/2.7/lib/
     to the DYLD_LIBRARY_PATH
   ```

#### Notes:
* The complete code of filtered channel features can be found [here](https://bitbucket.org/shanshanzhang/code_filteredchannelfeatures) (we use only the LCDF based ones)
* Execute a bash clean.sh before run pose_this.py on a folder
* When using deepcut-cnn try large scales values for small subjects

### work in progress...stay tuned!

#### References

```
Filtered channel features detector
@INPROCEEDINGS{Shanshan2015CVPR,
  Author = {Shanshan Zhang and Rodrigo Benenson and Bernt Schiele},
  Title = {Filtered Channel Features for Pedestrian Detection},
  Booktitle = {CVPR},
  Year = {2015}
}
@INPROCEEDINGS{Shanshan2016CVPR,
  Author = {Shanshan Zhang and Rodrigo Benenson and Mohamed Omran and Jan Hosang and Bernt Schiele},
  Title = {How Far are We from Solving Pedestrian Detection?},
  Year = {2016},
  Booktitle = {CVPR}
}

Based on Piott's toolbox
@misc{PMT, 
   author = {Piotr Doll\'ar}, 
   title = {{P}iotr's {C}omputer {V}ision {M}atlab {T}oolbox ({PMT})}, 
   howpublished = {\url{https://github.com/pdollar/toolbox}} 
} 


The skeletal tracker (deepcut-cnn)
@inproceedings{insafutdinov2016deepercut,
    author = {Eldar Insafutdinov and Leonid Pishchulin and Bjoern Andres and Mykhaylo Andriluka and Bernt Schieke},
    title = {DeeperCut: A Deeper, Stronger, and Faster Multi-Person Pose Estimation Model},
    booktitle = {European Conference on Computer Vision (ECCV)},
    year = {2016},
    url = {http://arxiv.org/abs/1605.03170}
    }
@inproceedings{pishchulin16cvpr,
    author = {Leonid Pishchulin and Eldar Insafutdinov and Siyu Tang and Bjoern Andres and Mykhaylo Andriluka and Peter Gehler and Bernt Schiele},
    title = {DeepCut: Joint Subset Partition and Labeling for Multi Person Pose Estimation},
    booktitle = {IEEE Conference on Computer Vision and Pattern Recognition (CVPR)},
    year = {2016},
    url = {http://arxiv.org/abs/1511.06645}
}

```

