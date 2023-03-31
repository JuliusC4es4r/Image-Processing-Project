function segmentedClumps = segmentClumps(EDF_image, nucleusMask, area, T)
% EDF_image = 
% nucleusMask = 
% area = 
% T =
    imageSample = imread(EDF_image);

    % Converting image to grayscale
    imageSample = im2gray(imageSample);

    imageSample = double(imageSample);

    binarizedImage = zeros(length(imageSample));
    binarizedImage = double(binarizedImage);

    % binarizing image based on threshold
    for i = 1:length(imageSample)
        for j = 1:length(imageSample)
            if(imageSample(i,j) < T)
                binarizedImage(i,j) = 1;
            end
        end
    end
    
    % removing regions less than size area
    CC = bwconncomp(binarizedImage);
    stats = regionprops(CC, 'Area','ConvexHull',"Image");
    for i = 1:CC.NumObjects
        r = stats(i);
        r_size = r.Area;
        if r_size < area
        % Remove r
        binarizedImage(CC.PixelIdxList{i}) = 0;
        end
    end

    % init empty matrices for 
    backgroundImage = zeros(length(imageSample));
    backgroundImage = double(backgroundImage);

    foregroundImage = zeros(length(imageSample));
    foregroundImage = double(foregroundImage);
    
    % separating binarized image to foreground and background
    for i = 1:length(imageSample)
        for j = 1:length(imageSample)
            if(binarizedImage(i,j) == 1)
                foregroundImage(i,j) = 1;
            else
                backgroundImage(i,j) = 1;
            end
        end
    end

    % replacing foreground and background images with original image
    for i = 1:length(imageSample)
        for j = 1:length(imageSample)
            if(foregroundImage(i,j) == 1)
                foregroundImage(i,j) = imageSample(i,j);
            else
                backgroundImage(i,j) = imageSample(i,j);
            end
        end
    end
    
    % subtracting nucleus mask from foreground image
    for i = 1:length(imageSample)
        for j = 1:length(imageSample)
            if(nucleusMask(i,j) == 1)
                foregroundImage(i,j) = foregroundImage(i,j) - imageSample(i,j);
                if(foregroundImage(i,j) < 0)
                    foregroundImage(i,j) = 0;
                end
            end
        end
    end
segmentedClumps = foregroundImage;

% drawing borders for segmented clumps
[B,L] = bwboundaries(segmentedClumps,'noholes');
imshow(segmentedClumps,[])
hold on
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'g');
end

% Display the original image and output binary mask
figure;
subplot(1,3,1);
imshow(imageSample, []);
title('Original');
subplot(1,3,2);
imshow(segmentedClumps, []);
title('Segmented Clumps');
subplot(1,3,3);
imshow(nucleusMask, []);
title('Nucleus Mask');
end