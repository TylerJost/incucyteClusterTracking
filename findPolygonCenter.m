function c = findPolygonCenter(pts,area)
%findPolygonCenter finds the center of a polygon defined by pts
    n = length(pts);
    % Equation from:
    % https://en.wikipedia.org/wiki/Centroid#Of_a_polygon    
    sx = sum((pts(1:n-1,1)+pts(2:n,1)).*(pts(1:n-1,1).*pts(2:n,2)-pts(2:n,1).*pts(1:n-1,2)));
    sy = sum((pts(1:n-1,2)+pts(2:n,2)).*(pts(1:n-1,1).*pts(2:n,2)-pts(2:n,1).*pts(1:n-1,2)));
    cx = 1/(6*area)*sx;
    cy = 1/(6*area)*sy;

    c = [cx,cy];
end