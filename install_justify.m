function install_justify
% INSTALL_JUSTIFY Adds settings to the startup file and the folder to the MATLAB path

% Check if startup already exists
if exist('startup','file') == 2
    isnew = false;
    fullpath = which('startup.m');
else
    isnew = true;
    fullpath = fullfile(regexprep(userpath,';$',''), 'startup.m');
end

% Open to append
fid = fopen(fullpath, 'a+');
fseek(fid,0,'bof');
txt = textscan(fid, '%s','Delimiter','','EndOfLine','');
txt = txt{:};
fseek(fid,0,'eof');

% Check if already installed
if ~isnew && any(~cellfun('isempty', regexp(txt,'^%% justify_settings')))
    warning('install_justify:isinstalled','JUSTIFY appears to be already installed.')
    return
end

justifycommands = [...
    '%% justify_settings (this title is used as anchor, do NOT edit)\n'
];    

% Add justify startup commands to the startup file
txt = [txt; justifycommands];
fprintf(fid, '%s', txt);
fclose(fid);

% Add path
folderpath = fileparts(mfilename('fullpath'));
addpath(folderpath)
savepath

% Add shortcut
s = struct('label'   , 'justify',...
           'callback', 'justify',...
           'icon'    , fullfile(folderpath,'justify.jpg'),...
           'category', 'Shortcuts',...
           'editable', 'true');

com.mathworks.mlwidgets.shortcuts.ShortcutUtils.addShortcutToBottom(s.label, s.callback, s.icon, s.category, s.editable);

end