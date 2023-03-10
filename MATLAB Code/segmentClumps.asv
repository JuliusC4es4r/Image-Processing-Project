function  C = segmentClumps(imgIn, minArea, maxIntensity)
% imgIn = 
% minArea = 
% maxIntensity = 
% C = output clump mask

% this function implements the clump segmentation algorithm from the
% paper "A framework for nucleus and overlapping cytoplasm..."
% Miguel Manguerra and Kimiya Mousavi

% Read image
im = imread(imgIn);

% Learn Gaussian Mixture Model
num_components = 2;
options = statset('MaxIter', 1000);
gmmodel = fitgmdist(double(im(:)), num_components, 'Options', options);

% Select threshold
b = gmmodel.mu(1);
threshold = b + sqrt(2*b)*erfinv(0.06);

% Binarize image
im_bin = im2bw(im, threshold/255);

% Perform connected component analysis
cc = bwconncomp(im_bin);
stats = regionprops(cc, 'Area', 'MeanIntensity');

% Filter out small and bright components
min_area = 100; % adjust as needed
max_intensity = gmmodel.mu(2); % adjust as needed
for i = 1:cc.NumObjects
    area = stats(i).Area;
    intensity = stats(i).MeanIntensity;
    if area < min_area || intensity > max_intensity
        im_bin(cc.PixelIdxList{i}) = 0;
    end
end

% Perform connected component analysis again
cc = bwconncomp(im_bin);
