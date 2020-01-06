function extrema = findClusterExtrema(x)
%findClusterExtrema finds the furthest points in a cluster of points

[~,minX] = min(x(:,1));
[~,minY] = min(x(:,2));
[~,maxX] = max(x(:,1));
[~,maxY] = max(x(:,2));
extrema = [x(minX,:);x(minY,:);x(maxX,:);x(maxY,:)];
end