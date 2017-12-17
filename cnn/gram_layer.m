function gram_mat = gram_layer(x)
% computes gram matrix of features
% 
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.

x = reshape(x,[],size(x,3));
gram_mat = x'*x;
gram_mat = gram_mat/(size(x,2));