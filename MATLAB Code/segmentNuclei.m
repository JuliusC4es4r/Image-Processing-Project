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