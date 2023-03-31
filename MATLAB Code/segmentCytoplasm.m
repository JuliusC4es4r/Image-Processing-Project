function cytoplasmMask = segmentCytoplasm(EDF_image, nucleusMask,segmentedClumps, alpha)

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
%   nucleiCenters = zeros(length(statsNuclei),2);

    

    imshow(imageSample,[]);
    axis on;
    hold on;
    for i = 1:length(statsNuclei)
        N = statsNuclei(i);
        nucleiPixels = N.PixelList;
        max_X = max(nucleiPixels(:,1));
        min_X = min(nucleiPixels(:,1));
        max_Y = max(nucleiPixels(:,2));
        min_Y = min(nucleiPixels(:,2));
        diff_X = round(max_X-min_X);
        diff_Y = round(max_Y-min_Y);
        plot(min_Y + diff_Y, min_X + diff_X, 'r*', 'LineWidth', 1);
    end
    
%     hold on;
%     for i = 1:25
%     rectangle('Position', stats(i).BoundingBox,'EdgeColor','r', 'LineWidth', 1);
%     end

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