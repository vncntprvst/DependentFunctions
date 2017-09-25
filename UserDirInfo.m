function userinfo=UserDirInfo(varargin)

if isempty(varargin)
    usageMode='simple';
else
    usageMode=varargin{1};
end

keepCurDir=cd;
%define info structure
userinfo=struct('directory',cd,'user',getenv('username')); ...% ,'dbldir',[],...
    %     'syncdir',[],'mapdr',[],'servrep',[],'mapddataf',[]);

if contains(usageMode,'extended') || contains(usageMode,'simple')
    % find host name
    [~,compHostName]=system('hostname');
    
    if regexp(compHostName(end),'\W') %the system command added a carriage return ending
        compHostName=compHostName(1:end-1);
    end
    
    %the definition file provides information about user directories
    %fill up the following fields (all are optional - depends on user preferences)
    % and save file with the hostname as filename (e.g., RecordingSetupPC)
    % userinfo.directory = 'E:\Data\'; % where the data is located
    % userinfo.user='Vincent'; %user name
    % userinfo.probemap='C:\...\probemaps'; %where the probe mappings are stored
    % userinfo.WinDirs='C:\Windows\system32;C:\Windows'; % Windows directories
    % userinfo.ypipe='C:\...\yes.txt'; % a pipe-in file with just the letter y in it
    % userinfo.circusHomeDir='C:\Users\Vincent\spyking-circus'; % spyking-circus home directory
    % userinfo.circusEnv='spykc'; % Anaconda environement for spyking-circus
    % userinfo.MPIDir='C:\Program Files\Microsoft MPI\Bin\'; % MPI directory
    % userinfo.dbldir=''; %database directory
    % userinfo.mapddataf=''; %mapped drive
    % userinfo.syncdir=''; %cloud directory
    
    %open definition file
    try
        cd ('C:\Code') % change that folder to wherever your definition file is
        if exist(compHostName,'file')
            fileLoc=['C:\Code' filesep compHostName];
        end
    catch
        disp('trying to locate directory definition file');
        funDir=[regexp(which('UserDirInfo'),['^.+(?=\' filesep ')'],'match','once') filesep];
        rootDir=[regexp(funDir,['^.+?(?=\' filesep ')'],'match','once') filesep]; %root letter of current directory in Windows
        %                                                                    may need to change for other platforms
        cd(funDir); cd('..');
        if contains(computer('arch'),'win')
            [~,list] = system(['dir ' compHostName ' /S/B']);
            fileLoc = textscan(list, '%s', 'Delimiter', '\n');
        else
            [~,fileLoc]=system(['find ' funDir ' -type f -name "' compHostName '"']);
        end
        % if comes up empty, move one folder up
        if contains(fileLoc{:},'File Not Found')
            cd('..'); curDir=cd;
            if contains(computer('arch'),'win')
                [~,list] = system(['dir ' compHostName ' /S/B']);
                fileLoc = textscan(list, '%s', 'Delimiter', '\n');
            else
                [~,fileLoc]=system(['find ' curDir ' -type f -name "' compHostName '"']);
            end
        end
        if contains(fileLoc{:},'File Not Found')
            cd(rootDir); curDir=cd;
            if contains(computer('arch'),'win')
                [~,list] = system(['dir ' compHostName ' /S/B']);
                fileLoc = textscan(list, '%s', 'Delimiter', '\n');
            else
                [~,fileLoc]=system(['find ' curDir ' -type f -name "' compHostName '"']);
            end
        end
        fileLoc=fileLoc{1, 1}{1, 1};
    end
    
    if ~isempty(fileLoc) & ~contains(fileLoc,'File Not Found')
        fid = fopen(fileLoc);
        tline = fgetl(fid);
        while ischar(tline)
            eval(tline)
            tline = fgetl(fid);
        end
        fclose(fid);
    else
        userinfo=[];
        return;
    end
end

if contains(usageMode,'extended') || contains(usageMode,'pyEnv')
    % find environment directories
    try
        [~,envInfo] = system('conda info -e');
        userinfo.envRootDir=cell2mat(regexp(envInfo,['(?<=' userinfo.circusEnv '                   ).+?(?=\n)'],'match'));
        if isempty(userinfo.envRootDir)
            %maybe it's activated
            userinfo.envRootDir=cell2mat(regexp(envInfo,['(?<=' userinfo.circusEnv '\s**\s{2,}).+?(?=\n)'],'match'));
            if isempty(userinfo.envRootDir)
                userinfo.envRootDir=cell2mat(regexp(envInfo,'(?<=root                  \*  ).+?(?=\n)','match'));
            end
        end
        userinfo.envScriptDir=[userinfo.envRootDir filesep 'Scripts'];
        userinfo.envLibDir=[userinfo.envRootDir filesep 'Library' filesep 'bin'];
    catch %conda not installed
        [userinfo.envRootDir,userinfo.envScriptDir,userinfo.envLibDir]=deal([]);
    end
end

if contains(usageMode,'extended') || contains(usageMode,'mappedDrives')
    %find if one or more remote drives are mapped
    [~,connlist]=system('net use');
    if logical(regexp(connlist,'OK'))
        %in case multiple mapped drives, add some code here
        carrets=regexpi(connlist,'\r\n|\n|\r');
        if isempty(regexp(connlist,':','start'))
            disp('connect remote drive to place files on server')
        elseif length(regexp(connlist,':','start'))==1
            userinfo.servrep=connlist(regexp(connlist,':','start')-1:carrets(find(carrets>regexp(connlist,':','start'),1))-1);
            userinfo.servrep=regexprep(userinfo.servrep,'[^\w\\|.|:|-'']','');
            if strfind(userinfo.servrep,'MicrosoftWindowsNetwork')
                userinfo.servrep=strrep(userinfo.servrep,'MicrosoftWindowsNetwork','');
            end
            userinfo.mapdr=userinfo.servrep(1:2);userinfo.servrep=userinfo.servrep(3:end);userinfo.servrep=regexprep(userinfo.servrep,'\\','/');
        elseif length(regexp(connlist,':','start'))>=2
            servs=regexp(connlist,':','start')-1;
            for servl=1:length(servs)
                if logical(strfind(regexprep(connlist(servs(servl):carrets(find(carrets>servs(servl),1))-1),'[^\w\\|.|:|-'']',''),...
                        userinfo.servname))
                    userinfo.servrep=regexprep(connlist(servs(servl):carrets(find(carrets>servs(servl),1))-1),'[^\w\\|.|:|-'']','');
                    userinfo.mapdr=userinfo.servrep(1:2);userinfo.servrep=userinfo.servrep(3:end);userinfo.servrep=regexprep(userinfo.servrep,'\\','/');
                    break;
                end
            end
        end
    else
        [userinfo.servrep,userinfo.mapdr]=deal([]);
    end
    cd(keepCurDir);
end
