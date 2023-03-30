function segmentedClumps = segmentClumps(EDF_image, nucleusMask, q, q_prime)
% imgIn = 
% nucleusMask = 
% q = 
% q_prime =
    imageSample = imread(EDF_image);

    % Converting image to grayscale
    imageSample = im2gray(imageSample);

    imageSample = double(imageSample);
    binarizedImage = zeros(length(imageSample));
    binarizedImage = double(binarizedImage);

    imageMedian = median(imageSample(:));

    for i = 1:length(imageSample)
        for j = 1:length(imageSample)
            if(imageSample(i,j) < imageMedian)
                binarizedImage(i,j) = 1;
            end
        end
    end
    GMM = fitgmdist(imageSample, 5);
   
% Display the original image and output binary mask
figure;
subplot(1,2,1);
imshow(imageSample, []);
title('Original');
subplot(1,2,2);
imshow(segmentedClumps, []);
title('Segmented Clumps');
end