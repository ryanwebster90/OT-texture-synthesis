function [e,gamma] = sinkhorn(C,varargin)
% See "Sinkhorn distances: Lightspeed Computation of Optimal Transport
% Distances", Marco Cuturi, 2013.
opts.epsilon = 1e-3;
opts.N_iter = 2;
opts = vl_argparse(opts,varargin);

b = ones(size(C,2),1,'like',C);
gamma = exp(-C/opts.epsilon);

for iter = 1:opts.N_iter
  a = 1./(gamma*b);
  b = (1./(a.'*gamma)).';
end

gamma = bsxfun(@times,gamma,(a*(b.')));
e = 0;




