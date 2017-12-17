function P = sinkhorn_perm_low_mem(Y,X,varargin) 
% Estimates a permutation from the rows of Y -> X using entropic optimal
% transport. I.e. Y* = X(P(:),:) where P is approximately a permutation.
% This is accomplished by solving an entropy regularized optimal transport
% problem with the following objective:
% D* = arg min { sum(C .* D(:)) + epsilon* h(D)}
% The solution is computed using a sliced Sinkhorn-Knopp algorithm and then
% a greedy algorithm which finds a permutation to minimize P.*D. 
% For more details, see section 2.2, algorithms 2 and 3. 
%
% P = sinkhorn_perm_low_mem(Y,X,'M',5e7,'epsilon',1e-3) 
% Estimates a permutation using an entropic regularization of 1e-3 and a
% memory parameter of 5e7. 
%
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.


opts.memory = 3e7; % Memory param on larget sliced matrix mult.
opts.epsilon = 1e-3; % entropic reg. for OT
opts.N_iter = 12; % number of iterations to try and reach permutation
opts.match_cardinality_tol = .99;  % Match cardinality when this algorithm stops
opts = vl_argparse(opts,varargin);

M = opts.memory;
P = ones(size(Y,1),1,'like',Y);
col_inds = (1:size(Y,1))'; % unmatched patches
row_inds = (1:size(Y,1))'; % unmatched patches
if isa(Y,'gpuArray'); 
  col_inds = gpuArray(col_inds);
  row_inds = gpuArray(row_inds);
end

% Write norm stacked versions of X and Y for euclidean distance as matrix
% multiplication
Y = [ Y , -1/2 * sum( Y.^2 ,2) , ones( size(Y,1) , 1 , 'like', Y ) ] ;
X = (-2)*[ X , ones( size(X,1) , 1 , 'like', X ) , -1/2 * sum( X.^2, 2 )  ];

for iter = 1:opts.N_iter
  
  % recompute sliced memory
  slice_size = floor(M/size(Y,1));
  num_slices = ceil(size(Y,1)/slice_size);
  a = ones(size(Y,1),1,'like',Y);
  b = ones(size(Y,1),1,'like',Y);
  
  %compute sliced row scaling of C
  for slice = 1:num_slices
    %indices of slice
    row_slice = (slice-1)*slice_size+1:min(slice*slice_size,size(Y,1));
    
    % compute slice of K = exp(-C/epsilon)
    K_slice = Y*X(row_slice,:).';
    K_slice = K_slice/(size(X,2)-2);
    K_slice = exp(-K_slice/opts.epsilon);
    
    % a nuance of this algorithm, is that a single iteration of SK is run
    % and a sub perm is selected and removed from the transport plan. So SK
    % must start over at each iterate. I.e. b = ones
    a(row_slice) = 1./sum(K_slice,1);
  end
  
  M_vals = zeros(size(Y,1),1,'like',Y);
  M_rows = zeros(size(Y,1),1,'like',Y);
  
  %compute sliced col scaling of C
  for slice = 1:num_slices
    col_slice = (slice-1)*slice_size+1:min(slice*slice_size,size(X,1));
   
     % compute slice of K = exp(-C/epsilon)
    K_slice = X*Y(col_slice,:).'; % K is implicitly transposed here for efficiency
    K_slice = K_slice/(size(X,2)-2);
    K_slice = exp(-K_slice/opts.epsilon);
    
    % scale rows of K
    K_slice = bsxfun(@times,K_slice,a);
    
    % At max iterations, just return current match
    if iter == opts.N_iter 
      % no need to scale with b, max along cols is invariant to scaling cols
      [~,row_perm] = max(K_slice,[],1);
      
      % return approx. perm for this slice
      P(col_inds(col_slice)) = row_inds(row_perm);
      
    else
      %scale cols of K
      b(col_slice) = 1./sum(K_slice,1); 
      K_slice = bsxfun(@times,K_slice,b(col_slice)'); %scale slice (for permutation selection)
      
      % greedy max along cols
      [M_vals(col_slice),M_rows(col_slice)] = max(K_slice,[],1);
    end
    
  end
  
  if iter < opts.N_iter
    
    tmp = unique(M_rows);
    
    % resolve non-unique indices, by only taking matches that are ma along
    % rows and columns
    S = sparse(double(gather(M_rows)),1:numel(col_inds),double(gather(M_vals)),numel(col_inds),numel(col_inds)) ;
    [col_max,col_perm] = max(S,[],2); 
    col_max = full(col_max);
    
    % throw out results of numerical instability (Inf and 0's)
    assigned_cols = false(size(col_inds));
    col_perm = col_perm(tmp); 
    col_max = col_max(tmp);
    nd = col_max~=0 & col_max~=Inf;
    col_perm = col_perm(nd);
    
    % determine indices of sub permutation
    assigned_cols(col_perm) = true;
    M_rows = M_rows(assigned_cols);
    P(col_inds(assigned_cols)) = row_inds(M_rows); % absorb into greater perm

    % update active row/cols
    col_inds = col_inds(~assigned_cols); % only keep un assigned cols
    unassigned_rows = true(size(row_inds));
    unassigned_rows(M_rows) = false;
    row_inds = row_inds(unassigned_rows);
    
    % discard patches already matched
    Y = Y(~assigned_cols,:);
    X = X(unassigned_rows,:);
    
    % determine current match cardinality via remaining unmatched cols
    curr_match_cardinality = 1-numel(col_inds)/numel(P);
%     fprintf('current match cardinality  = %f, iter = %d\n',curr_match_cardinality,iter);
    
  end
  
  % check if an approx perm is reached
  if ~numel(col_inds) || ( iter > 2 && (curr_match_cardinality > opts.match_cardinality_tol))
    break;
  end
  
end