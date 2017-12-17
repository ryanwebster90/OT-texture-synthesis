function P = sparse_sinkhorn_perm(K,varargin)
% Estimates a permutation given a sparse gibbs kernel K = exp(-C/epsilon),
% where K is sparse, by greedily selecting column maximums, resolving by
% taking maximums along rows and then removing matched columns. See
% Algorithm 2 or sinkhorn_perm_low_mem for more details. Currently unused.
%
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.
opts.epsilon = 1e-3;
opts.N_iter = 12;
opts = vl_argparse(opts,varargin);

% K = spfun(@exp,-K/opts.epsilon);
P = zeros(size(K,1),1);
col_inds = (1:size(K,1))'; % current set of active cols
row_inds = (1:size(K,1))'; % current set of active rows
for iter = 1:opts.N_iter
  size(K)
  a = sparse(1:size(K,1),1:size(K,2),1./sum(K,2)); %sparse diagonal scaling
  
  if iter == opts.N_iter % a permutation or max iter has been reached
    [~,row_perm] = max(a*K,[],1);
    % return approx. perm
    P(col_inds) = row_inds(row_perm);
    
  else
    b = sparse(1:size(K,1),1:size(K,2),1./sum(a*K,1)); %sparse diagonal scaling
    [row_max,row_perm] = max(a*K*b,[],1);
    
    tmp = unique(row_perm);
    
    % find indices which are max on row and columns
    R = sparse(double(gather(row_perm)),1:numel(col_inds),double(gather(row_max)),numel(col_inds),numel(col_inds)) ;
    [col_max,col_perm] = max(R,[],2); 
    col_max = full(col_max);
    
    col_perm = col_perm(tmp); 
    col_max = col_max(tmp);
    nd = col_max~=0 & col_max~=Inf;
    fprintf('num degenerate max = %d\n',nnz(~nd));
    col_perm = col_perm(nd); % throw out results of numerical instability
    
    assigned_cols = false(size(col_inds));
    assigned_cols(col_perm) = true;
    row_perm = row_perm(assigned_cols);
    P(col_inds(assigned_cols)) = row_inds(row_perm); % absorb into greater perm

    %update active row/cols
    col_inds = col_inds(~assigned_cols); % only keep un assigned cols
    unassigned_rows = true(size(row_inds));
    unassigned_rows(row_perm) = false;
    row_inds = row_inds(unassigned_rows);
    
    K = K(unassigned_rows,~assigned_cols);
    
  end
  
  fprintf('Sparse sinkhorn percent perm  = %f, iter = %d\n',numel(unique(P))/numel(P),iter);
  
  if ~numel(col_inds)
    break;
  end
end
