% 2021-10-11 MJG 
% GUI for modifying automatically generated pig eye model params prior to
% running the trajectory generation;
% this code should replace the previous plotOCTmodel.m code 

% notation fix
SCAN_NO = SCAN_NO_ACh; % dbl

% --- load plotting data 
load([SDIR 'allParams_' num2str(SCAN_NO,'%04i') '.mat'], ...
    'corn_pts_mm', 'endo_pts_mm', 'iris_pts_mm', 'pupil_pts_mm',  ...
    'Xdata', 'Ydata', 'Zdata', 'p_bc', 'eqpts');

% -------------------------------------------------------
% --- calc init plotting params 
% -------------------------------------------------------
% pupil modeling 
[pupilCenter, ocdir, pupilRadius, pupilPoints] = fit3Dcircle_v2(pupil_pts_mm);

% fit surface to endo pts 
surffit_endo = fit([endo_pts_mm(:,1), endo_pts_mm(:,2)], endo_pts_mm(:,3), 'poly22');

% endo: get fit pts for plotting 
[Xendo, Yendo, Zendo] = fitendo(endo_pts_mm, surffit_endo);

% --- pts and directions for rotation 
% get a point on the pupil circle; any point is fine, we take the first 
px = pupilPoints(1,:)';
% get unit vector from pupilCenter to this point 
[pupilCenter2px, ~] = udir(pupilCenter, px);
% get second direction (cross prod)
ydir = cross(pupilCenter2px, ocdir);
% get second point on the pupil circle 
py = pupilCenter + pupilRadius * ydir;

% get zbar (with sign) of pbc (bag center pt) location wrt pc; for init slider control 
[pc2pbc_n, pc2pbc_d] = udir(pupilCenter, p_bc);
init_zbar = -sign(pc2pbc_n(3)) * pc2pbc_d;

% initial r_equator; for init the slider GUI 
% r_equator = 1.2332 * pupilRadius;
% r_equator = norm(p_bc - eqpts(1,:)');
r_equator = norm(p_bc - [Xdata(1,1); Ydata(1,1); Zdata(1,1)]);

% line: optical center
oclengths = [5 5];
ocendpts = getLineEnds(pupilCenter, ocdir, oclengths);

% 2022-02-15 MJG: Force bag to be down 
% 2022-02-16 MJG: Fixed the bag equator initial plot with some messy hacks
if p_bc(3) < pupilCenter(3)
    % messy hack
    new_eqpts = zeros(size(eqpts));
    % get pupilCenter (pc) location 
    pc = pupilCenter;
    % get pre-flip locations
    p1 = ocendpts(:,1);
    p2 = ocendpts(:,2);
    % calc OC norm direction
    [ocdir, ~] = udir(p2, p1);
    % FLIP THE DIRECTION 
    ocdir = -ocdir;
    % update p_bc location 
    p_bc = pc + init_zbar * ocdir; 
    % calc l1, l2
    [~, l1] = udir(p1, pc);
    [~, l2] = udir(p2, pc);
    % calc new p1, p2 
    p1flipped = pc + l1 * ocdir;
    p2flipped = pc - l2 * ocdir;
    % update p1, p2
    ocendpts(:,1) = p1flipped;
    ocendpts(:,2) = p2flipped;
    % --- rotate equator pts 
    % get pre-flip equator points 
    epts = eqpts' - pc;
    % get unit axis of rotation (for rotating eq pts and bag)
    rotx = [pc px];
    [axrot, ~] = udir(rotx(:,1), rotx(:,2));
    % calc rot matrix about axrot by 180°
    R = rotationVectorToMatrix(pi * axrot);
    % apply rotation to equator points, essentially "flipping" them
    new_eqpts = new_eqpts'; % messy hack
    for ii = 1:size(epts,2)
        new_eqpts(:,ii) = R * epts(:,ii) + pc;
    end
    eqpts = new_eqpts'; % messy hack 
    % --- rotate PC bag points
    % get the pre-flip PC data 
    pcpts = [Xdata(:) Ydata(:) Zdata(:)]' - pc;
    % apply rotation to bag pts, essentially "flipping" it 
    for ii = 1:size(pcpts,2)
        pcpts(:,ii) = R * pcpts(:,ii) + pc;
    end
    % update PC points 
    Xdata = reshape(pcpts(1,:), size(Xdata));
    Ydata = reshape(pcpts(2,:), size(Ydata));
    Zdata = reshape(pcpts(3,:), size(Zdata));
end

% ---------------------
% Build GUI 
% ---------------------

% create app window; hide until all components are built
f = uifigure('Visible', 'off');
f.Position = [100 10 1189 803];
f.Name = 'Pig Eye Modeling v1.0';

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

% plot initial data 
hold(fig, 'on');

% cornea data pts 
hc = scatter3(fig, corn_pts_mm(:,1), corn_pts_mm(:,2), corn_pts_mm(:,3), 10, [100/255 110/255 180/255], 'Marker', 'x');
% hc = plot3(fig, corn_pts_mm(:,1), corn_pts_mm(:,2), corn_pts_mm(:,3), 'r.', 'MarkerSize', 10);
set(hc, 'MarkerEdgeAlpha', 0.1, 'MarkerFaceAlpha', 0);

% endo data pts 
% he = scatter3(fig, endo_pts_mm(:,1), endo_pts_mm(:,2), endo_pts_mm(:,3), 100, [40/255 60/255 140/255], 'Marker', '.');
% he = plot3(fig, endo_pts_mm(:,1), endo_pts_mm(:,2), endo_pts_mm(:,3), 'g.', 'MarkerSize', 10);
% set(he, 'MarkerEdgeAlpha', 0.1, 'MarkerFaceAlpha', 0);

% endo surface fit 
endosurf = surf(fig, Xendo, Yendo, Zendo, 'FaceColor', [140/255 150/255 210/255], 'EdgeAlpha', 0, 'FaceAlpha', 0.2);

% pupil data pts 
hs = scatter3(fig, iris_pts_mm(:,1), iris_pts_mm(:,2), iris_pts_mm(:,3), 10, [0.8 0.2 0.1], 'Marker', 'x');
% hs = plot3(fig, iris_pts_mm(:,1), iris_pts_mm(:,2), iris_pts_mm(:,3), 'b.', 'MarkerSize', 10);
set(hs, 'MarkerEdgeAlpha', 0.1, 'MarkerFaceAlpha', 0);

% pupil fit points 
plot3(fig, pupil_pts_mm(:,1), pupil_pts_mm(:,2), pupil_pts_mm(:,3), '+', 'Color', [230/255 60/255 100/255], 'MarkerSize', 4);

% point: eye center 
hEyeCenter = plot3(fig, pupilCenter(1), pupilCenter(2), pupilCenter(3), '.', 'Color', [130/255 15/255 70/255], 'MarkerSize', 12);

% line: optical center
hOC = plot3(fig, [ocendpts(1,1) ocendpts(1,2)], [ocendpts(2,1) ocendpts(2,2)], [ocendpts(3,1) ocendpts(3,2)], 'Color', [200/255 100/255 150/255], 'LineWidth', 1); 
hp1 = plot3(fig, ocendpts(1,1), ocendpts(2,1), ocendpts(3,1), '_', 'Color', [200/255 100/255 150/255]);
hp2 = plot3(fig, ocendpts(1,2), ocendpts(2,2), ocendpts(3,2), '_', 'Color', [200/255 100/255 150/255]);

% plot: pupil circle 
hPupilCircle = plot3(fig, pupilPoints(:,1), pupilPoints(:,2), pupilPoints(:,3), '-', 'Color', [90/255 10/255 50/255], 'LineWidth', 1);

% plot rotational axes 
hrotx = plot3(fig, [pupilCenter(1) px(1)], [pupilCenter(2) px(2)], [pupilCenter(3) px(3)], '-', 'Color', [80/255 160/255 100/255]);
hpx = plot3(fig, px(1), px(2), px(3), '.', 'Color', [80/255 160/255 100/255], 'MarkerSize', 12);
hroty = plot3(fig, [pupilCenter(1) py(1)], [pupilCenter(2) py(2)], [pupilCenter(3) py(3)], '-', 'Color', [40/255 70/255 160/255]);
hpy = plot3(fig, py(1), py(2), py(3), '.', 'Color', [40/255 70/255 160/255], 'MarkerSize', 12);

% Capsular bag center point 
hpbc = plot3(fig, p_bc(1), p_bc(2), p_bc(3), '.', 'MarkerSize', 12, 'Color', [15/255 90/255 75/255]);

% Modeled equator points 
heqpts = plot3(fig, eqpts(:,1), eqpts(:,2), eqpts(:,3), '-', 'LineWidth', 1, 'Color', [15/255 90/255 75/255]);

% Modeled capsular bag (posterior section)
hcb = surf(fig, Xdata, Ydata, Zdata, 'LineStyle', 'none', 'FaceAlpha', 0.3, 'FaceColor', [0 0.4470 0.7410]);
% colormap winter;

% get plot limits 
maxxy = max([eqpts(:,1), eqpts(:,2)]) + 2;
minxy = min([eqpts(:,1), eqpts(:,2)]) - 2;

% apply plot limits 
fig.XLim = [minxy(1) maxxy(1)];
fig.YLim = [minxy(2) maxxy(2)];

% exportgraphics(fig,'anatomy.png');
% print(saveFig, 'anatomy.eps', '-depsc2', '-tiff', '-r100', '-painters');

% ----------------
% GUI Labels (Static)
% ----------------

% -- label: "Pupil Parameters"
label_pupilParams = uilabel(GridLayout, 'Text', 'Pupil Parameters', 'FontWeight', 'bold');
label_pupilParams.Layout.Row = 1;
label_pupilParams.Layout.Column = [1 2];

% -- label: "Pupil Radius"
label_pupilRadius = uilabel(GridLayout, 'Text', 'Pupil Radius');
label_pupilRadius.VerticalAlignment = 'bottom';
label_pupilRadius.Layout.Row = 2;
label_pupilRadius.Layout.Column = [1 2];

% Create PupilCenterLabel
label_pupilCenter = uilabel(GridLayout, 'Text', 'Pupil Center');
label_pupilCenter.VerticalAlignment = 'bottom';
label_pupilCenter.Layout.Row = 4;
label_pupilCenter.Layout.Column = [1 2];

% Create XLabel
label_X1 = uilabel(GridLayout, 'Text', 'X', 'FontWeight', 'bold');
label_X1.HorizontalAlignment = 'center';
label_X1.Layout.Row = 5;
label_X1.Layout.Column = 1;

% Create YLabel
label_Y1 = uilabel(GridLayout, 'Text', 'Y', 'FontWeight', 'bold');
label_Y1.HorizontalAlignment = 'center';
label_Y1.Layout.Row = 6;
label_Y1.Layout.Column = 1;

% Create ZLabel
label_Z1 = uilabel(GridLayout, 'Text', 'Z', 'FontWeight', 'bold');
label_Z1.HorizontalAlignment = 'center';
label_Z1.Layout.Row = 7;
label_Z1.Layout.Column = 1;

% -- mm label
label_mm01 = uilabel(GridLayout, 'Text', '[mm]');
label_mm01.Layout.Row = 3;
label_mm01.Layout.Column = 7;
% -- mm label
label_mm02 = uilabel(GridLayout, 'Text', '[mm]');
label_mm02.Layout.Row = 6;
label_mm02.Layout.Column = 7;
% -- mm label
label_mm03 = uilabel(GridLayout, 'Text', '[mm]');
label_mm03.Layout.Row = 5;
label_mm03.Layout.Column = 7;
% -- mm label
label_mm04 = uilabel(GridLayout, 'Text', '[mm]');
label_mm04.Layout.Row = 7;
label_mm04.Layout.Column = 7;
% -- mm label
label_mm05 = uilabel(GridLayout, 'Text', '[mm]');
label_mm05.Layout.Row = 15;
label_mm05.Layout.Column = 7;
% -- mm label
label_mm06 = uilabel(GridLayout, 'Text', '[mm]');
label_mm06.Layout.Row = 17;
label_mm06.Layout.Column = 7;

% -- deg label
label_deg01 = uilabel(GridLayout, 'Text', '[deg]');
label_deg01.Layout.Row = 9;
label_deg01.Layout.Column = 7;
% -- deg label
label_deg02 = uilabel(GridLayout, 'Text', '[deg]');
label_deg02.Layout.Row = 11;
label_deg02.Layout.Column = 7;
% -- deg label
label_deg03 = uilabel(GridLayout, 'Text', '[deg]');
label_deg03.Layout.Row = 10;
label_deg03.Layout.Column = 7;

% Create XLabel_2
label_X2 = uilabel(GridLayout, 'FontWeight', 'bold', 'Text', 'X');
label_X2.HorizontalAlignment = 'center';
label_X2.FontColor = [0.4667 0.6745 0.1882];
label_X2.Layout.Row = 9;
label_X2.Layout.Column = 1;
% Create YLabel_2
label_Y2 = uilabel(GridLayout, 'FontWeight', 'bold', 'Text', 'Y');
label_Y2.HorizontalAlignment = 'center';
label_Y2.FontColor = [0 0.4471 0.7412];
label_Y2.Layout.Row = 10;
label_Y2.Layout.Column = 1;
% Create ZLabel_2
label_Z2 = uilabel(GridLayout, 'FontWeight', 'bold', 'Text', 'Z');
label_Z2.HorizontalAlignment = 'center';
label_Z2.FontColor = [0.6353 0.0784 0.1843];
label_Z2.Layout.Row = 11;
label_Z2.Layout.Column = 1;

% Create EquatorRadiusLabel
label_equatorRadius = uilabel(GridLayout, 'Text', 'Equator Radius');
label_equatorRadius.VerticalAlignment = 'bottom';
label_equatorRadius.Layout.Row = 14;
label_equatorRadius.Layout.Column = [1 2];

% Create SystemControlsLabel
label_SystemControls = uilabel(GridLayout, 'Text', 'System Controls', 'FontWeight', 'bold');
label_SystemControls.Layout.Row = 19;
label_SystemControls.Layout.Column = [1 2];

% Create BagCenterLabel
label_BagCenter = uilabel(GridLayout, 'Text', 'Bag Center');
label_BagCenter.VerticalAlignment = 'bottom';
label_BagCenter.Layout.Row = 16;
label_BagCenter.Layout.Column = [1 2];

% Create CapsularBagParametersLabel_2
label_bagParams = uilabel(GridLayout, 'Text', 'Capsular Bag Parameters', 'FontWeight', 'bold');
label_bagParams.Layout.Row = 13;
label_bagParams.Layout.Column = [1 3];

% Create SystemStatusLabel
label_systemStatus = uilabel(GridLayout, 'Text', 'System Status');
label_systemStatus.VerticalAlignment = 'bottom';
label_systemStatus.Layout.Row = 22;
label_systemStatus.Layout.Column = [1 2];

% Create PlotTitleLabel
label_plotTitle = uilabel(GridLayout, 'FontWeight', 'bold');
label_plotTitle.HorizontalAlignment = 'center';
label_plotTitle.Layout.Row = 1;
label_plotTitle.Layout.Column = 9;
label_plotTitle.Text = ['Scan Number ' num2str(SCAN_NO) '; {OCT} [mm]'];

% Create PupilRotationLabel
label_pupilRotation = uilabel(GridLayout, 'Text', 'Pupil Rotation');
label_pupilRotation.VerticalAlignment = 'bottom';
label_pupilRotation.Layout.Row = 8;
label_pupilRotation.Layout.Column = [1 2];


% --------------------------
% GUI Displays 
% --------------------------

% -- display: pupil radius value 
dispPupilRadius = uieditfield(GridLayout, 'numeric', 'Editable', 'off');
dispPupilRadius.Layout.Row = 3;
dispPupilRadius.Layout.Column = [5 6];
dispPupilRadius.Value = pupilRadius; % init

% display: pupil center X
dispPupilCenterX = uieditfield(GridLayout, 'numeric', 'Editable', 'off');
dispPupilCenterX.Layout.Row = 5;
dispPupilCenterX.Layout.Column = [5 6];
dispPupilCenterX.Value = pupilCenter(1); % init

% --- display: pupil center Y 
dispPupilCenterY = uieditfield(GridLayout, 'numeric', 'Editable', 'off');
dispPupilCenterY.Layout.Row = 6;
dispPupilCenterY.Layout.Column = [5 6];
dispPupilCenterY.Value = pupilCenter(2); % init

% display: pupil center Z 
dispPupilCenterZ = uieditfield(GridLayout, 'numeric', 'Editable', 'off');
dispPupilCenterZ.Layout.Row = 7;
dispPupilCenterZ.Layout.Column = [5 6];
dispPupilCenterZ.Value = pupilCenter(3); % init

% --- display: pupil rotation X
dispPupilRotX = uieditfield(GridLayout, 'numeric', 'Editable', 'off');
dispPupilRotX.Layout.Row = 9;
dispPupilRotX.Layout.Column = [5 6];
dispPupilRotX.Value = 0; % init

% --- display: pupil rotation Y 
dispPupilRotY = uieditfield(GridLayout, 'numeric', 'Editable', 'off');
dispPupilRotY.Layout.Row = 10;
dispPupilRotY.Layout.Column = [5 6];
dispPupilRotY.Value = 0; % init

% --- display: pupil rotation Z
dispPupilRotZ = uieditfield(GridLayout, 'numeric', 'Editable', 'off');
dispPupilRotZ.Layout.Row = 11;
dispPupilRotZ.Layout.Column = [5 6];
dispPupilRotZ.Value = 0; % init

% --- display: equator radius 
dispEquatorRadius = uieditfield(GridLayout, 'numeric', 'Editable', 'off');
dispEquatorRadius.Layout.Row = 15;
dispEquatorRadius.Layout.Column = [5 6];
dispEquatorRadius.Value = r_equator; % init

% --- display: bag center 
dispBagCenter = uieditfield(GridLayout, 'numeric', 'Editable', 'off');
dispBagCenter.Layout.Row = 17;
dispBagCenter.Layout.Column = [5 6];
dispBagCenter.Value = init_zbar; % init

% "System Status" box
statusBox = uitextarea(GridLayout, 'Editable', 'off');
statusBox.Layout.Row = [23 25];
statusBox.Layout.Column = [1 7];

% --------------------------
% GUI Controls (Sliders)
% --------------------------

% --- Slider: Pupil Radius [mm]
sliderPupilRadius = uislider(GridLayout);
sliderPupilRadius.Layout.Row = 3;
sliderPupilRadius.Layout.Column = [1 4];
sliderPupilRadius.Limits = [4 7]; % from anatomical assumptions
% saturate model-generated value... 
    if pupilRadius > sliderPupilRadius.Limits(2); pupilRadius = sliderPupilRadius.Limits(2); end
    if pupilRadius < sliderPupilRadius.Limits(1); pupilRadius = sliderPupilRadius.Limits(1); end
sliderPupilRadius.Value = pupilRadius; % init
% modify tick mark appearance 
tiPupRad = (sliderPupilRadius.Limits(2)-sliderPupilRadius.Limits(1)) / 4;
sliderPupilRadius.MajorTicks = sliderPupilRadius.Limits(1):tiPupRad:sliderPupilRadius.Limits(2);
sliderPupilRadius.MajorTickLabels = {''};

% pupil center slider padding [mm]
PCSP = 3;

% --- slider: pupil Center X 
uiPupilCenterX = uislider(GridLayout);
uiPupilCenterX.MajorTickLabels = {''};
uiPupilCenterX.Layout.Row = 5;
uiPupilCenterX.Layout.Column = [2 4];
uiPupilCenterX.Value = pupilCenter(1); 
uiPupilCenterX.Limits = [pupilCenter(1)-PCSP pupilCenter(1)+PCSP];
tiPupCentX = (uiPupilCenterX.Limits(2)-uiPupilCenterX.Limits(1)) / 4;
uiPupilCenterX.MajorTicks = uiPupilCenterX.Limits(1):tiPupCentX:uiPupilCenterX.Limits(2);
uiPupilCenterX.MajorTickLabels = {''};

% --- slider: pupil center Y 
uiPupilCenterY = uislider(GridLayout);
uiPupilCenterY.MajorTickLabels = {''};
uiPupilCenterY.Layout.Row = 6;
uiPupilCenterY.Layout.Column = [2 4];
uiPupilCenterY.Value = pupilCenter(2); 
uiPupilCenterY.Limits = [pupilCenter(2)-PCSP pupilCenter(2)+PCSP];
tiPupCentY = (uiPupilCenterY.Limits(2)-uiPupilCenterY.Limits(1)) / 4;
uiPupilCenterY.MajorTicks = uiPupilCenterY.Limits(1):tiPupCentY:uiPupilCenterY.Limits(2);
uiPupilCenterY.MajorTickLabels = {''};

% --- slider: pupil Center Z 
uiPupilCenterZ = uislider(GridLayout);
uiPupilCenterZ.MajorTickLabels = {''};
uiPupilCenterZ.Layout.Row = 7;
uiPupilCenterZ.Layout.Column = [2 4];
uiPupilCenterZ.Value = pupilCenter(3); 
uiPupilCenterZ.Limits = [pupilCenter(3)-PCSP pupilCenter(3)+PCSP];
tiPupCentZ = (uiPupilCenterZ.Limits(2)-uiPupilCenterZ.Limits(1)) / 4;
uiPupilCenterZ.MajorTicks = uiPupilCenterZ.Limits(1):tiPupCentZ:uiPupilCenterZ.Limits(2);
uiPupilCenterZ.MajorTickLabels = {''};

% --- slider: pupil rotation X
uiPupilRotX = uislider(GridLayout);
uiPupilRotX.Layout.Row = 9;
uiPupilRotX.Layout.Column = [2 4];
uiPupilRotX.Limits = [-90 90];
uiPupilRotX.Value = 0;
uiPupilRotX.UserData = 0;
tiPupRotX = (uiPupilRotX.Limits(2)-uiPupilRotX.Limits(1)) / 4;
uiPupilRotX.MajorTicks = uiPupilRotX.Limits(1):tiPupRotX:uiPupilRotX.Limits(2);
uiPupilRotX.MajorTickLabels = {''};

% --- slider: pupil rotation Y
uiPupilRotY = uislider(GridLayout);
uiPupilRotY.MajorTickLabels = {''};
uiPupilRotY.Layout.Row = 10;
uiPupilRotY.Layout.Column = [2 4];
uiPupilRotY.Limits = [-90 90];
uiPupilRotY.Value = 0;
uiPupilRotY.UserData = 0;
tiPupRotY = (uiPupilRotY.Limits(2)-uiPupilRotY.Limits(1)) / 4;
uiPupilRotY.MajorTicks = uiPupilRotY.Limits(1):tiPupRotY:uiPupilRotY.Limits(2);
uiPupilRotY.MajorTickLabels = {''};

% --- slider: pupil rotation Z 
uiPupilRotZ = uislider(GridLayout);
uiPupilRotZ.MajorTickLabels = {''};
uiPupilRotZ.Layout.Row = 11;
uiPupilRotZ.Layout.Column = [2 4];
uiPupilRotZ.Limits = [-90 90];
uiPupilRotZ.Value = 0;
uiPupilRotZ.UserData = 0;
tiPupRotZ = (uiPupilRotZ.Limits(2)-uiPupilRotZ.Limits(1)) / 4;
uiPupilRotZ.MajorTicks = uiPupilRotZ.Limits(1):tiPupRotZ:uiPupilRotZ.Limits(2);
uiPupilRotZ.MajorTickLabels = {''};

% --- slider: equator radius 
uiEquatorRadius = uislider(GridLayout);
uiEquatorRadius.MajorTickLabels = {''};
uiEquatorRadius.Layout.Row = 15;
uiEquatorRadius.Layout.Column = [1 4];
uiEquatorRadius.Limits = [5 9]; % from anatomical assumptions
    % saturate based on anatomical assumptions 
    if r_equator > uiEquatorRadius.Limits(2); r_equator = uiEquatorRadius.Limits(2); end
    if r_equator < uiEquatorRadius.Limits(1); r_equator = uiEquatorRadius.Limits(1); end
uiEquatorRadius.Value = r_equator;
tiEqRad = (uiEquatorRadius.Limits(2)-uiEquatorRadius.Limits(1)) / 4;
uiEquatorRadius.MajorTicks = uiEquatorRadius.Limits(1):tiEqRad:uiEquatorRadius.Limits(2);
uiEquatorRadius.MajorTickLabels = {''};

% --- slider: bag center 
uiBagCenter = uislider(GridLayout);
uiBagCenter.MajorTickLabels = {''};
uiBagCenter.Layout.Row = 17;
uiBagCenter.Layout.Column = [1 4];
uiBagCenter.Limits = [-oclengths(2) oclengths(1)];
% 2022-02-14 ensure within GUI slider limits 
if init_zbar > oclengths(1) || init_zbar < -oclengths(2)
    init_zbar = sum([-oclengths(2) oclengths(1)])/2;
end
% uiBagCenter.Value = init_zbar;
tiBC = (uiBagCenter.Limits(2)-uiBagCenter.Limits(1)) / 4;
uiBagCenter.MajorTicks = uiBagCenter.Limits(1):tiBC:uiBagCenter.Limits(2);
uiBagCenter.MajorTickLabels = {''};


% --------------------------
% GUI Controls (Buttons, etc.)
% --------------------------

% Create ResetModelButton
ResetModelButton = uibutton(GridLayout, 'push', 'Text', 'Reset Model');
ResetModelButton.Layout.Row = 20;
ResetModelButton.Layout.Column = [1 3];

% Create SaveModelButton
SaveModelButton = uibutton(GridLayout, 'push', 'Text', 'Save Model', 'FontWeight', 'bold');
SaveModelButton.Layout.Row = [20 21];
SaveModelButton.Layout.Column = [5 7];

% Create SavePNGofGUIButton
SavePNGofGUIButton = uibutton(GridLayout, 'push', 'Text', 'Save PNG of GUI');
SavePNGofGUIButton.Layout.Row = 21;
SavePNGofGUIButton.Layout.Column = [1 3];

% Toggle switch for OC direction 
uiToggleOC = uiswitch(GridLayout, 'slider', 'Items', {'+', '-'}, 'Value', '+');
uiToggleOC.Layout.Row = 13;
uiToggleOC.Layout.Column = [5 6];

% Show the figure after all components are created
f.Visible = 'on';












% define callback functions 
sliderPupilRadius.ValueChangingFcn = @modPupilRadius;
uiPupilCenterX.ValueChangingFcn = @pupilEyeCenterX;
uiPupilCenterY.ValueChangingFcn = @pupilEyeCenterY;
uiPupilCenterZ.ValueChangingFcn = @pupilEyeCenterZ;
uiPupilRotX.ValueChangingFcn = @pupilRotateX;
uiPupilRotY.ValueChangingFcn = @pupilRotateY;
uiPupilRotZ.ValueChangingFcn = @pupilRotateZ;
uiEquatorRadius.ValueChangingFcn = @equatorRadius;
uiBagCenter.ValueChangingFcn = @bagCenter;
SavePNGofGUIButton.ButtonPushedFcn = @savePNGofGUI;
ResetModelButton.ButtonPushedFcn = @resetModel;
uiToggleOC.ValueChangedFcn = @toggleBagDirection;
SaveModelButton.ButtonPushedFcn = @saveModelParams;



% store all handles to plots, GUI elements, labels, etc. in the userData
% element of the overall gui figure f 
f.UserData = struct(...
    "dispPupilRadius", dispPupilRadius, ...
    "sliderPupilRadius", sliderPupilRadius, ...
    "hPupilCircle", hPupilCircle, ...
    "hEyeCenter", hEyeCenter, ...
    "hrotx", hrotx, ...
    "hroty", hroty, ...
    "hpx", hpx, ...
    "hpy", hpy, ...
    "hOC", hOC, ...
    "hpbc", hpbc, ...
    "hcb", hcb, ...
    "hp1", hp1, ...
    "hp2", hp2, ...
    "heqpts", heqpts, ...
    "dispPupilCenterX", dispPupilCenterX, ...
    "dispPupilCenterY", dispPupilCenterY, ...
    "dispPupilCenterZ", dispPupilCenterZ, ...
    "uiPupilCenterX", uiPupilCenterX, ...
    "uiPupilCenterY", uiPupilCenterY, ...
    "uiPupilCenterZ", uiPupilCenterZ, ...
    "dispPupilRotX", dispPupilRotX, ...
    "dispPupilRotY", dispPupilRotY, ...
    "dispPupilRotZ", dispPupilRotZ, ...
    "uiPupilRotX", uiPupilRotX, ...
    "uiPupilRotY", uiPupilRotY, ...
    "uiPupilRotZ", uiPupilRotZ, ...
    "uiEquatorRadius", uiEquatorRadius, ...
    "uiBagCenter", uiBagCenter, ...
    "dispBagCenter", dispBagCenter, ...
    "dispEquatorRadius", dispEquatorRadius, ...
    "SDIR", SDIR, ...
    "SCAN_NO", SCAN_NO, ...
    "pupilCenter", pupilCenter, ...
    "ocendpts", ocendpts, ...
    "pupilPoints", pupilPoints, ...
    "px", px, ...
    "py", py, ...
    "p_bc", p_bc, ...
    "eqpts", eqpts, ...
    "Xdata", Xdata, ...
    "Ydata", Ydata, ...
    "Zdata", Zdata, ...
    "pupilRadius", pupilRadius, ...
    "r_equator", r_equator, ...
    "init_zbar", init_zbar, ...
    "statusBox", statusBox, ...
    "uiToggleOC", uiToggleOC);




% -------------------------------------
% Callback functions 
% -------------------------------------


% modify pupil radius 
function modPupilRadius(src, event)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 

    % update display value 
    d.dispPupilRadius.Value = event.Value;
    % nota; get current eye center 
    pc = getxyzfromhandle(d.hEyeCenter);

    % build array of all the points that need to update 
    % current pupilFit points (3 x n) | rotation axes end pts (3 x 2)
    pts2rot = [d.hPupilCircle.XData d.hrotx.XData(2) d.hroty.XData(2); ...
               d.hPupilCircle.YData d.hrotx.YData(2) d.hroty.YData(2); ...
               d.hPupilCircle.ZData d.hrotx.ZData(2) d.hroty.ZData(2)]; 
   
    % scale each pt in the list by the pupilRadius along each pts' dir 
    directions = pts2rot - pc;
    newpts = event.Value * directions ./ vecnorm(directions) + pc;

    % update plot data
    updateHandleData(d.hPupilCircle, newpts(:, 1:end-2));
    updateHandleData(d.hrotx, [pc newpts(:,end-1)]);
    updateHandleData(d.hroty, [pc newpts(:,end)]);
    updateHandleData(d.hpx, newpts(:,end-1))
    updateHandleData(d.hpy, newpts(:,end));

end

% modify pupil center X 
function pupilEyeCenterX(src, event)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % update display
    d.dispPupilCenterX.Value = event.Value;
    % calc delta
    inc_x = event.Value - d.hEyeCenter.XData;
    % update pupil center X position
    d.hEyeCenter.XData = event.Value;
    % update optical centerline 
    d.hOC.XData = d.hOC.XData + inc_x;
    d.hp1.XData = d.hp1.XData + inc_x; 
    d.hp2.XData = d.hp2.XData + inc_x;
    % update pupil circle fit 
    d.hPupilCircle.XData = d.hPupilCircle.XData + inc_x;
    % update center of rot axes
    d.hrotx.XData(1) = d.hrotx.XData(1) + inc_x;
    d.hrotx.XData(2) = d.hrotx.XData(2) + inc_x;
    d.hroty.XData(1) = d.hroty.XData(1) + inc_x;
    d.hroty.XData(2) = d.hroty.XData(2) + inc_x;
    d.hpx.XData = d.hpx.XData + inc_x;
    d.hpy.XData = d.hpy.XData + inc_x;
    % update p_bc location 
    d.hpbc.XData = d.hpbc.XData + inc_x;
    % update equator points 
    d.heqpts.XData = d.heqpts.XData + inc_x; 
    % update surface data 
    d.hcb.XData = d.hcb.XData + inc_x; 
end
% modify pupil center Y
function pupilEyeCenterY(src, event)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % update display
    d.dispPupilCenterY.Value = event.Value;
    % calc delta
    inc_y = event.Value - d.hEyeCenter.YData;
    % update pupil center Y position
    d.hEyeCenter.YData = event.Value;
    % update optical centerline 
    d.hOC.YData = d.hOC.YData + inc_y;
    d.hp1.YData = d.hp1.YData + inc_y; 
    d.hp2.YData = d.hp2.YData + inc_y;
    % update pupil circle fit 
    d.hPupilCircle.YData = d.hPupilCircle.YData + inc_y;
    % update center of rot axes
    d.hrotx.YData(1) = d.hrotx.YData(1) + inc_y;
    d.hrotx.YData(2) = d.hrotx.YData(2) + inc_y;
    d.hroty.YData(1) = d.hroty.YData(1) + inc_y;
    d.hroty.YData(2) = d.hroty.YData(2) + inc_y;
    d.hpx.YData = d.hpx.YData + inc_y;
    d.hpy.YData = d.hpy.YData + inc_y;
    % update p_bc location 
    d.hpbc.YData = d.hpbc.YData + inc_y;
    % update equator points 
    d.heqpts.YData = d.heqpts.YData + inc_y; 
    % update surface data 
    d.hcb.YData = d.hcb.YData + inc_y;
end
% modify pupil center Z
function pupilEyeCenterZ(src, event)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % update display
    d.dispPupilCenterZ.Value = event.Value;
    % calc delta
    inc_z = event.Value - d.hEyeCenter.ZData;
    % update pupil center Y position
    d.hEyeCenter.ZData = event.Value;
    % update optical centerline 
    d.hOC.ZData = d.hOC.ZData + inc_z;
    d.hp1.ZData = d.hp1.ZData + inc_z; 
    d.hp2.ZData = d.hp2.ZData + inc_z;
    % update pupil circle fit 
    d.hPupilCircle.ZData = d.hPupilCircle.ZData + inc_z;
    % update center of rot axes
    d.hrotx.ZData(1) = d.hrotx.ZData(1) + inc_z;
    d.hrotx.ZData(2) = d.hrotx.ZData(2) + inc_z;
    d.hroty.ZData(1) = d.hroty.ZData(1) + inc_z;
    d.hroty.ZData(2) = d.hroty.ZData(2) + inc_z;
    d.hpx.ZData = d.hpx.ZData + inc_z;
    d.hpy.ZData = d.hpy.ZData + inc_z;
    % update p_bc location 
    d.hpbc.ZData = d.hpbc.ZData + inc_z;
    % update equator points 
    d.heqpts.ZData = d.heqpts.ZData + inc_z; 
    % update surface data 
    d.hcb.ZData = d.hcb.ZData + inc_z;
end

% rotate pupil about X 
function pupilRotateX(src, event)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % update display
    d.dispPupilRotX.Value = event.Value;

    % get axis of rotation
    [axrot, ~] = udir([d.hrotx.XData(1); d.hrotx.YData(1); d.hrotx.ZData(1)], ...
                      [d.hrotx.XData(2); d.hrotx.YData(2); d.hrotx.ZData(2)]);

    % calc the inc amt of ang change from last call 
    rotinc = event.Value - d.uiPupilRotX.UserData;
    % update user data with the current requested angle 
    d.uiPupilRotX.UserData = event.Value;

    % get eye center; nota
    pc = getxyzfromhandle(d.hEyeCenter);

    % get rotation matrix from direction; magnitude is rotation amt
    R = rotationVectorToMatrix(deg2rad(rotinc) * axrot);

    % get opticalCenter points; zero-center 
    oc = getxyzfromhandle(d.hOC) - pc;

    % apply rotation to OC pts and undo zero-center 
    for ii = 1:2
        oc(:,ii) = R * oc(:,ii) + pc;
    end

    % update optical centerline 
    updateHandleData(d.hOC, oc);    

    % nota: pupil circle pts (all); zero center 
    xyz = getxyzfromhandle(d.hPupilCircle) - pc;

    % loop through pts and rotate
    for ii = 1:size(xyz,2)
        xyz(:,ii) = R * xyz(:,ii) + pc;
    end

    % update pupilCircle pts in plots
    updateHandleData(d.hPupilCircle, xyz);

    % rotate and apply to rotation axes 
    rotbyhandle(d.hroty, R, pc, 2);
    rotbyhandle(d.hpy, R, pc, 1);

    % rotate and apply to p1, p2 points 
    rotbyhandle(d.hp1, R, pc, 1);
    rotbyhandle(d.hp2, R, pc, 1);

    % rotate and apply to pbc 
    rotbyhandle(d.hpbc, R, pc, 1);

    % --- equator 
    exyz = getxyzfromhandle(d.heqpts) - pc;
    for ii = 1:size(exyz,2)
        exyz(:,ii) = R * exyz(:,ii) + pc;
    end
    updateHandleData(d.heqpts, exyz);

    % --- PC bag 
    pcpts = [d.hcb.XData(:) d.hcb.YData(:) d.hcb.ZData(:)]' - pc;
    for ii = 1:size(pcpts,2)
        pcpts(:,ii) = R * pcpts(:,ii) + pc;
    end
    d.hcb.XData = reshape(pcpts(1,:), size(d.hcb.XData));
    d.hcb.YData = reshape(pcpts(2,:), size(d.hcb.YData));
    d.hcb.ZData = reshape(pcpts(3,:), size(d.hcb.ZData));

%     % rebuild PC bag model 
%     p_bc = getxyzfromhandle(d.hpbc);
%     opticalCenter = p_bc - pc;
%     opticalCenter = opticalCenter / norm(opticalCenter);
%     eqRadius = d.uiEquatorRadius.Value;
% 
%     [d.hcb.XData, d.hcb.YData, d.hcb.ZData] = modPCmodel(p_bc, opticalCenter, eqRadius);


    

end



% rotate pupil about Y
function pupilRotateY(src, event)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % update display
    d.dispPupilRotY.Value = event.Value;

    % get axis of rotation
    [axrot, ~] = udir([d.hroty.XData(1); d.hroty.YData(1); d.hroty.ZData(1)], ...
                      [d.hroty.XData(2); d.hroty.YData(2); d.hroty.ZData(2)]);

    % calc the inc amt of ang change from last call 
    rotinc = event.Value - d.uiPupilRotY.UserData;
    % update user data with the current requested angle 
    d.uiPupilRotY.UserData = event.Value;

    % get eye center; nota
    pc = getxyzfromhandle(d.hEyeCenter);

    % get rotation matrix from direction; magnitude is rotation amt
    R = rotationVectorToMatrix(deg2rad(rotinc) * axrot);

    % get opticalCenter points; zero-center 
    oc = getxyzfromhandle(d.hOC) - pc;

    % apply rotation to OC pts and undo zero-center 
    for ii = 1:2
        oc(:,ii) = R * oc(:,ii) + pc;
    end

    % update optical centerline 
    updateHandleData(d.hOC, oc);    

    % nota: pupil circle pts (all); zero center 
    xyz = getxyzfromhandle(d.hPupilCircle) - pc;

    % loop through pts and rotate
    for ii = 1:size(xyz,2)
        xyz(:,ii) = R * xyz(:,ii) + pc;
    end

    % update pupilCircle pts in plots
    updateHandleData(d.hPupilCircle, xyz);

    % rotate and apply to rotation axes 
    rotbyhandle(d.hrotx, R, pc, 2);
    rotbyhandle(d.hpx, R, pc, 1);

    % rotate and apply to p1, p2 points 
    rotbyhandle(d.hp1, R, pc, 1);
    rotbyhandle(d.hp2, R, pc, 1);

    % rotate and apply to pbc 
    rotbyhandle(d.hpbc, R, pc, 1);

    % --- equator 
    exyz = getxyzfromhandle(d.heqpts) - pc;
    for ii = 1:size(exyz,2)
        exyz(:,ii) = R * exyz(:,ii) + pc;
    end
    updateHandleData(d.heqpts, exyz);

    % --- PC bag 
    pcpts = [d.hcb.XData(:) d.hcb.YData(:) d.hcb.ZData(:)]' - pc;
    for ii = 1:size(pcpts,2)
        pcpts(:,ii) = R * pcpts(:,ii) + pc;
    end
    d.hcb.XData = reshape(pcpts(1,:), size(d.hcb.XData));
    d.hcb.YData = reshape(pcpts(2,:), size(d.hcb.YData));
    d.hcb.ZData = reshape(pcpts(3,:), size(d.hcb.ZData));

end

% rotate pupil about Z
function pupilRotateZ(src, event)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % update display
    d.dispPupilRotZ.Value = event.Value;

    % calc the inc amt of ang change from last call 
    rotinc = event.Value - d.uiPupilRotZ.UserData;
    % update user data with the current requested angle 
    d.uiPupilRotZ.UserData = event.Value;

    % get eye center
    pc = getxyzfromhandle(d.hEyeCenter); 

    % get direction of OC 
    [ocdir, ~] = udir([d.hOC.XData(2); d.hOC.YData(2); d.hOC.ZData(2)], ...
                      [d.hOC.XData(1); d.hOC.YData(1); d.hOC.ZData(1)]);

    % calc rot matrix abt OC; mag is rot amt
    R = rotationVectorToMatrix(deg2rad(rotinc) * ocdir);

    % apply rotation to axes 
    rotbyhandle(d.hpx, R, pc, 1);
    rotbyhandle(d.hpy, R, pc, 1);
    rotbyhandle(d.hrotx, R, pc, 2);
    rotbyhandle(d.hroty, R, pc, 2);

end

% equator radius 
function equatorRadius(src, event)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % update display
    d.dispEquatorRadius.Value = event.Value;
    % get p_bc 
    p_bc = getxyzfromhandle(d.hpbc);
    % nota; get bag pts 
    xp = d.hcb.XData;
    yp = d.hcb.YData;
    zp = d.hcb.ZData;
    % get new bag model points
    [xp, yp, zp] = updateBagModel(xp, yp, zp, p_bc, event.Value);

    % update bag model points 
    d.hcb.XData = xp;
    d.hcb.YData = yp;
    d.hcb.ZData = zp;
    % update equator points
    updateHandleData(d.heqpts, [xp(1,:); yp(1,:); zp(1,:)]);

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
    savefilename = [d.SDIR timestamp '_GUIscreen_' num2str(d.SCAN_NO) '_' uniquetag '.png'];
    exportapp(gui, savefilename);
    d.statusBox.Value = {['GUI saved as PNG in: ' savefilename]};
end



% reset model to original parameters 
function resetModel(src, ~)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 

    % Reset values 
    updateHandleData(d.hEyeCenter, d.pupilCenter);
    updateHandleData(d.hOC, d.ocendpts);
    updateHandleData(d.hp1, d.ocendpts(:,1));
    updateHandleData(d.hp2, d.ocendpts(:,2));
    updateHandleData(d.hPupilCircle, d.pupilPoints');
    updateHandleData(d.hrotx, [d.pupilCenter d.px]);
    updateHandleData(d.hroty, [d.pupilCenter d.py]);
    updateHandleData(d.hpbc, d.p_bc);
    updateHandleData(d.heqpts, d.eqpts');
    updateHandleData(d.hpx, d.px);
    updateHandleData(d.hpy, d.py);
    
    % Reset PC bag 
    d.hcb.XData = d.Xdata;
    d.hcb.YData = d.Ydata;
    d.hcb.ZData = d.Zdata;

    % --- Reset GUI controls to init vals 
    d.sliderPupilRadius.Value = d.pupilRadius;
    d.uiPupilCenterX.Value = d.pupilCenter(1); 
    d.uiPupilCenterY.Value = d.pupilCenter(2); 
    d.uiPupilCenterZ.Value = d.pupilCenter(3); 
    d.uiPupilRotX.Value = 0;
    d.uiPupilRotY.Value = 0;
    d.uiPupilRotZ.Value = 0;
    d.uiEquatorRadius.Value = d.r_equator;
    d.uiBagCenter.Value = d.init_zbar;
    d.uiToggleOC.Value = '+';
    % reset GUI displays 
    d.dispPupilRadius.Value = d.pupilRadius; % init
    d.dispPupilCenterX.Value = d.pupilCenter(1); % init
    d.dispPupilCenterY.Value = d.pupilCenter(2); % init
    d.dispPupilCenterZ.Value = d.pupilCenter(3); % init
    d.dispPupilRotX.Value = 0; % init
    d.dispPupilRotY.Value = 0; % init
    d.dispPupilRotZ.Value = 0; % init
    d.dispEquatorRadius.Value = d.r_equator; % init
    d.dispBagCenter.Value = d.init_zbar; % init

    d.statusBox.Value = {'Model reset to original parameters.'};

end


% toggle bag direction 
function toggleBagDirection(src, ~)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % get current zbar value 
    z_bar = d.uiBagCenter.Value;
    % get pupilCenter (pc) location 
    pc = getxyzfromhandle(d.hEyeCenter);
    % get pre-flip locations
    p1 = getxyzfromhandle(d.hp1);
    p2 = getxyzfromhandle(d.hp2);
    % calc OC norm direction
    [ocdir, ~] = udir(p2, p1);
    % FLIP THE DIRECTION 
    ocdir = -ocdir;
    % update p_bc location 
    updateHandleData(d.hpbc, pc + z_bar * ocdir);
    % calc l1, l2
    [~, l1] = udir(p1, pc);
    [~, l2] = udir(p2, pc);
    % calc new p1, p2 
    p1flipped = pc + l1 * ocdir;
    p2flipped = pc - l2 * ocdir;
    % update p1, p2
    updateHandleData(d.hp1, p1flipped);
    updateHandleData(d.hp2, p2flipped);
    % update OC plot 
    d.hOC.XData = [p1flipped(1) p2flipped(1)];
    d.hOC.YData = [p1flipped(2) p2flipped(2)];
    d.hOC.ZData = [p1flipped(3) p2flipped(3)];

    % --- rotate equator pts 
    % get pre-flip equator points 
    epts = getxyzfromhandle(d.heqpts) - pc;
    % get unit axis of rotation (for rotating eq pts and bag)
    rotx = getxyzfromhandle(d.hrotx);
    [axrot, ~] = udir(rotx(:,1), rotx(:,2));
    % calc rot matrix about axrot by 180°
    R = rotationVectorToMatrix(pi * axrot);
    % apply rotation to equator points, essentially "flipping" them
    for ii = 1:size(epts,2)
        epts(:,ii) = R * epts(:,ii) + pc;
    end
    % update equator points 
    updateHandleData(d.heqpts, epts);

    % --- rotate PC bag points
    % get the pre-flip PC data 
    pcpts = [d.hcb.XData(:) d.hcb.YData(:) d.hcb.ZData(:)]' - pc;
    % apply rotation to bag pts, essentially "flipping" it 
    for ii = 1:size(pcpts,2)
        pcpts(:,ii) = R * pcpts(:,ii) + pc;
    end
    % update PC points 
    d.hcb.XData = reshape(pcpts(1,:), size(d.hcb.XData));
    d.hcb.YData = reshape(pcpts(2,:), size(d.hcb.YData));
    d.hcb.ZData = reshape(pcpts(3,:), size(d.hcb.ZData));

end


% bag center shift 
function bagCenter(src, event)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 
    % retain previous value of zbar
    z_bar_orig = d.dispBagCenter.Value;
    % get new value of zbar
    z_bar = event.Value;
    % update display
    d.dispBagCenter.Value = z_bar;

    % get current optical center endpts
    p1 = getxyzfromhandle(d.hp1);
    p2 = getxyzfromhandle(d.hp2);
    % calc OC norm direction 
    [ocdir, ~] = udir(p2, p1);
    % get current pupilCenter 
    pc = getxyzfromhandle(d.hEyeCenter);
    % update p_bc location 
    updateHandleData(d.hpbc, pc + z_bar * ocdir);
    
    % calc distance shifted b/t function calls 
    shiftDist = z_bar - z_bar_orig;

    % shift and update equator points 
    d.heqpts.XData = d.heqpts.XData + shiftDist * ocdir(1);
    d.heqpts.YData = d.heqpts.YData + shiftDist * ocdir(2);
    d.heqpts.ZData = d.heqpts.ZData + shiftDist * ocdir(3);

    % shift and update PC bag points 
    d.hcb.XData = d.hcb.XData + shiftDist * ocdir(1);
    d.hcb.YData = d.hcb.YData + shiftDist * ocdir(2);
    d.hcb.ZData = d.hcb.ZData + shiftDist * ocdir(3);
    

end

% save model params
function saveModelParams(src, ~)
    % access data 
    gui = ancestor(src, "figure", "toplevel");
    d = gui.UserData; 

    % build path to allParams .mat file 
    paramfilename = [d.SDIR 'allParams_' num2str(d.SCAN_NO,'%04i') '.mat'];

    % --- many params remain unchanged by the GUI; load these into memory
    % from the previous allParams_#.mat file 
    load(paramfilename, ...
    'corn_pts_mm', 'endo_pts_mm', 'iris_pts_mm', 'pupil_pts_mm', ...
    'refIndex', 'TOI_ACh', 'OCTz_ACh', 'surffit_endo', ...
    'corneaThickness_mm'); 

    % --- Some params simply require a rename or definition 
    SCAN_NO_ACh = d.SCAN_NO;
    SCAN_NO = d.SCAN_NO;
    
    % --- Many params get updated in the GUI; these require pointing to the
    % new values
    p_bc = getxyzfromhandle(d.hpbc);
    eqpts = getxyzfromhandle(d.heqpts)';
    Xdata = d.hcb.XData;
    Ydata = d.hcb.YData;
    Zdata = d.hcb.ZData;
    pupilCenter = getxyzfromhandle(d.hEyeCenter);
    [opticalCenter, ~] = udir(getxyzfromhandle(d.hp1), getxyzfromhandle(d.hp2));
    pupilRadius = d.sliderPupilRadius.Value;
    pupilCurvePts = getxyzfromhandle(d.hPupilCircle);

    % --- Two params (PolyCoef_cornea_mm_IRISSframe,
    % PolyCoef_post_mm_IRISSframe) need to be specially generated 
    % Mia's code expects poly22 fit coefficients
    % To get a good fit, we need to first shave off some of the "close to
    % equator" points 
    levels2shave = 50;
    xx = Xdata(levels2shave:end, :);
    yy = Ydata(levels2shave:end, :);
    zz = Zdata(levels2shave:end, :);
    % compile into matrix 
    pcfitpts_mm = [xx(:), yy(:), zz(:)];

    % --- Convert params to Mia's data format --- %
    % https://docs.google.com/spreadsheets/d/1t4bfVIIaAbXP61JEGQKT-zpibm8xWG-xJs_fPByoPyg/edit?usp=sharing
    [PolyCoef_cornea_mm_IRISSframe, PolyCoef_post_mm_IRISSframe, SurfacePolyOrd] = ...
        convert4mia(TOI_ACh, endo_pts_mm, pcfitpts_mm);
    
    % create backup of the file
    copiedfilepath = [d.SDIR 'backup' datestr(now, 'YYYY-mm-DD-HHMMSSFFF') 'allParams_' num2str(d.SCAN_NO,'%04i') '.mat'];
    copyfile(paramfilename, copiedfilepath);

    % save the new data; overwriting the original file 
    save(paramfilename, ...
        'SCAN_NO_ACh', ... 
        'SCAN_NO', ...
        'PolyCoef_cornea_mm_IRISSframe', ...
        'SurfacePolyOrd', ...
        'pupil_pts_mm', ...
        'PolyCoef_post_mm_IRISSframe', ...
        'TOI_ACh', ...
        'corn_pts_mm', ...
        'endo_pts_mm', ...
        'iris_pts_mm', ...
        'refIndex', ...
        'OCTz_ACh', ...
        'corneaThickness_mm', ...
        'pupilCenter', ...
        'opticalCenter', ...
        'pupilRadius', ...
        'p_bc', ...
        'eqpts', ...
        'Xdata', ...
        'Ydata', ...
        'Zdata', ...
        'pupilCurvePts', ...
        'surffit_endo', ...
        'pcfitpts_mm'); % Added pc points as output (Mia 2021-10-13) 

    % update user 
    d.statusBox.Value = {'Model parameters SAVED.'};

end