function P = sinkhorn_perm(C,varargin)
% Estimates a permutation from the rows of Y -> X using entropic optimal
% transport. Non-sliced version of sinkhorn_perm_low_mem.
% For more details, see section 2.2, algorithms 2 and 3. Currently unused.
%
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.



opts.epsilon = 1e-3;
opts.N_iter = 12;
opts.perm_ratio = .9;
opts = vl_argparse(opts,varargin);

K = exp(-C/opts.epsilon);
P = zeros(size(C,1),1,'like',C);
col_inds = (1:size(C,1))'; % current set of active cols
row_inds = (1:size(C,1))'; % current set of active rows
for iter = 1:opts.N_iter
  gamma = bsxfun(@rdivide,K,sum(K,2));
  
  if iter == opts.N_iter
    [row_max,row_perm] = max(gamma,[],1);
    % return approx. perm
    P(col_inds) = row_inds(row_perm);
    
  else
    gamma = bsxfun(@rdivide,gamma,sum(gamma,1)); %scale gamma along cols
    [row_max,row_perm] = max(gamma,[],1);
    
    tmp = unique(row_perm);
    
    % find indices which are max on row and columns
    S = sparse(double(gather(row_perm)),1:numel(col_inds),double(gather(row_max)),numel(col_inds),numel(col_inds));
    [col_max,col_perm] = max(S,[],2); 
    col_max = full(col_max);
    
    assigned_cols = false(size(col_inds));
    col_perm = col_perm(tmp); 
    col_max = col_max(tmp);
    nd = col_max~=0 & col_max~=Inf;
    fprintf('num degenerate max = %d\n',nnz(~nd));
    col_perm = col_perm(nd); % throw out results of numerical instability
    
    assigned_cols(col_perm) = true;
    row_perm = row_perm(assigned_cols);
    P(col_inds(assigned_cols)) = row_inds(row_perm); % absorb into greater perm

    %update active row/cols
    col_inds = col_inds(~assigned_cols); % only keep un assigned cols
    unassigned_rows = true(size(row_inds));
    unassigned_rows(row_perm) = false;
    row_inds = row_inds(unassigned_rows);
    
    K = K(unassigned_rows,~assigned_cols);
    
    % display progress
    fprintf('percentage inds remaining: %f\n',nnz(col_inds)/size(C,1));
  end
  
  if ~numel(col_inds)
    break;
  end
  
end
