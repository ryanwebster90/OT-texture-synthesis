function loss_net = create_constraint_loss_net(net,x,loss_vars,loss_fn)
% Passes x through network x, then saves its value at the loss function. In
% autonn, this will be saved as a constant argument in the layer inputs.
% 
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.


if ~iscell(loss_vars)
    loss_vars = {loss_vars};
end
tmp = fieldnames(net.inputs);
input_var = tmp{1};

net.eval({input_var,x},'forward');
yl = {};
for v = 1:numel(loss_vars)
    tmp = net.getValue(loss_vars{v}.name);
    yl{v} = loss_fn(loss_vars{v},tmp);
end

if numel(yl)>1
loss = vl_nnwsum(yl{:},'weights',ones(numel(yl),1));
else
    loss = yl{1};
end
loss.name = 'loss';
loss_net = Net(loss);
    
    