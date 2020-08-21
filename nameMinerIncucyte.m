function [well,date] = nameMinerIncucyte(fileName)
%nameMinerIncucyte finds the well # and date of capture from the filename

fileComponents = strsplit(fileName,'_');
well = fileComponents(2);
% Extract date
dateCap = fileComponents(4);
timeCap = fileComponents(5);
date  = datetime(str2double(dateCap{1}(1:4)),str2double(dateCap{1}(6:7)),...
    str2double(dateCap{1}(9:10)),...
    str2double(timeCap{1}(1:2)),str2double(timeCap{1}(4:5)),0);
end