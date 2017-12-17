function ic = innovation_capacity(x_sz,P)
% Computes the percentage of tiled pixels, given a match Y* = X(P(:),:);
% A pixel is tiled if its mapping under P maintains the same indexing.
% For example, if P is a circshift operator, then ic = 0. 
%
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.

x_sz = x_sz(1:2);
copy_map = reshape(P,x_sz); % mapping of identity tile map
pos_map = reshape( 1:numel(P),x_sz); % identity tile map
X = im2row_patch_sample_2D(pos_map,2,1); % patches of indexes of identity tile map
X = X(P(:),:); % map identity tiles under P
Y = im2row_patch_sample_2D(copy_map,2,1); 

X = X(:,2:4); % only neighboring pels
Y = Y(:,2:4); 

tmp = X==Y; % locations where P tiles
ic = 1-nnz(tmp)/numel(X); % total percentage of tiled pixels
