function [PolyCoef_cornea_mm_IRISSframe, PolyCoef_post_mm_IRISSframe, SurfacePolyOrd] = convert4mia(TOI_ACh, endo_pts_mm, pcfitpts_mm)
%convert4mia 2021-09-20 MJG 
% convert variables into the notation that Mia's traj. gen. script requires


% > PolyCoef_cornea_mm_IRISSframe
% The surface fit must be done in the {I} [mm] frame 
% Transform endo pts {O} [mm] to {I} [mm] 
endoXYZ_IRISS = [endo_pts_mm ones(size(endo_pts_mm,1),1)] * inv(TOI_ACh)';
% Redo the surface fit in the {I} [mm] frame 
sfIRISS = fit([endoXYZ_IRISS(:,1), endoXYZ_IRISS(:,2)], endoXYZ_IRISS(:,3), 'poly22');
% Compile variable with the poly22 coefficients 
PolyCoef_cornea_mm_IRISSframe = [sfIRISS.p00 sfIRISS.p10 sfIRISS.p01 sfIRISS.p20 sfIRISS.p11 sfIRISS.p02];

% > PolyCoef_post_mm_IRISSframe
% Likewise, for the PC surface, the fit must be done in the {I} [mm] frame
% Transform the PC {O}[mm] pts to {I} [mm]
% Note: We can use TOI_ACh here because the we only have one {O}
% frame/volume now
PCpts_IRISS = [pcfitpts_mm ones(size(pcfitpts_mm,1),1)] * inv(TOI_ACh)';
% then fit surface to these points... {IRISS} frame [mm]
surfPC_IRISS = fit([PCpts_IRISS(:,1), PCpts_IRISS(:,2)], PCpts_IRISS(:,3), 'poly22'); 
% Compile variable with the poly22 coefficients
PolyCoef_post_mm_IRISSframe = [surfPC_IRISS.p00 surfPC_IRISS.p10 surfPC_IRISS.p01 surfPC_IRISS.p20 surfPC_IRISS.p11 surfPC_IRISS.p02];


% > SurfacePolyOrd
% This value is always constant; it refers to the order of the poly fit 
SurfacePolyOrd = 2; 


end

