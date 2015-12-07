%% How it works 
% justify() pads with blanks the LHS of an assigment expression, e.g.
% A = rand(10), until all '=' (equal) signs of a block of code are aligned
% NOTE: all '=' signs will be surrounded by blanks, i.e. ' = ';
A = rand(10);
someVar=   A;
abcd=1;
B =magic(10);
10,12;
B == 1;

%% The alignment point is determined separately for each block of code
      A       =10;
myVar    = 20;

myVar2=1;
anotherVar=A(myVar2<=1-A);
% A comment alone does not split a block of code, you need an empty line
C = 20;

% This way you can scope a block of code by tasks while retaining some
% intermediate comments for clarity
fid=fopen('something.txt');
data   =   textscan(fid,'%f%f');
% Convert to matrix
data = cell2mat(data);

%% Control flow statements define their own block of code
B = rand(10);
var = NaN(1,10);
A=B;
for ii = 1:10
    % This block has its own alignment point
    var(:,ii) = sum(B(:,ii));
    A(:,ii)=B-var(:,ii);
end
% This is a new block too
result=A;