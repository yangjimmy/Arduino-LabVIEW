function segim = runSegmentation(SDIR, SCAN_NO_ACh, model_filename, vscan)
%runSegmentation 2021-09-20 MJGl 
% check if the segim.mat exists
% > if it does, use it
% > if not, run the model on the data (takes a long time)
% NOTE: If this code is too slow, you an experiment with increasing the
% "MiniBatchSize" in the semanticseg---it should be able to go higher

% add trailing slash if not specified 
if SDIR(end) ~= filesep; SDIR(end+1) = filesep; end 

% build path to segmentation file 
segfile = [SDIR 'segim' num2str(SCAN_NO_ACh,'%04i') '.mat'];

% check if this vscan has already been segmented---if so, just load the
% results; if not, then need to segment the data using the trained model
if exist(segfile, 'file')
    load(segfile, 'segim'); 
else
    % load the trained model
    load(model_filename, 'net');
    % convert the vscan to the format the model expects (model was trained on actual images)
    cscan = uint8(255 * vscan);
    % convert 3d matrix to 4d; in prep for the segmentation
    cscan = permute(cscan, [1 2 4 3]);
    % Perform the actual inference/segmentation (takes awhile).
    % Note: you should be able to crank up the minibatchsize some more
    segim = semanticseg(cscan, net, 'OutputType', 'uint8', 'MiniBatchSize', 8); 
    % Save the results so we don't have to do this again
    save(segfile, 'segim'); 
end


end

