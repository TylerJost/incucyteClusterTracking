function quickPlotWell(dates,imRange,clusterCell,centroidCell,polyCell)

% close all
imRange = round(linspace(imRange(1),imRange(end),6));
if mean(imRange) == imRange(1)
    imRange = imRange(1);
end

[~,clusterN] = size(clusterCell);

for im = imRange
    if length(imRange)>1
        figure(im)
    else
        figure()
    end
    xWhole = centroidCell{im};
    scatter(xWhole(:,1),xWhole(:,2),2.5,'k','filled')
    clusters = clusterCell(im,:);
    cat = [];
    for c = 1:clusterN
        cat = [cat; repmat(c,length(clusters{c}),1)];
        hold on
        verts = polyCell{im,c};
        if all(sum(verts)>0)
%             verts = dilateHull(verts,sizeI);
            plot(verts(:,1),verts(:,2),':m','LineWidth',1.5)
        end
    end
    x = [vertcat(clusters{1:end}), cat];
    if sum(cellfun(@isempty,clusters))<length(clusters)
        hold on
        h = gscatter(x(:,1),x(:,2),x(:,3));
        for i = 1:length(h)
            h(i).MarkerSize = 5;
        end
    end
    if iscell(dates)
        cluster = 1;
        myTitle = sprintf('%s\nCell Number=%g',string(dates{im}),...
            length(clusterCell{im,cluster}));
%         title(string(dates{im}))
        title(myTitle)
    end
end

end