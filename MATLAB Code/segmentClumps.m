function segmentedClumps = segmentClumps(EDF_image, nucleusMask, q, q_prime)
% imgIn = 
% nucleusMask = 
% q = 
% q_prime =
    imageSample = imread(EDF_image);

    % Converting image to grayscale
    imageSample = im2gray(imageSample);

    imageSample = double(imageSample);
    GMM = fitgmdist(imageSample, 5);
    % Learn a Gaussian Mixture Model with two components on pixel intensities
    % gmm = fitgmdist(imageSample, 2, 'RegularizationValue', 1e-5);

    % Find the index of the Gaussian corresponding to the background
    [~, backgroundIdx] = max(gmm.mu);

    % Calculate the threshold T
    b = gmm.mu(backgroundIdx);
    b_std = sqrt(gmm.Sigma(backgroundIdx));
    T = b + sqrt(2 * b_std * erfinv(2 * q - 1));

    % Binarize the image using the threshold T
    binarizedImage = EDF_image <= T;

    % Perform connected component analysis
    CC = bwconncomp(binarizedImage);
    stats = regionprops(CC, EDF_image, 'Area', 'MeanIntensity', 'PixelIdxList');

    % Remove connected components that do not contain any nucleus
    % or have a small area or average intensity larger than Q(q_prime)
    Q_q_prime = b + sqrt(2 * b_std * erfinv(2 * q_prime - 1));
    segmentedClumps = false(size(EDF_image));

    for i = 1:length(stats)
        r = stats(i);
        containsNucleus = any(nucleusMask(r.PixelIdxList{:}));
        isLargeEnough = r.Area >= 1; % Replace 1 with a suitable minimum area threshold
        hasLowIntensity = r.MeanIntensity < Q_q_prime;

        if containsNucleus && isLargeEnough && hasLowIntensity
            segmentedClumps(r.PixelIdxList{:}) = 1;
        end
    end

% Discard nuclei that do not overlap with any segmented cell clump
nucleusMask(~segmentedClumps) = 0;

% Display the original image and output binary mask
figure;
subplot(1,2,1);
imshow(imageSample, []);
title('Original');
subplot(1,2,2);
imshow(segmentedClumps, []);
title('Segmented Clumps');
end