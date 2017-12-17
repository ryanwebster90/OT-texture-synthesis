function state = LBFGS_optim(funObj,state)
% L-BFGS optimization method, see minFunc by Mark Schmidt. Notably, the
% wolfe-line along the current gradient was removed. This is because this
% file is used for optimizing a gram loss (see randn_relu_gram_synthesis),
% which can sometimes be unstable. Additionally, this file is state based
% and handles data type conversion better. I.e. state.x can be single
% gpuArrays for fast convolution.
% NOTE:
% I *DO NOT* recommend the general use of this LBFGS optimizer. It is
% purely for convenience and self containment. Use minFunc instead.
%
% See also,
% loss_net_fn_obj, randn_relu_gram_synthesis
%
% 
% Copyright (C) Mark Schmidt, 2005

%save dummy type variable
x0 = state.x(1); 
[f,g] = funObj(state.x);

%gather for two loop recursion
state.x = gather(state.x);
f = cast(f,'like',state.x);
g = cast(g,'like',state.x);

if state.t == 0
  
    default.lr = 1; %learning rate
    default.M = 100; %memory parameter
    default.verbose = 1;
    default.stochastic = 0;
    state = init_state(state,default);
    state.loss_history = [];
    state.t = 1;
end

if state.t ==1
    state.d = -g;
    state.S = [];
    state.Y =[];
    state.YS = [];
else
    y = g - state.g_prev;
    s = state.d;
    ys = y'*s;
    if ys > 1e-10
        [state.S,state.Y,state.YS] = update_vars(state.S,state.Y,state.YS,s,y,ys,state.M);
        state.d = hessian_update(g,state.S,state.Y,state.YS);
    end
end

state.x = state.x + state.lr*state.d;
state.loss_history = cat(1,state.loss_history,f);
state.g_prev = g;

if state.stochastic && mod(state.t, state.M+1) == 0
    state.t = 1;
else
    state.t = state.t+1;
end

%cast to original type
state.x = cast(state.x,'like',x0);

end

function [S,Y,YS] = update_vars(S,Y,YS,s,y,ys,M)

    S = cat(2,s,S);
    S = S(:,1:min(M,size(S,2)));

    Y = cat(2,y,Y);
    Y = Y(:,1:min(M,size(Y,2)));

    YS = cat(1,ys,YS);
    YS = YS(1:min(M,size(Y,2)));

end


function d = hessian_update(g,S,Y,YS)

    % approximation of (inverse hessian)*g
    % using two loop recursion

    Hdiag = YS(1)/(Y(:,1)'*Y(:,1));

    m = size(S,2);
    al = cast(zeros(m,1),'like',S);
    be = cast(zeros(m,1),'like',S);

    d = -g;
    for i = 1:m
        al(i) = (S(:,i)'*d)/YS(i);
        d = d-al(i)*Y(:,i);
    end

    d = Hdiag*d;

    for i = m:-1:1
        be(i) = (Y(:,i)'*d)/YS(i);
        d = d + S(:,i)*(al(i)-be(i));
    end

end

function state = init_state(state,default)

    fn = fieldnames(default);
    for k = 1:numel(fn)
        f = fn{k};
        if ~isfield(state,f)
            state.(f) = default.(f);
        end
    end
end
