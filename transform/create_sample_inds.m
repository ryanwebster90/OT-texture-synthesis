function sample_inds = create_sample_inds(x_sz,dataratio)
% Returns sorted linear indices from a 2D grid sized x_sz.
% Dataratio specifies the percentage of indices taken, with
% dataratio = 1 taking every location (i.e. (1:x_sz(1)*x_sz(2))').
%
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.

if dataratio == 1;
  sample_inds = (1:x_sz(1)*x_sz(2))';
else
  x_sz = x_sz(1:2);
  %create grid of linear inds
  lin_inds = reshape(1:x_sz(1)*x_sz(2),x_sz);
  
  % take num_inds from a permutation of size x_sz(1)*x_sz(2)
  num_inds = floor(numel(lin_inds)*dataratio);
  sample_inds = randperm(numel(lin_inds),num_inds);
  
  % sort and vectorize
  sample_inds = sort(lin_inds(sample_inds)).';
end

