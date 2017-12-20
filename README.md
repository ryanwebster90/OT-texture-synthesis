# OT-texture-synthesis #

Included here are the non-parametric texture synthesis algorithms of Texture Optimization [2], The bidirectional similarity method [3] and a method using Sinkhorn's algorithm [4], discussed in more detail in [1]* NOTE: This is a working copy.


# Notes #
* All code is in native MATLAB for reproducability and was designed for fast and low memory execution.

* To synthesize a texture, run setup.m then run demo_MRF_synthesis.m
* Choose which algorithm to run by changing match_heurisitic to 'OT'[1], 'BS' for [3] or 'NN' for [2]
* Reproduce figures from [1] in create figures folder
* Tested on MATLAB R2015b
* Image processing toolbox is not required, but 'lanczos3' interpolation is used for experiments, so if you do not have that toolbox the images are resized with interp2 bilinear interpolation. Particularily the random convolution method looks slightly worse with bilinear interpolation.

# Additional Links #

* All images from [1] are taken from the photography of flickr user [arbyreed](https://www.flickr.com/photos/19779889@N00/)
* The cropped dataset can be found here [arbyreed dataset](https://drive.google.com/drive/folders/0B6oh_CUacdkDSkR3cDYyZnBaRDA?usp=sharing)

* If you'd like to use random convolutional networks, you'll need to the auto differentiation library [autonn](https://github.com/vlfeat/autonn) to your path. It is also in native MATLAB so no installation is required.

* See also 

[1] [Innovative Non-parametric Texture Synthesis via Entropic Optimal Transport](https://drive.google.com/open?id=1DQrSUZm5JZVkIWdxFODY0VMnE1i3zsX4), Ryan Webster, NOTE: This is subject to change. 

[2] [Texture Optimization for Example-based Synthesis, Kwatra et al, 2005](https://www.cc.gatech.edu/cpl/projects/textureoptimization/TO-final.pdf) 

[3] [Summarizing Visual Data Using Bidirectional Similarity](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.140.2545&rep=rep1&type=pdf), 2008

[4] [Sinkhorn Distances: Lightspeed Computation of Optimal Transportation Distances, Marco Cuturi, 2013](https://arxiv.org/abs/1306.0895).
