function plotCells(cellCoordinates)
%plotCells is a basic helper function which just plots cell coordinates
figure
scatter(cellCoordinates(:,1),cellCoordinates(:,2),5,'r','linewidth',1.5)
end