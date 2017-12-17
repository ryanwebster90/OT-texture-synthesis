% Batch texture synthesis, comparing the OT and BS non-parametric methods
% and the random convolution statistical method, as well as their
% respective innovation capacities.
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.

N_scales =5;
N_iter = 16;
rand_seed = 13;

cnn_N_scales = 5; 
cnn_N_iter = 500; % LBFGS optimization iterations
cnn_N_filters = 2^8; % less filters tends to be implausible, more will converge on a circshift or run out of memory

patchsize = 4;
tile_patchsize = 6;
dataratio = .35;
scale = [480,640];
% scale = 1;

bs_alpha = .25;
epsilon = 1e-3;

methods = {'BS','OT','CNN'};

files = {'bones2.jpg','art_arabic.jpg','black_sand.jpg'};
% files = {'wrinkled_rust.png','melted_rocks.png','oil.png','twine.png','tumeric.png','lichen_lava.png',...
%   'red_lichen.png','bolts.png','erosion.png','carved.png','tarps.png','rusty_wall.png','packaged_candy.png','mud2.png'...
%   'green_onions.png','canvas.png'};


% change to desired output directory
test_name = '';
out_dir = ['./figures/figure 3/','ps',num2str(patchsize),'_ns',num2str(N_scales),'_rs',num2str(rand_seed),test_name,'/'];
mkdir(out_dir);

mkdir(out_dir);

for f1 = 1:numel(files)
  for mh = 1:numel(methods)
    x0 = single(imread(files{f1}))/255;
    x0 = resize_image_2D(x0,scale);
    x0 = Spectrum.periodic(x0);
    
    disp(['synthesizing ', files{f1}])
    
    x0 = gpuArray(x0);
    rng(rand_seed);
    if mh < 3
      
%       [y,P] = MRF_synthesis(x0,'match_heuristic',methods{mh},'N_scales',N_scales,'epsilon',epsilon,...
%         'N_iter',N_iter,'patchsize',patchsize,'dataratio',dataratio,'new_figure',false,'bs_alpha',bs_alpha);

      [y,P] = MRF_synthesis_gp(x0,'match_heuristic',methods{mh},'N_scales',N_scales,'disp',1,'new_figure',false,...
    'N_iter',N_iter,'patchsize',patchsize,'dataratio',dataratio,'epsilon',epsilon,'bs_alpha',bs_alpha,'alpha',.85);
      
      ic_N_scales = 4;
      [mr_ic,copy_maps,innovation_capacities] = MR_innovation_capacity(x0,y,tile_patchsize,ic_N_scales);
      
      fn_out = [out_dir,files{f1}(1:end-4),'_',methods{mh},'_ic',sprintf('%.2f ',innovation_capacities),'_avg',...
        sprintf('%.2f ',mr_ic),'.jpg'];
      imwrite(gather(y),fn_out,'Quality',100);
      
    else % CNN gram synthesis
      
      y = randn_relu_gram_synthesis(x0,'N_iter',cnn_N_iter,'N_scales',cnn_N_scales,'N_filters',2^8);

      ic_N_scales = 4;
      [mr_ic,copy_maps,innovation_capacities] = MR_innovation_capacity(x0,y,tile_patchsize,ic_N_scales);
      
      fn_out = [out_dir,files{f1}(1:end-4),'_CNN','_ic',sprintf('%.2f ',innovation_capacities),'_avg',...
        sprintf('%.2f ',mr_ic),'.jpg'];
      imwrite(gather(y),fn_out,'Quality',100);
      
    end
  end
  
end

