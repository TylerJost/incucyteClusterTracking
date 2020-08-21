clc
clear
%%
dataLocation = 'C:\Users\lucif\Box\Research\trCalculation\centroidData\GH2003';
files = dir('*.mat');
files = {files.name};
files = string(files);
nFiles = length(files);
%%
set(0,'DefaultFigureWindowStyle','normal')
vw = VideoWriter(sprintf('%s.avi',fileName),'Motion JPEG AVI');
vw.Quality = 100;
for file = 1:nFiles
    close all
    fileName = files{file};
   
    open(vw);
    h = figure('units','normalized','outerposition',[0 0 1 1]);
    load(files{file}, 'centroidCell','wellDates','outliers')
    if exist('outliers')
        centroidCell(outliers) = [];
        wellDates(outliers) = [];
    end
    for i = 1:length(centroidCell)
       cc = centroidCell{i};
       wd = wellDates{i};
       scatter(cc(:,1),cc(:,2),'.k')
       title(string(wd))
       pbaspect([1 1 1])
       frame = getframe(h);
       writeVideo(vw,frame)
       clf
    end
    close(vw)
    clear('centroidCell','wellDates','outliers')
    
end