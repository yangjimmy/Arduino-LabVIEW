clc; 

% figure window 
f = uifigure('Position', [430 50 392+20+804 32*28+64+32]); % l b w h 

% main grid 
maingrid = uigridlayout(f, [1 2], 'ColumnWidth', {392+20, '1x'}, 'Padding', [0 0 0 0]);

% col 1
g1rowHeights = cell(1,30); g1rowHeights(:) = {32}; g1rowHeights(29) = {64}; g1rowHeights(30) = {'1x'};
g1 = uigridlayout(maingrid, [30 1], 'RowHeight', g1rowHeights, 'Padding', [20 0 20 0]);
% col 2
g2 = uigridlayout(maingrid, [6 1], 'RowHeight', {20 32*23 32 32 32 '1x'}, 'Padding', [0 0 0 0]);


t1 = uilabel(g1, 'Text', 'Pupil Parameters', 'FontWeight', 'bold');
t1.Layout.Row = 2;
t2 = uilabel(g1, 'Text', 'Pupil Radius');

sg1 = uigridlayout(g1)

s1 = uislider(g1, 'Value', 5, 'Limits', [0 10], 'MajorTicks', []);


t2 = uilabel(g1, 'Text', '[mm]');
t2.Layout.Row

% dd1.Layout.Row = 2;
% dd1.Layout.Column = 1;


%%

% Create panels 
panelPupil = uipanel(maingrid, 'Title', 'Adjust Pupil', 'FontWeight','bold');
panelPupil.Layout.Row = 1;
panelPupil.Layout.Column = 1;

    pp1 = uigridlayout(panelPupil, [3 3]);
    


dd1 = uislider(pp1, 'Value', 5, 'Limits', [0 10]);
dd1.MajorTicks = [];
% dd1.Position = [0 20 150 3]
dd1.Layout.Row = 2;
dd1.Layout.Column = 2;




panelBag = uipanel(maingrid, 'Title', 'Adjust Capsular Bag', 'FontWeight','bold');
panelBag.Layout.Row = 2;
panelBag.Layout.Column = 1;

panelMainControls = uipanel(maingrid, 'Title', 'Adjust Pupil Parameters', 'FontWeight','bold');
panelMainControls.Layout.Row = 3;
panelMainControls.Layout.Column = 1;





% c = uicontrol('Parent',panelMainControls,'String','Push here');






% % dd1.ValueChangingFcn

% pnl = uipanel(fig);

% 
% uiPupilX = uicontrol('Parent', f, 'Style', 'slider', 'value', pupilCenter(1), 'min', pupilCenter(1)-sr, 'max', pupilCenter(1)+sr);
% uiPupilX.Layout.Row = 1;
% uiPupilX.Layout.Column = 1;



% uiPupilX.Callback = {@modEyeCenterX, uiPupilX, hEyeCenter, hOC, hPupilCircle, hrotx, hroty, hpbc, heqpts, hcb, hp1, hp2, hpx, hpy};
% uicontrol('Parent', f, 'Style', 'text', 'Position', [10+200+10-3 70-3 20 20], 'String', 'X', 'HorizontalAlignment', 'left');

