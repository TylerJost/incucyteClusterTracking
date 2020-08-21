%% Test file
close all
file = 'GH1825_B6.mat';
load(file)
wellDates = [wellDates{:}]';
[centroidCell, center] = centerWell(centroidCell);
figure(1)
x1 = centroidCell{43};
scatter(x1(:,1),x1(:,2),'.r')
hold on
x2 = centroidCell{44};
scatter(x2(:,1),x2(:,2),'.b')

%% Take upper quadrant
euclid = @(x1,x2,y1,y2) sqrt((x1-x2).^2+(y1-y2).^2);


x1 = x1(x1(:,1)>0,:);
x1 = x1(x1(:,2)>0,:);

x2 = x2(x2(:,1)>0,:);
x2 = x2(x2(:,2)>0,:);
% Speed test
% Find closest point

translation = zeros(size(x1));
for i = 1:length(x1)
    pts = euclid(x1(i,1),x2(:,1),x1(i,2),x2(:,2));
    [v,index] = min(pts);
    closest = x2(index,:);
    translation(i,1) = x1(i,1) - closest(1,1);
    translation(i,2) = x1(i,2) - closest(1,2);
end
figure(2)
hold on
set(gca,'Color','k')
sp = scatplot(translation(:,1),translation(:,2));


[~,transI] = max(sp.ddf);

trans = translation(transI,:);
disp(trans)
x1T = x1-trans;

figure(3)
subplot(121)
scatter(x1T(:,1),x1T(:,2),'.r')
hold on
% scatter(x1(:,1),x1(:,2),'.g')
scatter(x2(:,1),x2(:,2),'.b')
title('Translated')

subplot(122)
scatter(x1(:,1),x1(:,2),'.r')
hold on
% scatter(x1(:,1),x1(:,2),'.g')
scatter(x2(:,1),x2(:,2),'.b')
title('Original')
%%
x1 = centroidCell{39};
x2 = centroidCell{40};
x1T = x1-trans;
figure(4)
subplot(121)
scatter(x1T(:,1),x1T(:,2),'.r')
hold on
% scatter(x1(:,1),x1(:,2),'.g')
scatter(x2(:,1),x2(:,2),'.b')
title('Translated')

subplot(122)
scatter(x1(:,1),x1(:,2),'.r')
hold on
% scatter(x1(:,1),x1(:,2),'.g')
scatter(x2(:,1),x2(:,2),'.b')
title('Original')
%%
fileName = 'GH1825_B6.mat';
tic
makeCentroidVideo(fileName)
toc