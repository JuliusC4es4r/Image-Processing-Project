function cytoplasmMask = segmentCytoplasm(EDF_image, nucleusMask,segmentedClumps, W, alpha)

% Boundary approximation
    imageSample = imread(EDF_image);

    % Converting image to grayscale
    imageSample = im2gray(imageSample);

    imageSample = double(imageSample);
    
    [Gmag, Gdir] = imgradient(imageSample);

    [B,L] = bwboundaries(segmentedClumps,'noholes');
    CC = bwconncomp(segmentedClumps);
    NM = bwconncomp(nucleusMask);
    statsClumps = regionprops(CC, 'BoundingBox','ConvexHull',"Image","ConvexImage","Centroid");

    statsNuclei = regionprops(NM,nucleusMask,"PixelList");

    imshow(imageSample,[]);
    axis on;
    hold on;

    centroids_x = zeros(length(statsNuclei),1);
    centroids_y = zeros(length(statsNuclei),1);

    for i = 1:length(statsNuclei)
        N = statsNuclei(i);
        nucleiPixels = N.PixelList;
        max_X = max(nucleiPixels(:,1));
        min_X = min(nucleiPixels(:,1));
        max_Y = max(nucleiPixels(:,2));
        min_Y = min(nucleiPixels(:,2));
        diff_X = round((max_X-min_X)/2);
        diff_Y = round((max_Y-min_Y)/2);
        centroids_x(i) = min_X + diff_X;
        centroids_y(i) = min_Y + diff_Y;
        plot(centroids_x(i), centroids_y(i),  'r*', 'LineWidth', 1);
    end

    % create grid 
    for i = 1:length(centroids_x)
        % Calculate the top left corner coordinates of the square
        disp(centroids_x(i))
        disp(centroids_y(i))
        x1 = max(round(centroids_x(i) - W/2), 1);
        y1 = max(round(centroids_y(i) - W/2), 1);
        
        % Calculate the bottom right corner coordinates of the square
        x2 = min(round(centroids_x(i) + W/2), size(imageSample, 2));
        y2 = min(round(centroids_y(i) + W/2), size(imageSample, 1));

        % Crop the square portion of the image
        square = imageSample(y1:y2, x1:x2, :);

        rectangle('Position', [x1, y1, x2-x1, y2-y1],'EdgeColor','r', 'LineWidth', 1);
    end


% normalizedFocusVectors = normalizeFocusVectors(focusMeasures);
% focusDistances = computeFocusDistances(normalizedFocusVectors);
% closeness = computeCloseness(rows, cols, W);
% likelihood = computeLikelihood(focusDistances, closeness, alpha);
% subimageAssignment = assignSubimages(likelihood, numNuclei, beta);
% 
% % Coarse refinement
% reachabilityMask = computeReachability(subimageAssignment, nucleusMask, W);
% refinedMask = reachabilityMask;
% 
% % Fine refinement
% for n = 1:numNuclei
%     nucleusCentroid = computeCentroid(nucleusMask, n);
%     refinedBoundary = refineBoundary(refinedMask(:,:,n), nucleusCentroid, a, threshold);
%     refinedMask(:,:,n) = refinedBoundary;
% end
% 
% % Combine refined masks
% cytoplasmMask = combineRefinedMasks(refinedMask, nucleusMask);
% 
% end