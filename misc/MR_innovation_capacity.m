function [mr_ic,copy_maps,innovation_capacities] = MR_innovation_capacity(x,y,patchsize,N_scales)
% computes a nearest neighbor matching between patches of x and y. Then
% determines what percentage of locations were verbatim copied, over
% multiple resolutions. copy_maps contains visualizations of the copy maps
% over every resolution, innovation_capacities contains the percentage of
% verbatim copies, mr_ic contains the average.
%
% Copyright (C) 2017 Ryan Webster
% All rights reserved.
%
% This file is made available under the terms of the MIT license.

copy_maps = {};
innovation_capacities = [];
for scale = 1:N_scales
  xs = resize_image_2D(x, 1/2^(N_scales - scale));
  ys = resize_image_2D(y, 1/2^(N_scales - scale));
  [copy_map,P] = get_tiling(ys,xs,patchsize);
  innovation_capacities(scale) = innovation_capacity(size(ys),P);
  copy_maps{scale} = copy_map;
end
mr_ic = mean(innovation_capacities);