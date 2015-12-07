function smartIndent(filename, mode)
% SMARTINDENT Programmatic smart indentation and removal of unnecessary whitespace
%
%   SMARTINDENT(FILENAME,[MODE])
%       Indents currently active document if FILENAME is empty or not
%       specified. FILENAME must be the name of an open document in the
%       editor
%
%       MODE specifies the smart indentation format and can be:
%           - 'Classic' [default]
%           - 'All'
%           - 'Mixed'
%       For examples on the mode see <a href="http://blogs.mathworks.com/community/2009/05/11/keep-your-code-readable-with-smart-indenting/">Smart Indent</a>.
%
%   Rules:
%       - Smart-indent
%       - Remove whitespace in empty lines
%       - Preserve indentantion after line continuations (...)
%
% See also: JUSTIFY

% Author: Oleg Komarov (oleg dot komarov at hotmail dot it)
% License: BSD 3-clause
% Tested on R2014a Win7 64bit
% 2015 Dec 07 - created

import matlab.desktop.editor.*
if nargin < 1 || isempty(filename), filename = ''; end
if nargin < 2 || isempty(mode)
    mode = 'ClassicFunctionIndent';
else
    mode = validatestring(mode, {'ClassicFunctionIndent','AllFunctionIndent','MixedFunctionIndent'});
end

d        = getDoc(filename);
oldLines = textToLines(d.Text);

% Smart indent as AllFunctionIndent
% Using undocumented feature from http://undocumentedmatlab.com/blog/changing-system-preferences-programmatically
editorProp      = 'EditorMFunctionIndentType';
oldVal          = com.mathworks.services.Prefs.getStringPref(editorProp);
com.mathworks.services.Prefs.setStringPref(editorProp, mode);
restoreSettings = onCleanup(@() com.mathworks.services.Prefs.setStringPref(editorProp, oldVal));
d.smartIndentContents()

% Preserve crafted continuations of line
lines         = textToLines(d.Text);
iContinuation = ~cellfun('isempty',strfind(lines, '...'));
iComment      = ~cellfun('isempty',regexp(lines, '^ *%([^%]|$)','once'));
pAfterDots    = find(iContinuation & ~iComment)+1;
for ii = 1:numel(pAfterDots)
    % Carry over the change in space due to smart-indenting from the
    % first continuation line to the last
    p            = pAfterDots(ii);
    nWhiteBefore = find(~isspace(oldLines{p-1}),1,'first');
    nWhiteAfter  = find(~isspace(lines{p-1}),1,'first');
    df           = nWhiteAfter - nWhiteBefore;
    if df > 0
        lines{p} = [blanks(df) oldLines{p}];
    elseif df < 0
        df       = min(abs(df)+1, find(~isspace(oldLines{p}),1,'first'));
        lines{p} = oldLines{p}(df:end);
    else
        lines{p} = oldLines{p};
    end
end

% Remove whitespace lines
idx        = cellfun('isempty',regexp(lines, '[^ \t\n]','once'));
lines(idx) = {''};

d.Text = linesToText(lines);
end

function d = getDoc(filename)
import matlab.desktop.editor.*

if ~ischar(filename)
    error('formatWhitespace:charFilename','The FILENAME should be a char.')
end

try
    isEditorAvailable();
catch
    error('formatWhitespace:noEditorApi','Check that the Editor API is available.')
end

if isempty(filename)
    d = getActive();
else
    % TODO: open file if it isn't open in the editor already
    d = findOpenDocument(filename);
    try
        [~,filenameFound] = fileparts(d.Filename);
    catch
        filenameFound = '';
    end
    isExactMatch = strcmp(filename, filenameFound);
    if ~isExactMatch
        error('formatWhitespace:filenameNotFound','Filename "%s" not found in the editor.', filename)
    end
end
end