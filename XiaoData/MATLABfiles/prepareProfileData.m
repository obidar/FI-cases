clc; clear; close all;

load CMesh.mat; load secondAnchorPoints.mat; anchors = secondAnchorPoints;
load UbMesh.mat;
%load anchors.mat; 

figure; hold on;
fNamesData = {'0p05','0p5','1','2','3','4','5','6','7','8'};
fNamesOF = {'xp05','xp5','x1','x2','x3','x4','x5','x6','x7','x8'};
dataDir = 'C:\Users\omid_\Documents\postProcess\PH\Krank\KKW_DNS_Periodic_Hill_Re5600\KKW_DNS_Periodic_Hill_Re5600\data\'; %7.0454545455,

tol = 5e-3;

profileRefFieldInversion = 1e16.*ones(length(Cy), 1);

check = 0;

for i = 1:length(anchors)
%    data = table2array(readtable(strcat(dataDir, fNamesData{1,i},'.dat')));
%    yMesh = table2array(readtable(strcat(dataDir, fNamesOF{1,i},'.csv')));
%    uNormalised = data(:,2); yOF = data(:,1);
%    [xData, yData] = prepareCurveData(yOF, uNormalised);
%    ft = 'linearinterp';
%    [fitresult, gof] = fit( xData, yData, ft, 'Normalize', 'on' );
    yRef = anchors(i,2); yUp = yRef + tol; yLow = yRef - tol; 
    xRef = anchors(i,1); xUp = xRef + tol; xLow = xRef - tol;
    for j = 1:length(Cy)
        y = Cy(j);
        x = Cx(j);
        if (y >= yLow && y <= yUp && x >= xLow && x <= xUp)
            plot(Cx(j), Cy(j), 'kx');
 %           profileRefFieldInversion(j,1) = feval(fitresult, Cy(j)); 
            profileRefFieldInversion(j,1) = UbMesh(j,1); 
            check = check + 1;
        end
    end 
end 
hold off; axis equal; 

file = fopen('profileRefFieldInversion.txt', 'w');
for i=1:length(Cy)
    fprintf(file, '%.16d\n', profileRefFieldInversion(i)); 
end 
fclose(file);
