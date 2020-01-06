function checkCircles(centroidCell,allPar,im)
figure()
x = centroidCell{im};
scatter(x(:,1),x(:,2),'.r')
clusterN = size(allPar);
if length(clusterN>2)
    clusterN = clusterN(end);
else
    clusterN = 1;
end

for c = 1:clusterN
    hold on
   circlePlot(allPar(im,1,c),allPar(im,2,c),allPar(im,3,c)*2)
end

end
