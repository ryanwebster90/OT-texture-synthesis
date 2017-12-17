% Demonstrates the necessity of small epsilon for synthesis with small
% patch size.
%
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.


N_scales = 5;
N_iter = 16;
rand_seed = 25;

patchsize = 4;
dataratio = .35;
scale = 1;
% scale = [256,256];

match_heuristics = {'OT'};

% epsilons = [1e-1,1e-2,1e-3]; %1e-1 is extremely slow, beware
epsilons = [1e-3,1e-2];

% input files
files = {'wrinkled_rust.png','red_lichen.png'};

% change to desired output directory
test_name = '';
out_dir = ['./figures/figure 1/','ps',num2str(patchsize),'_ns',num2str(N_scales),'_rs',num2str(rand_seed),test_name,'/'];
mkdir(out_dir);


for ei = 1:numel(epsilons)
  mc = 0;
  for f1 = 1:numel(files)
    
    x0 = single(imread(files{f1}))/255;
    x0 = resize_image_2D(x0,scale);
    x0 = Spectrum.periodic(x0);
    
    disp(['synthesizing ', files{f1}])
    
    x0 = gpuArray(x0);
    rng(rand_seed);
    
    
    % [y,P] = MRF_synthesis(x0,'match_heuristic','OT','N_scales',N_scales,'alpha',.85,...
    %  'N_iter',N_iter,'patchsize',patchsize,'dataratio',dataratio,'epsilon',epsilons(ei),'new_figure',false);
    
    [y,P] = MRF_synthesis_gp(x0,'match_heuristic','OT','N_scales',N_scales,'alpha',.85,...
      'N_iter',N_iter,'patchsize',patchsize,'dataratio',dataratio,'epsilon',epsilons(ei),'new_figure',false);
    
    mc = numel(unique(P))/numel(P);
    
    fn_out =[out_dir,files{f1}(1:end-4),'_OT_eps',num2str(epsilons(ei)),'_mc',sprintf('%.3f',mc),'.jpg'];
    imwrite(gather(y),fn_out,'Quality',100);
    
  end
  
end

