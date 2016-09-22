function userinfo=UserDirInfo
%find user, directories and slash type

userinfo=struct('directory',[],'slash',[],'user',[],'dbldir',[],...
    'syncdir',[],'mapdr',[],'servrep',[],'mapddataf',[]);

% find host name
[~,compHostName]=system('hostname');

if regexp(compHostName(end),'\W') %the system command added a carriage return ending
    compHostName=compHostName(1:end-1);
end

if strfind(computer('arch'),'win')
    userinfo.slash = '\';
else
    userinfo.slash = '/';
end

if strcmp(compHostName,'setup_souris')
    userinfo.directory = 'E:\Data\raw';
    userinfo.user='Vincent';
    userinfo.probemap='C:\Code\EphysDataProc\DataExport\probemaps';
    userinfo.dbldir='';
    userinfo.mapddataf='';
    userinfo.syncdir='C:\Box Sync\Home Folder vp35\Sync\Wang Lab\Data\Ephys\export';
    userinfo.MPIDir='C:\Program Files\Microsoft MPI\Bin\';
    userinfo.WinDirs='C:\Windows\system32;C:\Windows';
    userinfo.ypipe='C:\Code\yes.txt';
    userinfo.circusHomeDir='C:\Users\Vincent\spyking-circus';
    userinfo.circusEnv='spykc';
elseif strcmp(compHostName,'Neuro-Wang-01')
    userinfo.directory = 'D:\Data\Vincent\ephys\raw';
    userinfo.probemap='D:\Code\EphysDataProc\DataExport\probemaps';
    userinfo.dbldir='';
    userinfo.mapddataf='';
    userinfo.MPIDir='C:\Program Files\Microsoft MPI\Bin\';
    userinfo.WinDirs='C:\Windows\system32;C:\Windows';
    if strcmp(getenv('username'),'Vincent')
        userinfo.user='Vincent';
        userinfo.syncdir='D:\Data\Vincent\Sync\Box Sync\Home Folder vp35\Sync\Wang Lab\Data\Ephys\export';
    elseif strcmp(getenv('username'),'Michael')
        userinfo.user='Michael';
        userinfo.syncdir='';
    end
    userinfo.ypipe='D:\Code\yes.txt';
elseif strcmp(compHostName,'DangerZone')
    if strcmp(getenv('username'),'DangerZone')
        userinfo.directory = 'E:\data\Recordings\';
        userinfo.user='Vincent';
        userinfo.dbldir = 'E:\JDBC';
        userinfo.mapddataf='vincedata';
        userinfo.syncdir='E:\BoxSync\Box Sync\Home Folder vp35\Sync\CbTimingPredict\data';
    end
end

% find environment directories
[~,envInfo] = system('conda info -e');
userinfo.envRootDir=cell2mat(regexp(envInfo,'(?<=spykc                    ).+?(?=\n)','match'));
userinfo.envScriptDir=[userinfo.envRootDir userinfo.slash 'Scripts'];
userinfo.envLibDir=[userinfo.envRootDir userinfo.slash 'Library' userinfo.slash 'bin'];

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
                    'ccn-sommerserv.win.duke.edu'))
                userinfo.servrep=regexprep(connlist(servs(servl):carrets(find(carrets>servs(servl),1))-1),'[^\w\\|.|:|-'']','');
                userinfo.mapdr=userinfo.servrep(1:2);userinfo.servrep=userinfo.servrep(3:end);userinfo.servrep=regexprep(userinfo.servrep,'\\','/');
                break;
            end
        end
    end
else
    [userinfo.servrep,userinfo.mapdr]=deal([]);
end
end