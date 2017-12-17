function [patch_sample_inds,sample_inds] = create_patch_sample_inds(x,patchsize,dataratio,varargin)
% Returns linear indices of patches from a 2D grid sized x_sz. There is an
% emphasis on speed, especially when x is a single gpuArray. If your goal
% is to take patches from an image in some way, this will be faster than
% most native or mex implementations.
%
% [patch_sample_inds,sample_inds] = create_patch_sample_inds(x,5,.25);
% Randomly samples 25% of the pixel locations in the first two dimensions
% of x, then returns all indices of 5x5 patches indexed by the top left
% pixel. patch_sample_inds is (size(x,1)*size(x,2)*.25 x 5*5*size(x,3)))
% i.e. patch indices comprise the rows.
% 
% See also,
% create_sample_inds, im2row_patch_sample_2D, row2im_patch_sample_2D,
% const_conv_periodic
%
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.

opts.sample_inds = []; % you can additionally provide the indices you want, e.g. a grid
opts = vl_argparse(opts,varargin);

x_sz = size(x);
x_sz = x_sz(1:2);
use_gpu = isa(x,'gpuArray');

if ~numel(opts.sample_inds)
  sample_inds = create_sample_inds(x_sz,dataratio);
else
  sample_inds = opts.sample_inds;
end

% indices for the patch indexed by (0,0)
[j0,i0] = meshgrid(0:patchsize-1,0:patchsize-1);

if use_gpu;
  sample_inds = gpuArray(sample_inds); 
  i0 = gpuArray(i0);
  j0 = gpuArray(j0);
end;

% linear indices to 2D
j1 = floor((sample_inds-1)/x_sz(1));
i1 = sample_inds - j1*x_sz(1) - 1;

% turn topleft indices into full patchsize x patchsize indices
% also, periodize indices outside image
i = mod(bsxfun(@plus,i1,i0(:).'),x_sz(1));
j = mod(bsxfun(@plus,j1,j0(:).'),x_sz(2));

% back into linear indices
patch_sample_inds = reshape( j*x_sz(1) + i + 1,numel(sample_inds),[]);
