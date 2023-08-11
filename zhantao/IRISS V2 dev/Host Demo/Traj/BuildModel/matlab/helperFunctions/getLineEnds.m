function ocline = getLineEnds(pupilCenter, ocdir, oclengths)
% 2021-10-04 MJG Matlab eye model GUI
% Gets 3d endpts for plotting the optical center of the eye; 
% lengths is an 1 x 2 array where lengths(1) is the dist UP (towards corn
% from the pc) and lengths(2) is the dist DOWN (towards the PC) from the pc

% scale the optical center by the [mm] half_length specified 
oc_top = oclengths(1) * ocdir;
oc_bot = - oclengths(2) * ocdir; % opposite the defined direction 

% get the end pts... 
ocline = [pupilCenter(1)+oc_top(1) pupilCenter(1)+oc_bot(1); 
          pupilCenter(2)+oc_top(2) pupilCenter(2)+oc_bot(2); 
          pupilCenter(3)+oc_top(3) pupilCenter(3)+oc_bot(3)];

end