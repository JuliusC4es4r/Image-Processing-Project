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

    for i = 1:length(imageSample)
        for j = 1:length(imageSample)
            if(imageSample(i,j) < 222)
                binarizedImage(i,j) = 1;
            end
        end
    end

    backgroundImage = zeros(length(backgroundImage));
    backgroundImage = double(backgroundImage);

    foregroundImage = zeros(length(foregroundImage));
    foregroundImage = double(foregroundImage);
    
    for i = 1:length(imageSample)
        for j = 1:length(imageSample)
            if(binarizedImage(i,j) == 1)
                foregroundImage(i,j) = 1;
            else
                backgroundImage(i,j) = 1;
            end
        end
    end

    for i = 1:length(imageSample)
        for j = 1:length(imageSample)
            if(foregroundImage(i,j) == 1)
                foregroundImage(i,j) = imageSample(i,j);
            else
                backgroundImage(i,j) = imageSample(i,j);
            end
        end
    end

     muBackground = mean(backgroundImage(:));
     muForeground = mean(foregroundImage(:));

     sigmaBackground = std(backgroundImage(:));
     sigmaForeground = std(foregroundImage(:));

    rng('default') % For reproducibility
    rBackground = mvnrnd(muBackground,sigmaBackground,1000);
    rForeground = mvnrnd(muForeground,sigmaForeground,1000);
    X = [rBackground; rForeground];

    GMM = fitgmdist(X, 2);
   
% Display the original image and output binary mask
figure;
subplot(1,2,1);
imshow(imageSample, []);
title('Original');
subplot(1,2,2);
imshow(segmentedClumps, []);
title('Segmented Clumps');
end