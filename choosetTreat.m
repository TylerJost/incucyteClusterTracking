function tTreat = choosetTreat(tTreatMat, nameSplit,varargin)
% Find well name
if isempty(varargin)
    nameSplit = strsplit(nameSplit{1},'_');
    well = nameSplit{2};
elseif strcmp(varargin{1},'well')
    well = nameSplit;
end
% Index well name
alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
fullPlate = zeros(8,12);
fullPlate(2:7,2:11) = tTreatMat;
row = find(alphabet == well(1));
col = str2double(well(2:end));
% Determine time of treatment
tTreat = fullPlate(row,col);
end