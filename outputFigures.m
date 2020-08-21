function outputFigures(outputFolder,varargin)

try
    cd(outputFolder)
catch
    error('Did you add the folder to the path (or create it at all)?')
end
figList = findobj(allchild(0), 'flat', 'Type', 'figure');
if ~isempty(varargin)
    names = varargin{1};
    if length(names) ~= length(figList)
        names = cell(1,length(figList));
    end
else
    names = cell(1,length(figList));
end
for iFig = 1:length(figList)
   figHandle = figList(iFig);
   figName = num2str(get(figHandle,'Number'));
%    set(0,'CurrrentFigure',figHandle)
   saveas(figHandle,fullfile(outputFolder,[figName,'_',names{str2double(figName)},'.jpg']))    
end
end