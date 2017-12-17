function sample_inds = grid_sample_inds(x_sz,stride)
% Returns strided linear indices from first two dimensions of x_sz
%
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.

x_sz = x_sz(1:2);
tmp = false(x_sz);
tmp(1:stride:end,1:stride:end) = true;
sample_inds = find(tmp(:));