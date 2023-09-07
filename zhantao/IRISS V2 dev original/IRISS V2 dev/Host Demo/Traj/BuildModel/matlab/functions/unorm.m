function B = unorm(A)
% UNORM Normalizes all values of a matrix or vector to [0,1]
%
% EXAMPLE USAGE
% B = unorm(A); 
% 
% HISTORY
% 2021-02-10 Final version; MJG

% --- 

% force to double
A = double(A);

% Perform scaling; Form is:
% B = (A - min) / (max - min)
B = (A - min(A(:))) / (max(A(:)) - min(A(:)));

end
