function y = randn_relu_gram_synthesis(x0,varargin)
% Minimizes the gram loss between a synthesis y and x0. The gram matrix is
% computed over random convolutions followed by a linear rectified unit.
% See Algorithm 5. Optimization is performed at increasing resolutions.
%
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.

opts.N_iter = 500; % number of LBFGS steps
opts.N_scales = 5; %number of resolutions
opts.display = 1; 
opts.N_filters = 2^8; % number of filters in random convolution filter bank
opts.new_figure = false; %create new figure
opts = vl_argparse(opts, varargin);

state.stochastic = 0;
state.M = 100; % number of gradients in LBFGS used to estimate hessian
state.lr = 1e-1; % "learning rate" for LBFGS, helps dampen isntability at inital optim
if opts.display
  show_int = 5;
else
  show_int = opts.N_iter +1;
end

if opts.new_figure
  figure
end

fprintf('%10s %15s \n','Iteration','Function Val');

% Define network using the automatic differentiation library autonn
x = Input(); 
f_size  = 5; %filter size
w1 = 1e-1*gpuArray(single(randn(f_size,f_size,3,opts.N_filters))); %random filter bank
% c1 = vl_nnconv(x,w1,[]); faster if you have cudNN with MatConvNet
% convolution in native MATLAB using patchifying operator + matrix mult
c1 = const_conv_periodic(x,w1); 
r1 = vl_nnrelu(c1); %rectified linear unti
yg =gram_layer(r1); % gram matrix
loss_fn = @(x,y) sum( (x(:)-y(:)).^2); % loss
net = Net(yg,'conserveMemory',[true true]);




for scale = 1:opts.N_scales
  x = resize_image_2D(x0, 1/2^(opts.N_scales-scale));
  if scale == 1
    y = std(x(:))*randn(size(x),'like',x);
  else
    y = resize_image_2D(y,size(x));
  end
  state.x = y(:);
  state.t = 0;
  
  loss_net = create_constraint_loss_net(net,x,yg,loss_fn); % redefine network loss with new gram matrix of x
  funobj = @(y) feval(@loss_net_fn_obj,y,size(x),loss_net); % objective function for LBFGS

  while state.t < opts.N_iter
    state = LBFGS_optim(funobj,state);
    fprintf('%10d %15.5e \n',state.t,state.loss_history(state.t-1));
    if ~mod(state.t,show_int)
      % state.x is current synthesis
      imshow(reshape(state.x,size(y)));
      drawnow;
    end
  end
  
  y = reshape(state.x,size(y));
  
end
