function [copy_map,P] = get_tiling(y,x,patchsize)
% computes a nearest neighbor matching between patches of x and y. Then
% determines what percentage of locations were verbatim copied, over
% multiple resolutions. copy_maps contains visualizations of the copy maps
% over every resolution, innovation_capacities contains the percentage of
% verbatim copies, mr_ic contains the average.
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.

x_sz = size(x);
[J,I] = meshgrid(1:x_sz(2),1:x_sz(1));
J = J/max(J(:)); I = I/max(I(:));
% visualize tile map
pos_map = cat(3,J,I.*J,I); %todo: increase contrast + periodize

Y = im2row_patch_sample_2D(y,patchsize,1);
X = im2row_patch_sample_2D(x,patchsize,1);

pos_map = reshape(pos_map,x_sz(1)*x_sz(2),[]);
P = nn_search(Y,X);
copy_map = pos_map(P(:),:);

pos_map = reshape(pos_map,x_sz);
copy_map = reshape(copy_map,x_sz);