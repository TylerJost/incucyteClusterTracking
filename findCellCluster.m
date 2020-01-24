function [xyC,ntry] = findCellCluster(x,epsilon,minpts,ntry,currentVerts)
%findCellCluster finds clusters of cells using dbscan
% x is all of the data, neighbors is the number of minimum cells in a
% cluster, ntry is the number of times , par has data about the circle to
% be fit to the data.

% Check to see if we should still be trying to find clusters
if isempty(currentVerts)
    xyC = NaN;
    ntry = NaN;
    return
end
% epsilon = 30;
% Find coordinates in last circle
xo = x;
% xcmat = repmat(par(1),length(x),1);
% ycmat = repmat(par(2),length(x),1);
% circleDists = euclid(x(:,1),xcmat,x(:,2),ycmat);
% % x = x(circleDists<=par(3)*2,:);
% % Check within a circle x times larger than the cluster
% x = x(circleDists<=par(3)*1.25,:);

% Check within polygon
in = inpolygon(x(:,1),x(:,2),currentVerts(:,1),currentVerts(:,2));
x = x(in,:);
% Set number of neighbors
% if length(x)<25 && length(x)>5
%     epsilon = 15;
%     minpts = 5;
% elseif length(x)<=5
%     minpts = 2;
%     epsilon = 10;
% end
% Use dbscan to find density based clusters
if ~isempty(x)
    dbidx = dbscan(x,epsilon,minpts);
else
    xyC = NaN;
    return
end
% Check if dbscan can't find any good clusters
if sum(dbidx==-1) == length(dbidx)
    xyC = NaN;
    return
end
%%
% % Optionally check what points the functions is trying to cluster
% figure(1)
% scatter(xo(:,1),xo(:,2),'.k')
% hold on
% gscatter(x(:,1),x(:,2),dbidx)
%% Finding Primary Clusters
[C,ia,ic] = unique(dbidx);
counts = accumarray(ic,1);
clusterSizes = sortrows([C, counts./length(xo)],2,'descend');
clusterSizes(clusterSizes(:,1)==-1,:) = [];
primaryCluster = clusterSizes(1,:);
clusterSizes(1,:) = [];
clusterSizes(clusterSizes(:,2)<=0.1,:) = [];
clusterSizes = [primaryCluster; clusterSizes];
xyC = cell(length(clusterSizes(:,1)),1);
for i = 1:length(clusterSizes(:,1))
    xyC{i} = x(dbidx == clusterSizes(i,1),:);
end
ntry = ntry+1;
end