function [y,P] = MRF_synthesis(x0,varargin)
% Non-parametric texture synthesis. Iteratively takes patches of x0 and
% current synthesis y, matches them according to a heuristic and then
% re-averages the row stacked patch matrix Y back into the image domain.
%
% y = MRF_synthesis(x0,'match_heuristic','OT','epsilon',1e-3,'patchsize',5);
% synthesizes y with the OT heuristic
%
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.


% synthesis options
opts.N_iter = 16; % num iter at each scale
opts.N_scales = 5; % number of resolutions for synthesis
opts.patchsize = 4;
opts.dataratio = .35; % percentage of patches randomly sampled
opts.match_heuristic = 'OT'; % can be nearest neighbor 'NN', optimal transport 'OT' or bidirectional similarity 'BS'
opts.epsilon = 1e-3; % entropic regularization for OT
opts.bs_alpha = .5; % convex combination of x and y's matching choice for BS
opts.new_figure = false;
opts.display = true;
opts.y0 = [];
opts = vl_argparse(opts,varargin);


isgpu = isa(x0,'gpuArray');
if isgpu;gd = gpuDevice;end;

if opts.new_figure
  figure;
end

t0 = tic;
% run synthesis over pyramid with N_scales
for scale = 1:opts.N_scales
  
  % x0 at current resolution
  x = resize_image_2D(x0, 1/2^(opts.N_scales-scale));
  
  if scale >1
    y = resize_image_2D(y,size(x));
  else
    if ~numel(opts.y0)
      y = cast(rand(size(x)),'like',x);
    else
      y = opts.y0;
      y = resize_image_2D(y,size(x));
    end
  end
  
  for iter = 1:opts.N_iter
    
    switch opts.match_heuristic
      case 'OT' % entropic optimal transport
        %patchify
        [Y,Y_patch_inds] = im2row_patch_sample_2D(y,opts.patchsize,opts.dataratio);
        X = im2row_patch_sample_2D(x,opts.patchsize,opts.dataratio);
        
        % estimate a permutation between X and Y using entropic OT
        P = sinkhorn_perm_low_mem(Y,X,'epsilon',opts.epsilon);
        
        % assign patches in Y
        Y = X(P(:),:);
        
        % re average into image domain
        y = row2im_patch_sample_2D(y,Y,Y_patch_inds);
        
      case 'BS' %bidirectional similarity
        % patchify
        [Y,Y_patch_inds] = im2row_patch_sample_2D(y,opts.patchsize,opts.dataratio);
        [X,X_patch_inds] = im2row_patch_sample_2D(x,opts.patchsize,opts.dataratio);
        
        % perform NN search from Y->X and X->Y
        P = nn_search(Y,X);
        P2 = nn_search(X,Y);
        
        % multiple rows in X may map to a single row in Y
        % this block of code averages these mappings,
        % then subsamples Y in the case of unmatched rows in Y
        S = sparse(double(gather(P2)),1:numel(P2),1);
        b = sum(S,2);
        m = b~=0; % selected patches
        S = S(m,:); % delete unselected patches
        Y2 = S*double(gather(X)); % perform sum and assignment
        b = b(m);
        Y2 = bsxfun(@rdivide,Y2,b); % average
        Y2_patch_inds = Y_patch_inds(m,:); % delete unselected patches
        Y2 = cast(Y2,'like',X);
        
        tmp  = zeros(size(y),'like',y);
        
        % re average both updates into image domain
        xy = row2im_patch_sample_2D(tmp,Y2,Y2_patch_inds);
        yx = row2im_patch_sample_2D(y,X(P(:),:),Y_patch_inds);
        
        m = xy(:)==0; % unmapped image regions of X->Y
        
        % convex comb. according to bs_alpha
        y = opts.bs_alpha*yx + (1-opts.bs_alpha)*xy;
        
        y(m) = yx(m); % take unmapped regions from yx.
        
      case 'NN' %nearest neighbor
        [Y,Y_patch_inds] = im2row_patch_sample_2D(y,opts.patchsize,opts.dataratio);
        [X,X_patch_inds] = im2row_patch_sample_2D(x,opts.patchsize,opts.dataratio);
        P = nn_search(Y,X);
        y = row2im_patch_sample_2D(y,X(P(:),:),Y_patch_inds);
        
      otherwise
        error('unkown MRF constraint');
    end
    
    if opts.display
      imshow(y);
      title(['synthesis iter: ',num2str(iter),...
        ' synthesis scale: ',num2str( 1/2^(opts.N_scales-scale))])
      drawnow
    end
  end
  
end
if isa(x0,'gpuArray');wait(gd);end;
disp(['Algorithm time: ',num2str(toc(t0))]);