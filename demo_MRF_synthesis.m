x0 = single(imread('lichen_lava.png'))/255;
s = 1; % scale
% s = [480,640];
x0 = resize_image_2D(x0,s);
x0 = Spectrum.periodic(x0); % a nuance, periodize image for periodic patches
x0 = gpuArray(x0);

N_scales = 5;
N_iter  = 16;
patchsize = 4;
dataratio = .35;
match_heuristic = 'BS';
% match_heuristic = 'OT';
% match_heuristic = 'NN';
epsilon = 1e-3;
bs_alpha = .25;


rng(7);

% [y,P] = MRF_synthesis(x0,'match_heuristic',match_heuristic,'N_scales',N_scales,...
%    'N_iter',N_iter,'patchsize',patchsize,'dataratio',dataratio,'epsilon',epsilon,'bs_alpha',bs_alpha);

% synthesize with lower resolution re-averaging. helps small patch sizes
% slightly
[y,P] = MRF_synthesis_gp(x0,'match_heuristic',match_heuristic,'N_scales',N_scales,...
    'N_iter',N_iter,'patchsize',patchsize,'dataratio',dataratio,'epsilon',epsilon,'bs_alpha',bs_alpha,'alpha',.85);

  
% random convolution gram loss synthesis
% y = randn_relu_gram_synthesis(x0,'N_filters',2^8,'N_scales',5,'N_iter',250);
  
  
