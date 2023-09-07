function [xACh, yACh, zACh, xIris, yIris, zIris, xPC, yPC, zPC] = visMdlInLV(SCAN_NO)

    cd('D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\allSaves');
    load(['allParams_' num2str(SCAN_NO, '%04i') '.mat']);

    % invert the CT from TOI to TIO
    TIO_AC = inv(TOI_ACh); 
    
    % convert the cornea points to the IRISS frame
    tmp = [corn_pts_mm ones(size(corn_pts_mm,1),1)] * TIO_AC';
    cornpts_iriss = tmp(:,1:3);
    
    % convert the iris points to the IRISS frame
    tmp = [pupil_pts_mm ones(size(pupil_pts_mm,1),1)] * TIO_AC';
    pupilpts_iriss = tmp(:,1:3);
    
    % convert the PC points to the IRISS frame
    tmp = [pcfitpts_mm ones(size(pcfitpts_mm,1),1)] * TIO_AC';
    pcfitpts_iriss = tmp(:,1:3);

    % downsample cornea points
    ratio = round(length(cornpts_iriss)/1000); 
    xACh = cornpts_iriss(:,1).';
    xACh = downsample(xACh, ratio); 
    yACh = cornpts_iriss(:,2).';
    yACh = downsample(yACh, ratio);
    zACh = cornpts_iriss(:,3).';
    zACh = downsample(zACh, ratio);

    % downsample iris points
    ratio = 1;
    xIris = pupilpts_iriss(:,1).';
    xIris = downsample(xIris, ratio); 
    yIris = pupilpts_iriss(:,2).';
    yIris = downsample(yIris, ratio);
    zIris = pupilpts_iriss(:,3).';
    zIris = downsample(zIris, ratio);
    
    % downsample PC fit points
    ratio = round(length(pcfitpts_iriss)/1000);  
    xPC = pcfitpts_iriss(:,1).';
    xPC = downsample(xPC, ratio); 
    yPC = pcfitpts_iriss(:,2).';
    yPC = downsample(yPC, ratio);
    zPC = pcfitpts_iriss(:,3).';
    zPC = downsample(zPC, ratio);
    

end