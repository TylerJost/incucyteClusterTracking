function quickPlotWell(dates,imRange,clusterCell,centroidCell,polyCell)

close all
imRange = round(linspace(imRange(1),imRange(end),6));

[~,clusterN] = size(clusterCell);

for im = imRange
    figure(im)
    xWhole = centroidCell{im};
    scatter(xWhole(:,1),xWhole(:,2),2.5,'m','filled')
    clusters = clusterCell(im,:);
    cat = [];
    for c = 1:clusterN
        cat = [cat; repmat(c,length(clusters{c}),1)];
        hold on
        verts = polyCell{im,c};
        if all(sum(verts)>0)
%             verts = dilateHull(verts,sizeI);
            plot(verts(:,1),verts(:,2),':k','LineWidth',1.5)
        end
    end
    x = [vertcat(clusters{1:end}), cat];
    if sum(cellfun(@isempty,clusters))<length(clusters)
        hold on
        gscatter(x(:,1),x(:,2),x(:,3))
    end
    if iscell(dates)
%         myTitle = sprintf('%s\narea=%g',string(dates{im}),...
%             polyarea(polyCell{im,4}(:,1),polyCell{im,4}(:,2)));
        title(string(dates{im}))
%         title(myTitle)
    end
end

end