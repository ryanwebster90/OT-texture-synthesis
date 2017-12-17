function P = nn_search(Y,X,varargin)
% A memory sliced nearest neighbor search from rows of Y->X, i.e. every row
% of Y has a match in X. P is a matrix of indices such that Y* = X(P(:),:).
%
% P = nn_search(Y,X,'M',1e6);
% Performs nearest neighbor search with memoy parameter of 1e6. The memory
% parameter decides the maximum sliced matrix multiplcation that occurs, of
% the form Y*X_I.', where Y is (N x B) X_I (M x B).
%
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.

opts.M = 5e7; % memory parameter
opts = vl_argparse(opts,varargin);

M = opts.M;
m = floor(M/size(X,1));
K = ceil(size(X,1)/m);

P = zeros(size(X,1),1,'like',X);
X = [ X , -1/2 * sum( X.^2 ,2) , ones( size(X,1) , 1, 'like', X ) ];
Y = (-2)*[ Y , ones( size(Y,1) , 1 , 'like', Y ) , -1/2 * sum( Y.^2,2)];
%compute sliced NN indices
for k = 1:K
  inds = (k-1)*m+1:min(k*m,size(X,1));
  
  C = Y(inds,:)*X.';
  [~,P(inds)] = min(C,[],2);
end
