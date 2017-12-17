function x = row2im_patch_sample_2D(x,X,patch_inds,varargin)
% Re-averages patches back into the image domain. 
% Alternatively, you can compute the derivative of the linear patchification operator,
% which is the tranpose operator.
%
% Emphasis is on speed by using MATLAB's fast indexing. Additionally, this
% code avoids usage of accumarray, by using the structure of the
% patchification operator. For example, the topleft pels of every patch do
% not contain duplicates, so that the operator can be slice transposed as a
% sum of indexed assignments.
%
% Example:
% [patch_sample_inds,sample_inds] = create_patch_sample_inds(x,5,1);
% [X,patch_inds,sample_inds] = im2row_patch_sample_2D(x,patchsize,dataratio,varargin)
% % Do some operation on the patches X
% 
% 
% See also,
% im2row_patch_sample_2D, const_conv_periodic
%
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.


opts.mode = 'avg'; %can be 'avg' or 'der'
opts.weights = [];
opts = vl_argparse(opts,varargin);

x_sz0 = size(x);
x_sz = [x_sz0(1),x_sz0(2),prod(x_sz0(3:end))];

patchsize = sqrt(size(X,2)/x_sz(3));

% have cols represent channel dimension
X = reshape(X,size(X,1)*size(patch_inds,2),[]);

% add patch dim offset to inds
X_lin_inds = bsxfun(@plus,patch_inds,...
  ((0:size(patch_inds,2)-1)*x_sz(1)*x_sz(2)));

% avoid using accumarray by dealing with each pixel in every patch (i.e.
% the columns of X) seperately via indexing, then summing

switch opts.mode
  case 'avg' % re-average operator
    
    % x_sz(3) + 1 for weights column
    Y = zeros( x_sz(1)*x_sz(2)*patchsize^2, x_sz(3) + 1, 'like', X);
    X = [X,ones(size(X,1),1,'like',X)];
    
    % permute pixels back to their original image domain positions, in the
    % columns of Y. This avoids usage of accumarray which is very slow.
    
    Y(X_lin_inds(:),:) = X; 
    %todo: slice this indexing struct along 1st dim for memory
    
    %reshape to image domain
    Y = reshape(Y,x_sz(1)*x_sz(2),[],x_sz(3) + 1);
    y = reshape(sum(Y,2), x_sz(1)*x_sz(2),x_sz(3) + 1);
    
    % weights (i.e. # occurences of each pel in the patches) is last
    % channel
    w = y(:,end);
    % pixel values
    y = y(:,1:end-1);
    
    % a nuance, only re-average non zero weights
    nz = w~=0;
    x = reshape(x,x_sz(1)*x_sz(2),x_sz(3));
    % average
    x(nz,:) = bsxfun(@rdivide, y(nz,:), w(nz));
    x = reshape(x,x_sz0);
    
  case 'der' %derivative, i.e. transpose patchification
    
    Y = zeros( x_sz(1)*x_sz(2)*patchsize^2, x_sz(3), 'like', X);
    Y(X_lin_inds(:),:) = X; %todo: slice this indexing struct along 1st dim for memory
    Y = reshape(Y,x_sz(1)*x_sz(2),[],x_sz(3));
    x = reshape(sum(Y,2), x_sz0);
  
  case 'weighted'
    %TODO: provide convex weights
    
  otherwise
    error('unknown mode');
end

end