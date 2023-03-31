function N = segmentNuclei(EDF_image, m, s, t1, t2, d)
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

    % Initialization
    imageSample = imread(EDF_image);

    % Converting image to grayscale
    imageSample = im2gray(imageSample);

    imageSample = double(imageSample);

    N = zeros(size(imageSample));
    I = wiener2(imageSample);

    % Iterative detection and segmentation
    for t = t1:10:t2
        B = I <= t;
        CC = bwconncomp(B);
        stats = regionprops(CC, 'Area', 'Solidity', 'Image');
        
        for i = 1:CC.NumObjects
            r = stats(i);
            r_size = r.Area;
            r_solidity = r.Solidity;
            r_mask = zeros(size(B));
            r_mask(CC.PixelIdxList{i}) = 1;
            overlap_mask = r_mask & N;
            if r_size < m || r_solidity < s
                % Remove r
                B(CC.PixelIdxList{i}) = 0;
            elseif (overlap_mask == 0)
                
                N = N | r_mask;
            else
                overlap_stats = regionprops(overlap_mask, 'Solidity');
                max_overlap_solidity = max([overlap_stats.Solidity]);

                if r_solidity >= max_overlap_solidity
                    N = N | r_mask;
                else
                    B(CC.PixelIdxList{i}) = 0;
                end
            end
        end
    end

    % Post-processing
   
    CC = bwconncomp(N);
    stats = regionprops(CC, imageSample, 'PixelValues', 'Perimeter', 'PixelList');


    for i = 1:CC.NumObjects
        
        r = stats(i);
        r_mask = zeros(size(N));
        r_mask(CC.PixelIdxList{i}) = 1;
        r_mask = imdilate(r_mask, strel('disk', 1));

        r_intensity = mean(r.PixelValues);
        outer_boundary = bwperim(r_mask);
%         outer_boundary_intensity = r.PixelList & outer_boundary;

%         outer_boundary = bwperim(r.Perimeter);
       x_values = zeros(1,1);
       y_values = zeros(1,1);
        
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

        outer_boundary_sum = 0.0;
        for k = 1:length(x_values)
            outer_boundary_sum = outer_boundary_sum + imageSample(x_values(k), y_values(k));
        end

        outer_boundary_intensity = outer_boundary_sum/ length(x_values);
% 
%         if r_intensity - outer_boundary_intensity < d
%             N(CC.PixelIdxList{i}) = 0;
%         end
        if (abs(r_intensity - outer_boundary_intensity)) < d
            N(CC.PixelIdxList{i}) = 0;
        end
    end

[B,L] = bwboundaries(N,'noholes');
imshow(N,[])
hold on
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'g');
end

% Display the original image and output binary mask
figure;
subplot(1,2,1);
imshow(imageSample, []);
title('Original');
subplot(1,2,2);
imshow(N, []);
title('Output Binary Mask N');
end