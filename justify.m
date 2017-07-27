function justify()
% JUSTIFY Improves readability of your code
%
% Positions the assignments (=) in a block of code at a common distance.
%
% Short example. This block of code
%
%     a = 1:10;
%     myVar = a*10-10;
%     mySum=a + myVar;
%
% becomes the following
%
%     a     = 1:10;
%     myVar = a*10-10;
%     mySum = a + myVar;
%
% For a full description of the padding rules, see justify_example.m
%
% See also: JUSTIFY_EXAMPLE

% Author: Oleg Komarov (oleg dot komarov at hotmail dot it)
% License: BSD 3-clause
% Tested on R2014a Win7 64bit
% 2014 Aug 14 - created

% Get active document
obj = matlab.desktop.editor.getActive;
if isempty(obj)
    return
end
text  = obj.Text;
lines = matlab.desktop.editor.textToLines(text);

% Get cursor position
sel = obj.Selection;

% Sandwich lines between two empty ones (need it for blocks creation)
lines  = [{''}; lines; {''}];
nlines = numel(lines);

% Parse file into a tree
tree = mtree(text);

% Check for mlint error
if ~isempty(tree.mtfind('Kind','ERR'))
    [~,name,ext] = fileparts(obj.Filename);
    warning('justify:mlintError','''%s'' contains syntax errors. Cannot proceed.',[name,ext])
    return
end

% Keywords idx (ELSEIF separately)
lineno.Keywords         = false(nlines,1);
keywords                = {'IF','ELSE','TRY','CATCH','WHILE','FOR','PARFOR','FUNCTION','SWITCH','CASE','OTHERWISE','PROPERTIES'};
tmp                     = tree.mtfind('Kind',keywords);
keypos                  = [tmp.lineno; tmp.lastone];
tmp                     = tree.mtfind('Kind','ELSEIF');
keypos                  = [keypos; tmp.lineno; tmp.previous.lastone] + 1;
lineno.Keywords(keypos) = true;

% Empty line idx
lineno.Empty = cellfun('isempty',regexp(lines, '[^ \n]','once'));

% Comment line idx
lineno.Comment = ~cellfun('isempty',regexp(lines, '^ *%([^%]|$)','once'));

% Double %%
lineno.Cell = ~cellfun('isempty',regexp(lines, '^ *%%','once'));

% Code lines index
chidx                  = repmat('c',nlines,1);
chidx(lineno.Keywords) = ' ';
chidx(lineno.Empty)    = ' ';
chidx(lineno.Cell)     = ' ';
chidx(lineno.Comment)  = '%';

% Create blocks
[from,to] = deal(zeros(1, ceil(nlines/2)));
ii        = 1;
b         = 1;
codeBlock = true;
while ii < nlines
    ii = ii + 1;
    if codeBlock
        if chidx(ii) == 'c'
            from(b)   = ii;
            codeBlock = false;
        end
    elseif chidx(ii) == ' '
        to(b)     = ii;
        b         = b + 1;
        codeBlock = true;
    end
end
multiLine = from ~= 0 & (to-from) > 1;
from      = from(multiLine);
to        = to(multiLine);

% Get line numbers of assignments
lineno.Assign          = false(nlines,1);
tmp                    = tree.mtfind('Kind','EQUALS');
asgline                = tmp.lineno + 1;
lineno.Assign(asgline) = true;

% Bring all assignment to 'LHS = RHS'
idx        = lineno.Assign & chidx == 'c';
expr       = {' *'              %   match leading white spaces
              '(?<=[^~<>=])'    %   avoid matching <=, >=, ==, ~=
              '='               %   match =
              '(?=[^=])'        %   avoid matching ==
              ' *'};            %   matching trailing white spaces
lines(idx) = regexprep(lines(idx),[expr{:}],' = ','once');

% LOOP by block and justify
expr = [expr{2:end-1}];
N    = size(from,2);
for ii = 1:N
    idx     = from(ii) <= asgline & asgline < to(ii);
    linepos = asgline(idx);
    tmp     = lines(linepos);
    asgpos  = regexp(tmp,expr,'once');
    asgpos  = [asgpos{:}];
    if isempty(asgpos)
        continue
    end
    % Pre-pad '=' with blanks to have a common alignment point
    padlen = max(asgpos) - asgpos;
    for r = 1:size(tmp,1)
        if padlen(r) > 0
            tmp{r} = [tmp{r}(1:asgpos(r)-1),...
                      repmat(' ',1,padlen(r)),...
                      tmp{r}(asgpos(r):end)];
        end
    end
    lines(linepos) = tmp;
end
obj.Text = matlab.desktop.editor.linesToText(lines(2:end-1));

% Restore cursor position
obj.insertTextAtPositionInLine('',sel(1),sel(2));
end