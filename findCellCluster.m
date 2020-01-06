function [xyC,ntry] = findCellCluster(x,epsilon,minpts,ntry,par)
%findCellCluster finds clusters of cells using dbscan
% x is all of the data, neighbors is the number of minimum cells in a
% cluster, ntry is the number of times , par has data about the circle to
% be fit to the data.

% Check to see if we should still be trying to find clusters
if sum(par) == 0
    xyC = NaN;
    ntry = NaN;
    return
end
% epsilon = 30;
% Find coordinates in last circle
xcmat = repmat(par(1),length(x),1);
ycmat = repmat(par(2),length(x),1);
circleDists = euclid(x(:,1),xcmat,x(:,2),ycmat);
% x = x(circleDists<=par(3)*2,:);
x = x(circleDists<=par(3)*2,:);
% Set number of neighbors
% if length(x)<25 && length(x)>5
%     epsilon = 15;
%     minpts = 5;
% elseif length(x)<=5
%     minpts = 2;
%     epsilon = 10;
% end
% Use dbscan to find density based clusters
dbidx = dbscan(x,epsilon,minpts);
% Check if dbscan can't find any good clusters
if sum(dbidx==-1) == length(dbidx)
    xyC = NaN;
    return
end
primaryCluster = mode(dbidx(dbidx>0),'all');
xyC = x(dbidx==primaryCluster,:);
ntry = ntry+1;
end