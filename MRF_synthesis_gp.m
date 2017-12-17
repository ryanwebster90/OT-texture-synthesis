function [y,P] = MRF_synthesis_gp(x0,varargin)
% Non-parametric texture synthesis. See MRF_synthesis.m
% Additionally, low resolutions are re synthesized every iteration
% and re-averaged with the current synthesis, to prevent lower resolutions
% from drifting which is sometimes the case with small patch sizes or
% data ratios.
%
% y = MRF_synthesis(x0,'match_heuristic','OT','alpha',.9);
% synthesizes y with the OT heuristic, re-averaging low resolutions with
% 'alpha' like y = alpha*y + (1-alpha)*y_l where y_l is lower resolution.
%
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.



% MRF options
opts.N_iter = 16; % number of iterations at each scale
opts.N_scales = 5; % number of resolutions
opts.patchsize = 4;
opts.alpha = .85; % convex comb. with previous resolution
opts.dataratio = .35; % percentage of patches randomly sampled
opts.match_heuristic = 'OT'; % can be nearest neighbor 'NN', optimal transport 'OT' or bidirectional similarity 'BS'
opts.epsilon = 1e-3; % entropic regularization for OT
opts.new_figure = false;
opts.display = true;
opts.bs_alpha = .5; % convex combination of x and y's matching choice for BS
opts = vl_argparse(opts,varargin);


isgpu = isa(x0,'gpuArray');
if isgpu;gd = gpuDevice;end;

if opts.new_figure
  figure
end
t0 = tic;

%precomp all resolutions of x0
x_gp = {};
for scale = 1:opts.N_scales
  x_gp{scale} = resize_image_2D(x0, 1/2^(opts.N_scales-scale));
end

% run synthesis over pyramid with N_scales
for scale = 1:opts.N_scales
  x = resize_image_2D(x0, 1/2^(opts.N_scales-scale));
  
  if scale > 1
    y = resize_image_2D(y,size(x));
  else
    y = rand(size(x));
    y = cast(y,'like',x);
  end
  
  for iter = 1:opts.N_iter
    
    % re-iterate over previous resolutions
    for s2 = 1:scale
      xs = x_gp{s2};
      if s2>1
        % resize synth of last scale
        ys_prev = resize_image_2D(ys,size(xs));
        
      end
      
      % resize current synthesis
      ys = resize_image_2D(y, 1/2^(scale-s2));
      
      if strcmp(opts.match_heuristic,'OT');% entropic optimal transport
        %patchify
        [Y,Y_patch_inds] = im2row_patch_sample_2D(ys,opts.patchsize,opts.dataratio);
        [X,X_patch_inds] = im2row_patch_sample_2D(xs,opts.patchsize,opts.dataratio);
        
        % estimate a permutation between X and Y using entropic OT
        P = sinkhorn_perm_low_mem(Y,X,'epsilon',opts.epsilon);
        
        % assign patches in Y
        Y = X(P(:),:);
        
        % re average into image domain
        ys = row2im_patch_sample_2D(ys,Y,Y_patch_inds);
        
      elseif strcmp(opts.match_heuristic,'BS'); %bidirectional similarity
        % patchify
        [Y,Y_patch_inds] = im2row_patch_sample_2D(ys,opts.patchsize,opts.dataratio);
        [X,X_patch_inds] = im2row_patch_sample_2D(xs,opts.patchsize,opts.dataratio);
        
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
        
        % re average both updates into image domain
        xy = row2im_patch_sample_2D(ys,Y2,Y2_patch_inds);
        yx = row2im_patch_sample_2D(ys,X(P(:),:),Y_patch_inds);
        
        % convex comb. according to bs_alpha
        ys = opts.bs_alpha*yx + (1-opts.bs_alpha)*xy;
      end
      
      %re-average with previous resolution
      if s2>1
        ys = opts.alpha*ys + (1-opts.alpha)*ys_prev;
      end

      
    end
    
    if opts.display
      y = ys;
      imshow(y);
      title(['synthesis iter: ',num2str(iter),...
        ' synthesis scale: ',num2str( 1/2^(opts.N_scales-s2))])
    
    end
    
  end
  
end

if isa(x0,'gpuArray');wait(gd);end;
disp(['Algorithm time: ',num2str(toc(t0))]);