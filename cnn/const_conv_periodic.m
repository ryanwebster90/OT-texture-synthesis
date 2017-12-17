function y = const_conv_periodic(x,w,varargin)
% Fast periodic filter bank convolution in native MATLAB, using a patchifying
% operator followed by matrix multiplication. It's about as fast as
% vl_nnconv in MatConvNet without cudNN enabled. Also computes derivatives
% dL/dx on backward pass in style of autonn. The usefulness of this file is
% reproducability, such as in an academic / classroom setting.
%
% Examples:
% % Network definition in autonn
% x = Input();
% w = randn(5,5,3,64); %64 random filters of size (5x5x3)
% y = const_conv_periodic(x,w);
% net = Net(y);
% net.eval({x,randn(256,256,3)}); % evaluate network
%
% % Forward convolution
% x = randn(256,256,3); % dummy image
% w = randn(5,5,3,64); % 64 random filters of size (5x5x3)
% y = const_conv_periodic(x,w); 
% % x = (M x N x C) w = (B x B x C x K), y = (M x N x K) 
%
% % Backward convolution
% x = randn(256,256,3); % dummy image
% w = randn(5,5,3,64); % 64 random filters of size (5x5x3)
% dy = randn(256,256,64); %dummy derivative
% dx = const_conv_periodic(x,w,dy); 
% 
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.


if isa(x,'Layer') % handle network definition in autonn
  y = Layer(@const_conv_periodic,x,w);
  y.precious = false;
  y.numInputDer = 1;
  
else
  
  if ~numel(varargin) %forward pass in eval,
    patchsize = size(w,1);
    %TODO: add options for sparse, strided, or dilated convolution
    
    % patchify
    [X,X_patch_inds] = im2row_patch_sample_2D(x,patchsize,1);
    W = reshape(w,[],size(w,4));
    % matrix multiplication
    y = X*W;
    % reshape tensor to image domain
    y = reshape(y,size(x,1),size(x,2),size(w,4));
    
  else %backward pass
    dy = varargin{1};
    [x_sz,x_type] = struct_or_tensor_size(x);
    W = reshape(w,[],size(w,4));
    dy = reshape(dy,[],size(w,4)); %der of reshape
    dy = dy*W'; %der of matrix multiplication
    
    % der of patchifying operator
    x_dummy = zeros(x_sz,'like',x_type);
    [X_patch_inds,~] = create_patch_sample_inds(x_dummy,size(w,1),1);
    dy = row2im_patch_sample_2D(x_dummy,dy,X_patch_inds,'mode','der');
    y = dy;
    
  end
  
end