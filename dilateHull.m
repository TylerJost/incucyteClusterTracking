function [ptsx2T, areaHull] = dilateHull(x,sizeFactor)
%dilateHull finds and enlarges the convex hull around a set of points

% Convert to double so convhull will work
g = double(x);
% Calculate convex hull and dilate it
[p,areaHull] = convhull(g);
pts = [g(p,1),g(p,2)];
ptsx2 = pts.*sizeFactor;
areaHull = areaHull;
% Find center of convex hull and translate dilated hull back
c = findPolygonCenter(pts,areaHull);
cx2 = findPolygonCenter(ptsx2,polyarea(ptsx2(:,1),ptsx2(:,2)));
diff2Move = cx2-c;
ptsx2T = [ptsx2(:,1)-diff2Move(1), ptsx2(:,2)-diff2Move(2)];
end