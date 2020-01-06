function [well,date] = nameMinerIncucyte(fileName)
%nameMinerIncucyte finds the well # and date of capture from the filename

% Split up filename
pieces = strsplit(fileName,'_');
well = pieces{2};
date = pieces{4};
time = pieces{5};
time = time(1:end-4);
% Combine date information into MATLAB's datetime format
date = datetime(str2double(date(1:4)),str2double(date(6:7)),...
    str2double(date(9:10)),str2double(time(1:2)),str2double(time(4:5)),0);

end