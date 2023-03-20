function  N = segmentNuclei(imgIn, minNucleus, minSolidity, t1, t2, minArea, d)
% imgIn = 
% minNucleus = 
% minSolidity = 
% t1 =
% t2 = 
% minArea = 
% d = 
% N = output nuclei mask

% this function implements the nucleus segmentation algorithm from the
% paper "A framework for nucleus and overlapping cytoplasm..."
% Miguel Manguerra and Kimiya Mousavi

% Reading image
imageSample = imread(imgIn);

% Converting image to grayscale
imageSample = im2gray(imageSample);

% weiner2 implements 2D adaptive noise removal filtering
filteredImage = wiener2(imageSample, [3,3]);

% Display the original image, noisy image, and filtered image
figure;
subplot(1,2,1);
imshow(imageSample, []);
title('Original');
subplot(1,2,2);
imshow(filteredImage, []);
title('Filtered');

% function N = nucleus_segmentation(EDF_image, m, s, t1, t2, d)
%     % Initialization
%     N = zeros(size(EDF_image));
%     I = wiener2(EDF_image);
% 
%     % Iterative detection and segmentation
%     for t = t1:10:t2
%         B = I <= t;
%         CC = bwconncomp(B);
%         stats = regionprops(CC, 'Area', 'Solidity', 'Image');
% 
%         for i = 1:length(stats)
%             r = stats(i);
%             r_size = r.Area;
%             r_solidity = r.Solidity;
%             r_mask = zeros(size(B));
%             r_mask(CC.PixelIdxList{i}) = 1;
% 
%             if r_size < m || r_solidity < s
%                 % Remove r
%                 B(CC.PixelIdxList{i}) = 0;
%             else
%                 overlap_mask = r_mask & N;
%                 if sum(overlap_mask(:)) == 0
%                     N = N | r_mask;
%                 else
%                     overlap_stats = regionprops(overlap_mask, 'Solidity');
%                     max_overlap_solidity = max([overlap_stats.Solidity]);
% 
%                     if r_solidity >= max_overlap_solidity
%                         N = N | r_mask;
%                     end
%                 end
%             end
%         end
%     end
% 
%     % Post-processing
%     N = imdilate(N, strel('disk', 1));
%     CC = bwconncomp(N);
%     stats = regionprops(CC, EDF_image, 'PixelValues', 'Perimeter', 'PixelList');
% 
%     for i = 1:length(stats)
%         r = stats(i);
%         r_intensity = mean(r.PixelValues);
%         outer_boundary = bwperim(r.Perimeter);
%         outer_boundary_intensity = mean(EDF_image(sub2ind(size(EDF_image), outer_boundary(:, 2), outer_boundary(:, 1))));
% 
%         if r_intensity - outer_boundary_intensity < d
%             N(CC.PixelIdxList{i}) = 0;
%         end
%     end
% end