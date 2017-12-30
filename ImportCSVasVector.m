function data=ImportCSVasVector(filename)
% Import data from csv file.

delimiter = ' ';

% Format for each line of text:
formatSpec = '%f%[^\n\r]';

% Read columns of data according to the format.
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);

% Allocate imported array to column variable names
data = dataArray{:, 1};