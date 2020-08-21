function [centroidCell,centers] = centerWell(centroidCell)
% centerWell translates points in order to have each image on a consistent
%   center.
centers = zeros(length(centroidCell),2);
for i = 1:length(centroidCell)
    % Find center of well using convex hull of all points
    pts = double(centroidCell{i});
    [npts,~] = size(pts);
    if npts<5
        continue
    end
    [k,areaHull] = convhull(pts);
    ptsHull = [pts(k,1), pts(k,2)];
    center = findPolygonCenter(ptsHull,areaHull);
    %     clf
    %     scatter(pts(:,1),pts(:,2),'.k')
    %     hold on
    %     scatter(pts(:,1)-c(1), pts(:,2)-c(2),'.g')
    if any(center<-0.5)
        error('Centroid center is less than 0')
    end
    % Translate to [0,0]
    centers(i,:) = center;
    centroidCell{i} = [pts(:,1)-center(1), pts(:,2)-center(2)];
end
end