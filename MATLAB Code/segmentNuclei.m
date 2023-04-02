function N = segmentNuclei(EDF_image, m, s, t1, t2, d)
% EDF_image = input image
% m = minimum area of nucleus
% s = solidity of nucleus
% t1 = lower intensity threshold
% t2 = higher intensity threshold
% d = boundary intensity difference
% N = output nuclei mask

% this function implements the nucleus segmentation algorithm from the
% paper "A framework for nucleus and overlapping cytoplasm..."
% Miguel Manguerra and Kimiya Mousavi

    % Initialization of image
    imageSample = imread(EDF_image);

    % Converting image to grayscale
    imageSample = im2gray(imageSample);

    % converting images to doubles for calculations
    imageSample = double(imageSample);
    
    % initializing nuclei mask
    N = zeros(size(imageSample));

    % filtering with a 2d adaptive noise filter
    I = wiener2(imageSample);

    % Iterative detection and segmentation
    for t = t1:10:t2
        B = I <= t;

        % separating all the B&W regions of the image
        CC = bwconncomp(B);

        % finding the stats of those regions
        stats = regionprops(CC, 'Area', 'Solidity', 'Image');
        
        for i = 1:CC.NumObjects
            r = stats(i);
            r_size = r.Area;
            r_solidity = r.Solidity;
            r_mask = zeros(size(B));
            r_mask(CC.PixelIdxList{i}) = 1;
            overlap_mask = r_mask & N;
            % remove region if region is smaller than minimum area m or
            % solidity is less than s
            if r_size < m || r_solidity < s
                B(CC.PixelIdxList{i}) = 0;
            elseif (overlap_mask == 0)
                % adding mask back to nuclei mask
                N = N | r_mask;
            else
                % finding overlap stats of the region
                overlap_stats = regionprops(overlap_mask, 'Solidity');
                max_overlap_solidity = max([overlap_stats.Solidity]);

                % if solidity of region is over max overlap keep the region
                if r_solidity >= max_overlap_solidity
                    N = N | r_mask;
                else
                    B(CC.PixelIdxList{i}) = 0;
                end
            end
        end
    end

    % Post-processing
   
    % separating all the B&W regions of the image
    CC = bwconncomp(N);

    % finding the stats of those regions
    stats = regionprops(CC, imageSample, 'PixelValues', 'Perimeter', 'PixelList');

    for i = 1:CC.NumObjects
    % iterating through the regions that are found previously    
    r = stats(i);

    % initializing a mask of zeroes
    r_mask = zeros(size(N));
    
    % copying the pixel index list to the mask
    r_mask(CC.PixelIdxList{i}) = 1;

    % filtering every region with imdilate
    r_mask = imdilate(r_mask, strel('disk', 1));
    
    % finding the average intensity of pixel values
    r_intensity = mean(r.PixelValues);
    outer_boundary = bwperim(r_mask);
    x_values = zeros(1,1);
    y_values = zeros(1,1);

        % finding x and y values of outer boundary of each region
        for k = 1:size(outer_boundary)
            for j = 1:size(outer_boundary)
                if (outer_boundary(k,j) == 1)
                    if((x_values(1) == 0) && (y_values(1) == 0))
                        x_values(1) = k;
                        y_values(1) = j;
                    else
                        temp_x = x_values;
                        temp_y = y_values;
                        x_values = [temp_x, k];
                        y_values = [temp_y, j];
                    end
                end
            end
        end

        % calculating intensity difference between boundary and average
        % intensity of r
        outer_boundary_sum = 0.0;
        for k = 1:length(x_values)
            outer_boundary_sum = outer_boundary_sum + imageSample(x_values(k), y_values(k));
        end
        
        outer_boundary_intensity = outer_boundary_sum/ length(x_values);

        % remove r if intensity difference is less than difference
        % parameter d
        if (abs(r_intensity - outer_boundary_intensity)) < d
            N(CC.PixelIdxList{i}) = 0;
        end
    end

    % finding boundaries of nuclei for presentation
    [B,L] = bwboundaries(N,'noholes');

% Display the original image and output binary mask
figure;
subplot(1,2,1);
imshow(imageSample, []);
title('Original');
subplot(1,2,2);
imshow(imageSample,[])
hold on
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'g');
end
title('Output Binary Mask N Boundaries');
end