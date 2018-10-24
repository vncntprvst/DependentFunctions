function whiskerTrackingData = ImportDLCWhiskerTrackingCSV(filename, startRow, endRow)
% Import DLC csv data

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 4;
    endRow = inf;
end

%% Format for each line of text:
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read data
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter',...
delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines', startRow(1)-1,...
'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Create output variable
whiskerTrackingData = ...
    table(dataArray{1:end-1}, 'VariableNames',...
    {'frameNum','Whisker1pX','Whisker1pY','Whisker1pLH',...
    'Whisker1mX','Whisker1mY','Whisker1mLH',...
    'Whisker1dX','Whisker1dY','Whisker1dLH',...
    'Whisker2pX','Whisker2pY','Whisker2pLH',...
    'Whisker2mX','Whisker2mY','Whisker2mLH',...
    'Whisker2dX','Whisker2dY','Whisker2dLH',...
    'Whisker3pX','Whisker3pY','Whisker3pLH',...
    'Whisker3mX','Whisker3mY','Whisker3mLH',...
    'Whisker3dX','Whisker3dY','Whisker3dLH'});

