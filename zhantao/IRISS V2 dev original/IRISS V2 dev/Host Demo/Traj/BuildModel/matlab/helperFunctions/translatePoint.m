function newpt = translatePoint(p, v, d)
%2021-10-06 MJG Shift a point p (3x1) along unit direction v (3x1) by
%scalar distance d (1x1) 

% ensure unit direction
v = v / norm(v);

% ensure distance is positive 
d = abs(d); 

% --- 

newpt = p + d * v;

 


end