function data=ImportCSVasVector(filename)
% Import data from csv file. Default delimiter here is space, and assuming
% floating numbers
delimiter = ' ';

%first get number of items per line, to define format
fileID = fopen(filename,'r');
itemNum=length(regexp(fgets(fileID),' '));
frewind(fileID);

% Format for each line of text:
formatSpec = [repmat('%f',1,itemNum) '%[^\n\r]'];

% Read columns of data according to the format.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);

% Allocate imported array to column variable names
data = cell2mat(dataArray(1:end-1));