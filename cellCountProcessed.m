function centroids = cellCountProcessed(fileName,varargin)
% cellCountProcessed finds centroids of cells in processed incucyte images
%     Adding the keyword 'view' after the fileName will take the image and
%     put cyan crosses on any detected cells. 

% Read in file and turn to gray
I = imread(fileName);
I = rgb2gray(I);
% Threshold using Otsu's method
th = multithresh(I);
% Make sure the black/white image has white cells on black background
bw = ~(I <= th);
% Define blob analysis
hblob = vision.BlobAnalysis( ...
    'AreaOutputPort', false, ...
    'BoundingBoxOutputPort', false, ...
    'OutputDataType', 'single', ...
    'MinimumBlobArea', 	1, ...
    'MaximumBlobArea', 350, ...
    'MaximumCount', 1e8);
% Locate centroids
centroids = step(hblob,bw);
if nargin>1
    if strcmp(varargin{1},'view')
        imCheck = insertMarker(I, centroids, '*', 'Color', 'cyan');
        figure()
        imshow(imCheck)
    end
end

%% Perimeters
% [B,L] = bwboundaries(bw,'noholes');
% imshow(label2rgb(L, @jet, [.5 .5 .5]))
% hold on
% for k = 1:length(B)
%     boundary = B{k};
%     plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 0.5)
% end

end