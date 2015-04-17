function justify
% JUSTIFY Justifies blocks of code
%
%
%

% Author: Oleg Komarov (oleg.komarov@hotmail.it) 
% Tested on R2014a Win7 64bit
% 2014 Aug 14 - created

% Get active document
obj   = matlab.desktop.editor.getActive;
text  = obj.Text;
lines = matlab.desktop.editor.textToLines(text);

% Get cursor position
sel = obj.Selection;

% Sandwich lines between two empty ones (need it for blocks creation)
lines  = [{''}; lines; {''}];
nlines = numel(lines);

% Parse file into a tree
tree = mtree(text);

% Kerywords idx (ELSEIF separately)
lineno.Keywords      = false(nlines,1);
keywords             = {'IF','ELSE','TRY','CATCH','WHILE','FOR','PARFOR','FUNCTION','CASE','OTHERWISE'};
tmp                  = tree.mtfind('Kind',keywords);
pos                  = [tmp.lineno; tmp.lastone];
tmp                  = tree.mtfind('Kind','ELSEIF');
pos                  = [pos; tmp.lineno; tmp.previous.lastone] + 1;
lineno.Keywords(pos) = true;

% Empty line idx
lineno.Empty = cellfun('isempty',regexp(lines, '[^ \n]','once'));

% Comment line idx
lineno.Comment = ~cellfun('isempty',regexp(lines, '^ *%[^%]','once'));

% Double %%
lineno.Cell = ~cellfun('isempty',regexp(lines, '^ *%%','once'));

% Char index
chidx                  = repmat('c',nlines,1);
chidx(lineno.Keywords) = ' ';
chidx(lineno.Empty)    = ' ';
chidx(lineno.Cell)     = ' ';
chidx(lineno.Comment)  = '%';

% Create blocks
ii     = 1;
fromto = zeros(2, ceil(nlines/2));
b      = 1;
cblock = true;
while ii < nlines
    ii = ii + 1;
    if cblock
        if chidx(ii) == 'c'
            fromto(1,b) = ii;
            cblock      = false;
        end
    elseif chidx(ii) == ' '
        fromto(2,b) = ii;
        b           = b + 1;
        cblock      = true;
    end
end
fromto = fromto(:,fromto(1,:)~=0 & diff(fromto) > 1);

% Get line numbers of assignments
lineno.Assign         = false(nlines,1);
asgpos                = tree.asgvars.lineno + 1;
lineno.Assign(asgpos) = true;

% Bring all assignment to 'LHS = RHS'
idx        = lineno.Assign & chidx == 'c';
lines(idx) = regexprep(lines(idx),' *= *',' = ','once');

% LOOP by block and justify
[counts, subs] = histc(asgpos, fromto(:));
for ii = 1:2:size(fromto,2)*2
    if counts(ii) > 0
        linepos = asgpos(subs == ii);
        tmp     = lines(linepos);
        if counts(ii) > 1
            pos    = regexp(tmp,'=','once');
            maxp   = max([pos{:}])-1;
            repstr = sprintf('${[repmat('' '',1,%d-numel($`)) ''='']}',maxp);
            tmp    = regexprep(tmp, '=',repstr,'once');
        end
        lines(linepos) = tmp;
    end
end
obj.Text = matlab.desktop.editor.linesToText(lines(2:end-1));

% Restore cursor position
obj.insertTextAtPositionInLine('',sel(1),sel(2));
end