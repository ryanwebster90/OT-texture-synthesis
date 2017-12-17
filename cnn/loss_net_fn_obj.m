function [f,g] = loss_net_fn_obj(y,y_sz,loss_net)
% Computes forward and backward pass in autonn, then returns loss and
% derivative as f and g respectively. Used with an optimizer.
%
% See also,
% LBFGS_optim, randn_relu_gram_synthesis
% 
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.

%assumes net has single input and single output named 'loss'
tmp = fieldnames(loss_net.inputs);
input_var = tmp{1};

%run net forward and backward
loss_net.eval({input_var,reshape(y,y_sz)});

f = loss_net.getValue('loss');

%get deriv and vectorize
g = loss_net.getDer(input_var);
g = g(:);
    
