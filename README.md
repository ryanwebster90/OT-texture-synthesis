# OT-texture-synthesis #

A simple non-parametric texture synthesis algorithm using entropic OT, see 

[1] [Innovative Non-parametric Texture Synthesis via Entropic Optimal Transport](https://drive.google.com/open?id=1DQrSUZm5JZVkIWdxFODY0VMnE1i3zsX4), Ryan Webster, Dec 2017

# Notes #
* All code is in native MATLAB for reproducability and was designed for fast and low memory execution.

* To synthesize a texture, run setup.m then run demo_MRF_synthesis.m
* Reproduce figures from [1] in create figures folder
* Tested on MATLAB R2015b
* Image processing toolbox is not required, but 'lanczos3' interpolation is used for experiments, so if you do not have that toolbox the images are resized with interp2 bilinear interpolation. Particularily the random convolution method looks slightly worse with bilinear interpolation.

# Additional Links #

* All images from [1] are taken from the photography of flickr user [arbyreed](https://www.flickr.com/photos/19779889@N00/)
* The cropped dataset can be found here [arbyreed dataset](https://drive.google.com/drive/folders/0B6oh_CUacdkDSkR3cDYyZnBaRDA?usp=sharing)

* If you'd like to use random convolutional networks, you'll need to the auto differentiation library [autonn](https://github.com/vlfeat/autonn) to your path. It is also in native MATLAB so no installation is required.

* See also 

[Texture Optimization for Example-based Synthesis, Kwatra et al, 2005](https://www.cc.gatech.edu/cpl/projects/textureoptimization/TO-final.pdf) 

[Sinkhorn Distances: Lightspeed Computation of Optimal Transportation Distances, Marco Cuturi, 2013](https://arxiv.org/abs/1306.0895).
