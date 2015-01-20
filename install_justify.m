function install_justify
% INSTALL_JUSTIFY Adds settings to the startup file and the folder to the MATLAB path

% Add path
folderpath = fileparts(mfilename('fullpath'));
addpath(folderpath)
savepath

% Add shortcut
s  = struct('label'   , 'justify',...
           'callback', 'justify',...
           'icon'    , fullfile(folderpath,'justify.jpg'),...
           'category', 'Shortcuts',...
           'editable', 'true');
su = com.mathworks.mlwidgets.shortcuts.ShortcutUtils();
su.addShortcutToBottom(s.label, s.callback, s.icon, s.category, s.editable);

% Add shortcut to Quick Access Bar
% TODO: add only if does not exist
desktop  = com.mathworks.mde.desk.MLDesktop.getInstance();
QAB      = desktop.getQuickAccessConfiguration;
import com.mathworks.toolstrip.factory.*
toolPath = TSToolPath(TSToolPath('shortcuts','general'),'justify','matlab_shortcut_toolset');
QAB.addTool(toolPath)
QAB.setLabelVisible(toolPath,false)

% Set button mnemonic
% TODO: get component by full to0lname
jDesktop = desktop.getMainFrame();
jQAB     = jDesktop.getQuickAccessBar().getComponent();
jButton  = jQAB.getComponent(jQAB.getComponentCount-2);
jButton.setButtonMnemonic('10');

end