# OT-texture-synthesis #

A simple non-parametric texture synthesis algorithm using entropic OT to supporting the following work:

# Notes #
* All code is in native MATLAB for reproducability and was designed for fast and low memory execution. A fast patchification operator is implemented
in im2row_patch_sample_2D and row2im_patch_sample_2D to which the code owes its speed. Patchification is used for both 
non-parametric texture synthesis and for filter bank convolution, which is about as fast as MatConvNet with cudNN disabled on my modest 
graphics card (Quaddro K2200).


* To synthesize a texture, run setup.m then run demo_MRF_synthesis.m

# Additional Links #

* All images from [1] are taken from the (excellent) photography of flickr user [arbyreed](https://www.flickr.com/photos/19779889@N00/)
* The cropped dataset can be found here [arbyreed dataset](https://drive.google.com/drive/folders/0B6oh_CUacdkDSkR3cDYyZnBaRDA?usp=sharing)

* If you'd like to use random convolutional networks, you'll need to add [autonn](https://github.com/vlfeat/autonn) to your path (there is no installation required).

*Finally, these two papers are integral to the method:
[Texture Optimization for Example-based Synthesis, Kwatra et al, 2005](https://www.cc.gatech.edu/cpl/projects/textureoptimization/TO-final.pdf)
[Sinkhorn Distances: Lightspeed Computation of Optimal Transportation Distances, Marco Cuturi, 2013](https://arxiv.org/abs/1306.0895).
