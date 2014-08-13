% Get active document
obj = matlab.desktop.editor.getActive;
text  = obj.Text;
lines = matlab.desktop.editor.textToLines(text);

% Sandwich lines between two empty ones
lines = [{''}; lines; {''}];
nlines = numel(lines);

% Empty line idx
lineno.Empty = cellfun('isempty',regexp(lines, '[^ \n]','once'));

% Comment line idx
lineno.Comment = ~cellfun('isempty',regexp(lines, '^ *%','once'));

% Char index
chidx = repmat('c',nlines,1);
chidx(lineno.Empty) = ' ';
chidx(lineno.Comment) = '%';

% Create blocks
ii = 1;
fromto = zeros(2, ceil(nlines/2));
b = 1;
cblock = true;
while ii < nlines
    ii = ii + 1;
    if cblock
        if chidx(ii) == 'c'
            fromto(1,b) = ii;
            cblock = false;
        end
    elseif chidx(ii) == ' '
        fromto(2,b) = ii-1;
        b = b + 1;
        cblock = true;
    end
end
fromto = fromto(:,fromto(1,:)~=0 & diff(fromto) > 0);

% Strip lines of the bread/padding
lines = lines(2:end-1);
fromto(1,:) = fromto(1,:)-1;

% Get line numbers of assignments
tree = mtree(text);
tree = tree.asgvars;
lineno.Assign = tree.lineno;

% Tag assignments with their block
[counts, subs] = histc(lineno.Assign, fromto(:));
for ii = 1:2:size(fromto,2)
    idx = subs == ii;
    linepos = lineno.Assign(idx);
    tmp = lines(linepos);
    tmp = regexprep(tmp,' *= *',' = ','once');
    if counts(ii) > 1
        pos    = regexp(tmp,'=','once');
        maxp   = max([pos{:}])-1;
        repstr = sprintf('${[repmat('' '',1,%d-numel($`)) ''='']}',maxp);
        tmp    = regexprep(tmp, '=',repstr,'once');
    end
    lines(linepos) = tmp;
end
obj.Text = matlab.desktop.editor.linesToText(lines);