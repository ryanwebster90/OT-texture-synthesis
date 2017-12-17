% Demonstrates that the non-parametric OT algorithm can produce novel
% images with a small patch size.
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.

fn = 'lichen_lava.png';

x0 = single(imread(fn))/255;
scale = 1;
x0 = resize_image_2D(x0,scale);
x0 = Spectrum.periodic(x0);
x0 = gpuArray(x0);

N_scales = 5;
N_iter  = 16;
patchsize = 4;
dataratio = .35;
method = 'OT';
% try BS method as well
% method = 'BS'; 
rand_seed = 25;

 % a slightly larger tile patch size is less prone to noise
tile_patchsize = 6;
epsilon = 1e-3;
bs_alpha = .25;

rng(rand_seed);
 
[y,P] = MRF_synthesis_gp(x0,'match_heuristic',method,'N_scales',N_scales,'disp',1,...
    'N_iter',N_iter,'patchsize',patchsize,'dataratio',dataratio,'epsilon',epsilon,'bs_alpha',bs_alpha,'alpha',.85);

ic_N_scales = 4;
[mr_ic,copy_maps,innovation_capacities] = MR_innovation_capacity(x0,y,tile_patchsize,ic_N_scales);
title(num2str(innovation_capacities))

% change to desired output directory
test_name = '';
out_dir = ['./figures/figure 2/','ps',num2str(patchsize),'_ns',num2str(N_scales),'_rs',num2str(rand_seed),test_name,'/'];
mkdir(out_dir);

imwrite(gather(y),[out_dir,fn,sprintf('%.2f ',innovation_capacities),'_avg',sprintf('%.2f ',mr_ic),'.jpg'],'Quality',100);
cm = copy_maps{end};
imwrite(cm,[out_dir,fn,sprintf('%.2f ',innovation_capacities),'_avg',sprintf('%.2f ',mr_ic),'_copymap.jpg'],'Quality',100);

  