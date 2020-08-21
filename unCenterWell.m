function [centroidCell,clusterCell,polyCell] = unCenterWell(centroidCell,clusterCell,polyCell,center)
for n = 1:length(centroidCell)
    cp = centroidCell{n};
    
    % Translate centroids
    cp = cp+center(n,:);
    centroidCell{n} = cp;
    
end

[lcc,nC] = size(clusterCell);

if ~iscell(clusterCell)
    return
end
for n = 1:lcc
    % For each cluster translate it back
    for c = 1:nC
        clusterP = clusterCell{n,c};
        pp = polyCell{n,c};
        
        % If there is a polygon, translate it
        if sum(pp) ~= 0
            pp = pp+center(n,:);         
        end
        
        % If there is a cluster, translate it
        if ~isempty(clusterP)
            clusterP = clusterP+center(n,:);
        end
        
        clusterCell{n,c} = clusterP;
        polyCell{n,c} = pp;
    end
end