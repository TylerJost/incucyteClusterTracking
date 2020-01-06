lose all
clear
clc
%%
% Basic cell counting using incucyte data
I = imread('VID483_B3_1_2018y08m14d_16h55m.jpg');
% imshow(I)
% figure()
% IGrey = rgb2gray(I);
% imshow(IGrey)

hblob = vision.BlobAnalysis( ...
    'AreaOutputPort', false, ...
    'BoundingBoxOutputPort', false, ...
    'OutputDataType', 'single', ...
    'MinimumBlobArea', 	1, ...
    'MaximumBlobArea', 100, ...
    'MaximumCount', 1e8);
% y1 = 2*IGrey - imdilate(IGrey, strel('square',7));
% y1(y1<0) = 0;
% y1(y1>1) = 1;
% y2 = imdilate(y1, strel('square',7)) - y1;
% th = multithresh(IGrey);      % Determine threshold using Otsu's method
% y3 = (IGrey <= th*.8);
% First find as many green cells as possible
% [BW,maskedRGB] = findGreenCells(I);
IGrey = rgb2gray(I);
th = multithresh(IGrey);
y = (IGrey <= th*0.8);
y = imcomplement(y);
% figure()
% imshow(y)
% Find centroid using hblob
showCentroid(hblob,y,I)
showCentroid(hblob,BW,I)

%% Watershedding
% https://www.mathworks.com/help/images/ref/watershed.html
close all
load('IS.mat')
% Note you need to define IS yourself
% Threshold data
th = multithresh(IS);
y = (IS <= th*1);
% bw = imbinarize(y);
bw = ~y;
imshow(bw)
% Fill in some of the holes
bw = imclose(bw,strel('disk',1));
bw = imfill(bw,'holes');
figure
imshow(bw)
% figure()
% imshow(bw)
% Make peaks into valleys by taking the complement of the image
% bw = ~y;
D = -bwdist(~bw);
D(~bw) = -Inf;
D = imhmin(D,0.6);
L = watershed(D);
figure()
imshow(label2rgb(L,'jet','w'))
% L = rgb2gray(label2rgb(L));
imshow(label2rgb(L))
figure()
imshow(IS)
% showCentroid(hblob,L,IS)
%% Watershedding Tutorial
url = 'https://blogs.mathworks.com/images/steve/2013/blobs.png';
bw = imread(url);
L = watershed(bw);
Lrgb = label2rgb(L);
imshow(Lrgb)
imshow(imfuse(bw,Lrgb))
bw2 = ~bwareaopen(~bw, 10);
imshow(bw2)
%% Following watershedding tutorial
th = multithresh(IL);
y = (IL <= th*1);
% bw = imbinarize(y);
bw = ~y;
imshow(bw)
L = watershed(bw);
Lrgb = label2rgb(L);
imshow(Lrgb)
imshow(imfuse(bw,Lrgb))
bw = imclose(bw,strel('disk',1));
bw = imfill(bw,'holes');
bw2 = ~bwareaopen(~bw, 10);
imshow(bw2)
D = -bwdist(~bw);
imshow(D,[])
Ld = watershed(D);
imshow(label2rgb(Ld))

% bw2 = bw;
bw2(Ld == 0) = 0;
imshow(bw2)

mask = imextendedmin(D,.3);
imshowpair(bw,mask,'blend')

D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
bw3 = bw;
bw3(Ld2 == 0) = 0;
imshow(bw3)
showCentroid(hblob,bw3,IL)
%% Get rid of well border
close all
% Try doing the opposite of imfill
th = multithresh(IGrey);
y = (IGrey <= th*1);
% bw = imbinarize(y);
bw = ~y;
bworig = bw;
imshow(bw)
bw = imclose(bw,strel('disk',1));
imshow(bw)
[bw2,locations_out] = imfill(bw,'holes');
imshow(bw2)
bwcrop = ~(bw2-bw);
imshow(bwcrop)
figure
imshow(bworig)
% imOut = watershedCells(bwcrop)
%%
close all
imOut = watershedCells(IGrey);
%% Functions
% function noBorder = cropWellBorder(imageIn)
% Crops the 
th = multithresh(imageIn);
y = (imageIn <= th*1);
bw = ~y;
bw = imclose(bw,strel('disk',1));
[bw2] = imfill(bw,'holes');
noBorder = ~(bw2-bw);
% end
function imOut = watershedCells(imageIn)
% th = multithresh(imageIn);
% y = (imageIn <= th*1);
% % bw = imbinarize(y);
% bw = ~y;
bw = cropWellBorder(imageIn);
imshow(bw)
% Fill in some of the holes
bw = imclose(bw,strel('disk',1));
bw = imfill(bw,'holes');
figure
imshow(bw)
% figure()
% imshow(bw)
% Make peaks into valleys by taking the complement of the image
% bw = ~y;
D = -bwdist(~bw);
D(~bw) = -Inf;
D = imhmin(D,0.6);
L = watershed(D);
figure()
imshow(label2rgb(L,'jet','w'))
% L = rgb2gray(label2rgb(L));
imshow(label2rgb(L))
figure()
imshow(imageIn)
imOut = L;
end
function showCentroid(hblob,imThresh,imOrig)
Centroid = step(hblob, imThresh);
image_out = insertMarker(imOrig, Centroid, '*', 'Color', 'cyan');
figure()
imshow(image_out)
end