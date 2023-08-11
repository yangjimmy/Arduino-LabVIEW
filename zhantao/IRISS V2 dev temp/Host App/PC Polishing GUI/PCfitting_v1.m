% 2021-10-30 MJG
% Segment and model the PC with glue 

% add directory of helper functions 
addpath('D:\Kevin\IRISS V2 dev\Host App\PC Polishing GUI\supportFunctions');

% file to save PC surf fit to...
SAVEFILE = 'D:\Kevin\IRISS V2 dev\Host App\PC Polishing GUI\PCfit.mat';

% directory to save screenshots, etc. 
SDIR = cdir('D:\Kevin\IRISS V2 dev\Host App\PC Polishing GUI\saves');

% Directory containing the .raw, .toi, and .srm files saved by LabView
DDIR = 'D:\Kevin\IRISS V2 dev\Host Demo\PreOpVscans\';

% filename/path of Intensity.data file (or .raw file)
% 1, 7, 8, 9, 11
SCAN_NO = 4;
oct_filename = 'D:\Kevin\IRISS V2 dev\Host App\PC Polishing GUI\test_data\Intensity_0009.data';
% oct_filename = [DDIR 'Model3D_' num2str(SCAN_NO, '%04i') '.raw'];

% Load OCTz and TOI vals from the SRM and TOI files 
[OCTz, TOI] = readScanData(SCAN_NO, DDIR);

% ---

% load the vscan 
vscan = getvscan(oct_filename);

% only the top 4 mm; truncate/crop
vscan = vscan(1:436, :, :);

% scale intensity data to regular ranges 
vscan = scalevscan(vscan);

% hard convert to binary; dumb but easy 
pcloud = vscan > 0.6;

% retain largest 3d binary blob... 
pcloud = retainLargest3Dblob(pcloud);

% convert binary pcloud to xyz coordinates 
[z, x, y] = ind2sub(size(pcloud), find(pcloud));

% downsample the points and convert to [mm] (this only used in plotting)
xyz_mm_ds = ds4plot(pcloud) .* [0.025 0.025 0.0092];


% -- PC "detection" ---
% find the bottom-most point in each col of the pcloud
cs = squeeze(sum(logical(cumsum(flipud(pcloud)))));

% gen array of X Y
[Y, X] = meshgrid(1:400, 1:400);

% convert to xyz nx3 array
pcxyz = [X(:) Y(:) cs(:)];

% remove zero entries 
pcxyz(pcxyz(:,3)==0,:) = [];

% convert to [mm]
pcxyz_mm = pcxyz .* [0.025 0.025 0.0092];

% convert points from {O} to {I}
TIO = inv(TOI);
N = length(pcxyz_mm);
iriss_pcxyz_mm = (TIO * [pcxyz_mm.'; ones(1,N)]).';

% plot data in {I} frame and see...
figure(4);
scatter3(iriss_pcxyz_mm(:,1), iriss_pcxyz_mm(:,2), iriss_pcxyz_mm(:,3), 1, [0 0 0], 'Marker', '.'); hold on;
xlabel('x [mm]'); ylabel('y [mm]'); zlabel('z [mm]');
grid on; grid minor;

% --- ellipse stuff (unused; Kevin's PC polish traj gen requires a poly22 surf fit) 
% fit ellipse (3d party function)
% [center, radii, ~, ~, ~] = ellipsoid_fit(pcxyz_mm, 'xy');
% gen xyz data without plotting the ellipse
% [Xdata, Ydata, Zdata] = ellipsoid(center(1), center(2), center(3), radii(1), radii(2), radii(3));

% fit poly22 surface to PC points {O}
fitPC = fit([pcxyz_mm(:,1), pcxyz_mm(:,2)], pcxyz_mm(:,3), 'poly22');
% save backup for the purpose of GUI reset... 
fitParams = [fitPC.p00 fitPC.p10 fitPC.p01 fitPC.p20 fitPC.p11 fitPC.p02];

% fit poly22 surface to PC points {I}
[iriss_fitPC, gof, output] = fit([iriss_pcxyz_mm(:,1), iriss_pcxyz_mm(:,2)], iriss_pcxyz_mm(:,3), 'poly22');
iriss_fitParams = [iriss_fitPC.p00 iriss_fitPC.p10 iriss_fitPC.p01 ...
    iriss_fitPC.p20 iriss_fitPC.p11 iriss_fitPC.p02];

% -- get range of XY points for surf fit plotting 
% this is mostly just down so the plot will look nicer 
centerPC = mean([pcxyz_mm(:,1) pcxyz_mm(:,2)]);
iriss_centerPC = mean([iriss_pcxyz_mm(:,1) iriss_pcxyz_mm(:,2)]);
% how far to each side to plot (too far will look weird/bad) 
edge = 4;
inc = 0.1;
% build XY values 
[Xpc, Ypc] = meshgrid(centerPC(1)-edge:inc:centerPC(1)+edge, centerPC(2)-edge:inc:centerPC(2)+edge);
% calc Z at each XY value 
Zpc = fitPC(Xpc, Ypc);


% ---------------------
% Build GUI 
% ---------------------

% create app window; hide until all components are built
f = uifigure('Visible', 'off');
f.Position = [100 100 1189 803];
f.Name = 'PC Detection v1.0';

% Create GridLayout
GridLayout = uigridlayout(f);
GridLayout.ColumnWidth = {15, 75, 50, '1.15x', '1x', 25, 32, 20, '19.71x'};
GridLayout.RowHeight = {25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, '1x'};
GridLayout.RowSpacing = 6;
GridLayout.Padding = [10 6.65625 10 6.65625];

% Create figure
fig = uiaxes(GridLayout);
xlabel(fig, 'x [mm]')
ylabel(fig, 'y [mm]')
zlabel(fig, 'z [mm]')
fig.View = [45 20];
fig.ZDir = 'reverse';
fig.XGrid = 'on';
fig.YGrid = 'on';
fig.ZGrid = 'on';
fig.Layout.Row = [2 25];
fig.Layout.Column = 9;
% apply plot limits 
fig.XLim = [0 10];
fig.YLim = [0 10];
fig.ZLim = [0 4];
% set axis equal 
set(fig, 'DataAspectRatio', [1 1 1]);

% plot initial data 
hold(fig, 'on');

% PC surf
hpcsurf = surf(fig, Xpc, Ypc, Zpc, 'FaceColor', [0.55 0.59 0.82], 'EdgeAlpha', 0, 'FaceAlpha', 0.3); hold on;

% PC data pts 
hp = scatter3(fig, xyz_mm_ds(:,1), xyz_mm_ds(:,2), xyz_mm_ds(:,3), 1, [0 0 0], 'Marker', '.'); hold on;
set(hp, 'MarkerEdgeAlpha', 0.2, 'MarkerFaceAlpha', 0);

% pts used in fitting the PC 
hpc = scatter3(fig, pcxyz_mm(:,1), pcxyz_mm(:,2), pcxyz_mm(:,3), 1, [1 0 0], 'Marker', '.'); hold on;
set(hpc, 'MarkerEdgeAlpha', 0.1, 'MarkerFaceAlpha', 0);

figure(1); clf;
scatter3(xyz_mm_ds(:,1), xyz_mm_ds(:,2), xyz_mm_ds(:,3), 1, [0 0 0], 'Marker', '.', 'MarkerEdgeAlpha', 0.2, 'MarkerFaceAlpha', 0); hold on;
scatter3(pcxyz_mm(:,1), pcxyz_mm(:,2), pcxyz_mm(:,3), 1, [1 0 0], 'Marker', '.', 'MarkerEdgeAlpha', 0.1, 'MarkerFaceAlpha', 0); hold on;
surf(Xpc, Ypc, Zpc, 'FaceColor', [0.55 0.59 0.82], 'EdgeAlpha', 0, 'FaceAlpha', 0.3); hold on;
set(gca, 'ZDir', 'reverse');
xlim([0 10]); ylim([0 10]); zlim([0 4]);
legend('Volume scan data points', 'PC data points', 'PC surface fit');
xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Z [mm]');
axis equal; grid on; grid minor;

% PC as ellipse
% hcb = surf(fig, Xdata, Ydata, Zdata, 'LineStyle', 'none', 'FaceAlpha', 0.3, 'FaceColor', [0 0.4470 0.7410]);

% ----------------



% ----------------
% GUI Labels (Static)
% ----------------

% PC fit params 
label_pupilCenter = uilabel(GridLayout, 'Text', 'PC Fit Params', 'FontWeight', 'bold');
label_pupilCenter.VerticalAlignment = 'bottom';
label_pupilCenter.Layout.Row = 4;
label_pupilCenter.Layout.Column = [1 2];

% p00
label_X1 = uilabel(GridLayout, 'Text', '00', 'FontWeight', 'bold');
label_X1.HorizontalAlignment = 'center';
label_X1.Layout.Row = 5;
label_X1.Layout.Column = 1;
% p10
label_Y1 = uilabel(GridLayout, 'Text', '10', 'FontWeight', 'bold');
label_Y1.HorizontalAlignment = 'center';
label_Y1.Layout.Row = 6;
label_Y1.Layout.Column = 1;
% p01
label_Z1 = uilabel(GridLayout, 'Text', '01', 'FontWeight', 'bold');
label_Z1.HorizontalAlignment = 'center';
label_Z1.Layout.Row = 7;
label_Z1.Layout.Column = 1;
% p20
label_X2 = uilabel(GridLayout, 'FontWeight', 'bold', 'Text', '20');
label_X2.HorizontalAlignment = 'center';
label_X2.Layout.Row = 9;
label_X2.Layout.Column = 1;
% p11
label_Y2 = uilabel(GridLayout, 'FontWeight', 'bold', 'Text', '11');
label_Y2.HorizontalAlignment = 'center';
label_Y2.Layout.Row = 10;
label_Y2.Layout.Column = 1;
% p02
label_Z2 = uilabel(GridLayout, 'FontWeight', 'bold', 'Text', '02');
label_Z2.HorizontalAlignment = 'center';
label_Z2.Layout.Row = 11;
label_Z2.Layout.Column = 1;
% system controls 
label_SystemControls = uilabel(GridLayout, 'Text', 'System Controls', 'FontWeight', 'bold');
label_SystemControls.Layout.Row = 19;
label_SystemControls.Layout.Column = [1 2];
% % PC orientation 
% label_bagParams = uilabel(GridLayout, 'Text', 'PC Orientation', 'FontWeight', 'bold');
% label_bagParams.Layout.Row = 13;
% label_bagParams.Layout.Column = [1 3];
% system status 
label_systemStatus = uilabel(GridLayout, 'Text', 'System Status');
label_systemStatus.VerticalAlignment = 'bottom';
label_systemStatus.Layout.Row = 22;
label_systemStatus.Layout.Column = [1 2];
% plot label 
label_plotTitle = uilabel(GridLayout, 'FontWeight', 'bold');
label_plotTitle.HorizontalAlignment = 'center';
label_plotTitle.Layout.Row = 1;
label_plotTitle.Layout.Column = 9;
label_plotTitle.Text = ['Model Fit for PC Polishing; {OCT} [mm]'];

% --------------------------
% GUI Displays 
% --------------------------

% display: p00
disp00 = uieditfield(GridLayout, 'numeric', 'Editable', 'off');
disp00.Layout.Row = 5;
disp00.Layout.Column = [5 6];
disp00.Value = fitPC.p00;

% display: p10
disp10 = uieditfield(GridLayout, 'numeric', 'Editable', 'off');
disp10.Layout.Row = 6;
disp10.Layout.Column = [5 6];
disp10.Value = fitPC.p10;

% display: p01
disp01 = uieditfield(GridLayout, 'numeric', 'Editable', 'off');
disp01.Layout.Row = 7;
disp01.Layout.Column = [5 6];
disp01.Value = fitPC.p01;

% display: p20
disp20 = uieditfield(GridLayout, 'numeric', 'Editable', 'off');
disp20.Layout.Row = 9;
disp20.Layout.Column = [5 6];
disp20.Value = fitPC.p20;

% display: p11
disp11 = uieditfield(GridLayout, 'numeric', 'Editable', 'off');
disp11.Layout.Row = 10;
disp11.Layout.Column = [5 6];
disp11.Value = fitPC.p11;

% --- display: p02
disp02 = uieditfield(GridLayout, 'numeric', 'Editable', 'off');
disp02.Layout.Row = 11;
disp02.Layout.Column = [5 6];
disp02.Value = fitPC.p02;

% "System Status" box
statusBox = uitextarea(GridLayout, 'Editable', 'off');
statusBox.Layout.Row = [23 25];
statusBox.Layout.Column = [1 7];

% --------------------------
% GUI Controls (Sliders)
% --------------------------

% slider ranges 
lims1 = 1;
lims2 = 0.01;

% --- slider: p00
uip00 = uislider(GridLayout);
uip00.MajorTickLabels = {''};
uip00.Layout.Row = 5;
uip00.Layout.Column = [2 4];
uip00.Limits = [fitPC.p00-lims1 fitPC.p00+lims1];
uip00.Value = fitPC.p00;
tiPupCentX = (uip00.Limits(2)-uip00.Limits(1)) / 4;
uip00.MajorTicks = uip00.Limits(1):tiPupCentX:uip00.Limits(2);
uip00.MajorTickLabels = {''};

% --- slider: p10
uip10 = uislider(GridLayout);
uip10.MajorTickLabels = {''};
uip10.Layout.Row = 6;
uip10.Layout.Column = [2 4];
uip10.Limits = [fitPC.p10-lims1 fitPC.p10+lims1];
uip10.Value = fitPC.p10;
tiPupCentY = (uip10.Limits(2)-uip10.Limits(1)) / 4;
uip10.MajorTicks = uip10.Limits(1):tiPupCentY:uip10.Limits(2);
uip10.MajorTickLabels = {''};

% --- slider: p01
uip01 = uislider(GridLayout);
uip01.MajorTickLabels = {''};
uip01.Layout.Row = 7;
uip01.Layout.Column = [2 4];
uip01.Limits = [fitPC.p01-lims1 fitPC.p01+lims1];
uip01.Value = fitPC.p01;
tiPupCentZ = (uip01.Limits(2)-uip01.Limits(1)) / 4;
uip01.MajorTicks = uip01.Limits(1):tiPupCentZ:uip01.Limits(2);
uip01.MajorTickLabels = {''};

% --- slider: p20
uip20 = uislider(GridLayout);
uip20.Layout.Row = 9;
uip20.Layout.Column = [2 4];
uip20.Limits = [fitPC.p20-lims2 fitPC.p20+lims2];
uip20.Value = fitPC.p20;
tiPupRotX = (uip20.Limits(2)-uip20.Limits(1)) / 4;
uip20.MajorTicks = uip20.Limits(1):tiPupRotX:uip20.Limits(2);
uip20.MajorTickLabels = {''};

% --- slider: p11
uip11 = uislider(GridLayout);
uip11.MajorTickLabels = {''};
uip11.Layout.Row = 10;
uip11.Layout.Column = [2 4];
uip11.Limits = [fitPC.p11-lims2 fitPC.p11+lims2];
uip11.Value = fitPC.p11;
tiPupRotY = (uip11.Limits(2)-uip11.Limits(1)) / 4;
uip11.MajorTicks = uip11.Limits(1):tiPupRotY:uip11.Limits(2);
uip11.MajorTickLabels = {''};

% --- slider: p02
uip02 = uislider(GridLayout);
uip02.MajorTickLabels = {''};
uip02.Layout.Row = 11;
uip02.Layout.Column = [2 4];
uip02.Limits = [fitPC.p02-lims2 fitPC.p02+lims2];
uip02.Value = fitPC.p02;
tiPupRotZ = (uip02.Limits(2)-uip02.Limits(1)) / 4;
uip02.MajorTicks = uip02.Limits(1):tiPupRotZ:uip02.Limits(2);
uip02.MajorTickLabels = {''};

% --------------------------
% GUI Controls (Buttons, etc.)
% --------------------------

% Create ResetModelButton
ResetModelButton = uibutton(GridLayout, 'push', 'Text', 'Reset Model');
ResetModelButton.Layout.Row = 20;
ResetModelButton.Layout.Column = [1 3];

% Create SaveModelButton
SaveModelButton = uibutton(GridLayout, 'push', 'Text', 'Save PC Fit', 'FontWeight', 'bold');
SaveModelButton.Layout.Row = [20 21];
SaveModelButton.Layout.Column = [5 7];

% Create SavePNGofGUIButton
SavePNGofGUIButton = uibutton(GridLayout, 'push', 'Text', 'Save PNG of GUI');
SavePNGofGUIButton.Layout.Row = 21;
SavePNGofGUIButton.Layout.Column = [1 3];

% Toggle switch for OC direction 
% uiToggleOC = uiswitch(GridLayout, 'slider', 'Items', {'+', '-'}, 'Value', '+');
% uiToggleOC.Layout.Row = 13;
% uiToggleOC.Layout.Column = [5 6];

% Show the figure after all components are created
f.Visible = 'on';

% define callback functions 
uip00.ValueChangingFcn = @p00change;
uip10.ValueChangingFcn = @p10change;
uip01.ValueChangingFcn = @p01change;
uip20.ValueChangingFcn = @p20change;
uip11.ValueChangingFcn = @p11change;
uip02.ValueChangingFcn = @p02change;
SavePNGofGUIButton.ButtonPushedFcn = @savePNGofGUI;
ResetModelButton.ButtonPushedFcn = @resetModel;
% uiToggleOC.ValueChangedFcn = @toggleBagDirection;
SaveModelButton.ButtonPushedFcn = @saveModelParams;

% store all handles to plots, GUI elements, labels, etc. in the userData
% element of the overall gui figure f 
f.UserData = struct(...
    "hp", hp, ...
    "hpc", hpc, ...
    "hpcsurf", hpcsurf, ...
    "disp00", disp00, ...
    "disp10", disp10, ...
    "disp01", disp01, ...
    "uip00", uip00, ...
    "uip10", uip10, ...
    "uip01", uip01, ...
    "disp20", disp20, ...
    "disp11", disp11, ...
    "disp02", disp02, ...
    "uip20", uip20, ...
    "uip11", uip11, ...
    "uip02", uip02, ...
    "statusBox", statusBox, ...
    "fitPC", fitPC, ...
    "Xpc", Xpc, ...
    "Ypc", Ypc, ...
    "Zpc", Zpc, ...
    "fitParams", fitParams, ...
    "SAVEFILE", SAVEFILE, ...
    "SDIR", SDIR, ...
    "oct_filename", oct_filename, ...
    "iriss_pcxyz_mm", iriss_pcxyz_mm, ...
    "iriss_fitParams", iriss_fitParams, ...
    "iriss_centerPC", iriss_centerPC, ...
    "toi", TOI);


% p00
function p00change(src, event)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % update display
    d.disp00.Value = event.Value;
    % get fit params; nota
    fp = [d.disp00.Value d.disp10.Value d.disp01.Value d.disp20.Value d.disp11.Value d.disp02.Value];
    % update surf fit plot with new Z calc'd at each XY value ..
    d.hpcsurf.ZData = fp(1) + fp(2) .* d.Xpc + fp(3) .* d.Ypc + fp(4) .* d.Xpc.^2 + fp(5) .* d.Xpc .* d.Ypc + fp(6) .* d.Ypc.^2;
end

% p10
function p10change(src, event)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % update display
    d.disp10.Value = event.Value;
    % get fit params; nota
    fp = [d.disp00.Value d.disp10.Value d.disp01.Value d.disp20.Value d.disp11.Value d.disp02.Value];
    % update surf fit plot with new Z calc'd at each XY value ..
    d.hpcsurf.ZData = fp(1) + fp(2) .* d.Xpc + fp(3) .* d.Ypc + fp(4) .* d.Xpc.^2 + fp(5) .* d.Xpc .* d.Ypc + fp(6) .* d.Ypc.^2;
end

% p01
function p01change(src, event)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % update display
    d.disp01.Value = event.Value;
    % get fit params; nota
    fp = [d.disp00.Value d.disp10.Value d.disp01.Value d.disp20.Value d.disp11.Value d.disp02.Value];
    % update surf fit plot with new Z calc'd at each XY value ..
    d.hpcsurf.ZData = fp(1) + fp(2) .* d.Xpc + fp(3) .* d.Ypc + fp(4) .* d.Xpc.^2 + fp(5) .* d.Xpc .* d.Ypc + fp(6) .* d.Ypc.^2;
end

% p20
function p20change(src, event)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % update display
    d.disp20.Value = event.Value;
    % get fit params; nota
    fp = [d.disp00.Value d.disp10.Value d.disp01.Value d.disp20.Value d.disp11.Value d.disp02.Value];
    % update surf fit plot with new Z calc'd at each XY value ..
    d.hpcsurf.ZData = fp(1) + fp(2) .* d.Xpc + fp(3) .* d.Ypc + fp(4) .* d.Xpc.^2 + fp(5) .* d.Xpc .* d.Ypc + fp(6) .* d.Ypc.^2;
end

% p11
function p11change(src, event)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % update display
    d.disp11.Value = event.Value;
    % get fit params; nota
    fp = [d.disp00.Value d.disp10.Value d.disp01.Value d.disp20.Value d.disp11.Value d.disp02.Value];
    % update surf fit plot with new Z calc'd at each XY value ..
    d.hpcsurf.ZData = fp(1) + fp(2) .* d.Xpc + fp(3) .* d.Ypc + fp(4) .* d.Xpc.^2 + fp(5) .* d.Xpc .* d.Ypc + fp(6) .* d.Ypc.^2;
end

% p02
function p02change(src, event)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % update display
    d.disp02.Value = event.Value;
    % get fit params; nota
    fp = [d.disp00.Value d.disp10.Value d.disp01.Value d.disp20.Value d.disp11.Value d.disp02.Value];
    % update surf fit plot with new Z calc'd at each XY value ..
    d.hpcsurf.ZData = fp(1) + fp(2) .* d.Xpc + fp(3) .* d.Ypc + fp(4) .* d.Xpc.^2 + fp(5) .* d.Xpc .* d.Ypc + fp(6) .* d.Ypc.^2;
end



% Save a .png of this figure 
function savePNGofGUI(src, ~)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % get unique filename components 
    timestamp = datestr(now, 'YYYY-mm-DD');
    uniquetag = datestr(now, 'HHMMSSFFF');
    % perform save 
    d.statusBox.Value = {'Saving PNG...'};
    savefilename = [d.SDIR timestamp '_GUIscreen_' uniquetag '.png'];
    exportapp(gui, savefilename);
    d.statusBox.Value = {['GUI saved as PNG in: ' savefilename]};
end


% reset model to original parameters 
function resetModel(src, ~)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % reset all Z values of the fit... 
    d.hpcsurf.ZData = d.Zpc;

    % reset Displays 
    d.disp00.Value = d.fitParams(1);
    d.disp10.Value = d.fitParams(2);
    d.disp01.Value = d.fitParams(3);
    d.disp20.Value = d.fitParams(4);
    d.disp11.Value = d.fitParams(5);
    d.disp02.Value = d.fitParams(6);

    % reset sliders
    d.uip00.Value = d.fitParams(1);
    d.uip10.Value = d.fitParams(2);
    d.uip01.Value = d.fitParams(3);
    d.uip20.Value = d.fitParams(4);
    d.uip11.Value = d.fitParams(5);
    d.uip02.Value = d.fitParams(6);

    d.statusBox.Value = {'Model reset to original parameters.'};

end






% save model params
function saveModelParams(src, ~)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 

    % get the fit params from the poly22 modified fit 
    fp = [d.disp00.Value d.disp10.Value d.disp01.Value d.disp20.Value d.disp11.Value d.disp02.Value];
    iriss_pcxyz_mm = d.iriss_pcxyz_mm;
    iriss_fitParams = d.iriss_fitParams;
    iriss_centerPC = d.iriss_centerPC;
    
    % create backup of the file
%     copiedfilepath = [d.SDIR 'backup' datestr(now, 'YYYY-mm-DD-HHMMSSFFF') 'allParams_' num2str(d.SCAN_NO,'%04i') '.mat'];
%     copyfile(paramfilename, copiedfilepath);

    % save the new data; overwriting the original file 
    save(d.SAVEFILE, 'fp', 'iriss_pcxyz_mm', 'iriss_fitParams', 'iriss_centerPC');

    % update user 
    d.statusBox.Value = {['PC fit params saved as .mat to: ' d.SAVEFILE]};

end

