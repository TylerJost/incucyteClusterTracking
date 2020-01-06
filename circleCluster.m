n = length(clusterCell);

x = clusterCell{n};
scatter(x(:,1),x(:,2),'rx')



extrema = [x(minX,:);x(minY,:);x(maxX,:);x(maxY,:)];

hold on
scatter(extrema(:,1),extrema(:,2),'bx')
par = CircleFitByPratt(extrema);
circlePlot(par(1),par(2),par(3)*2.5)

function extrema = findClusterExtrema(x)
%findClusterExtrema finds the furthest points in a cluster of points
[~,minX] = min(x(:,1));
[~,minY] = min(x(:,2));
[~,maxX] = max(x(:,1));
[~,maxY] = max(x(:,2));
extrema = [x(minX,:);x(minY,:);x(maxX,:);x(maxY,:)];
end