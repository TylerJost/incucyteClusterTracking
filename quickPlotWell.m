function quickPlotWell(dates,imRange,clusterCell,centroidCell,allPar)

close all
imRange = round(linspace(imRange(1),imRange(end),6));

[~,clusterN] = size(clusterCell);

for im = imRange
    figure(im)
    xWhole = centroidCell{im};
    scatter(xWhole(:,1),xWhole(:,2),'.m')
    clusters = clusterCell(im,:);
    cat = [];
    for c = 1:clusterN
        cat = [cat; repmat(c,length(clusters{c}),1)];
        hold on
        circlePlot(allPar(im,1,c),allPar(im,2,c),allPar(im,3,c)*2)
    end
    x = [vertcat(clusters{1:end}), cat];
    if sum(cellfun(@isempty,clusters))<length(clusters)
        hold on
        gscatter(x(:,1),x(:,2),x(:,3))
%         gscatter(x(:,1),x(:,2),x(:,3),repmat(3,1,length(unique(x(:,3)))))
    end
        title(string(dates{im}))
end

end