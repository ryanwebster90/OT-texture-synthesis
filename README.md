# OT-texture-synthesis #

Included here is a non-parametric texture synthesis algorithm desribed in [1], which finds permutations of patches using [2] below.

[1] [Innovative Non-parametric Texture Synthesis via Patch Permutations](https://arxiv.org/abs/1801.04619) , Ryan Webster, 2018. 

# Notes #
* All code is in native MATLAB for reproducability and was designed for fast and low memory execution.
* To synthesize a texture, run setup.m then run demo_MRF_synthesis.m
* Reproduce figures from [1] in create figures folder
* Tested on MATLAB R2015b
* Image processing toolbox is not required, but 'lanczos3' interpolation is used for experiments, so if you do not have that toolbox the images are resized with interp2 bilinear interpolation. Particularily the random convolution method looks slightly worse with bilinear interpolation.Summarizing Visual Data Using Bidirectional Similarity, Simakov et al, 2008

# Additional Links #

* All images from [1] are taken from the photography of flickr user [arbyreed](https://www.flickr.com/photos/19779889@N00/)

* If you'd like to use random convolutional networks, you'll need to the auto differentiation library [autonn](https://github.com/vlfeat/autonn) to your path. It is also in native MATLAB so no installation is required.

* See also

[2] [Sinkhorn Distances: Lightspeed Computation of Optimal Transportation Distances, Marco Cuturi, 2013](https://arxiv.org/abs/1306.0895).
[3] Summarizing Visual Data Using Bidirectional Similarity, Simakov et al, 2008
