function install_justify
% INSTALL_JUSTIFY Adds settings to the startup file and the folder to the MATLAB path

% Add path
folderpath = fileparts(mfilename('fullpath'));
addpath(folderpath)
savepath

% Add shortcut
s      = struct('label'   , 'justify',...
                'callback', 'justify',...
                'icon'    , fullfile(folderpath,'images','justify.jpg'),...
                'category', 'Shortcuts',...
                'editable', 'true');
su     = com.mathworks.mlwidgets.shortcuts.ShortcutUtils();
jArray = su.getShortcutsByCategory('Shortcuts');
nlab   = jArray.size();
it     = jArray.iterator();
labels = cell(nlab,1);
for ii = 1:nlab
    labels{ii} = char(it.next.getLabel());
end
if ~strcmp(s.label,labels)
    su.addShortcutToBottom(s.label, s.callback, s.icon, s.category, s.editable);
    pause(0.1)
end

% Add shortcut to Quick Access Bar
desktop  = com.mathworks.mde.desk.MLDesktop.getInstance();
QAB      = desktop.getQuickAccessConfiguration;
import com.mathworks.toolstrip.factory.*
toolPath = TSToolPath(TSToolPath('shortcuts','general'),'justify','matlab_shortcut_toolset');
if ~QAB.containsTool(toolPath)
    QAB.addTool(toolPath)
    QAB.setLabelVisible(toolPath,false)
end

% Set button mnemonic. Works only for current session :(
jDesktop   = desktop.getMainFrame();
buttonList = jDesktop.getQuickAccessBar().getComponent().getComponents();
for ii = numel(buttonList):-1:1
    if regexp(char(buttonList(ii).getName), s.label, 'once')
        buttonList(ii).setButtonMnemonic('j')
    end
end
end