clc; clear; close all;
% read u/U_b data and interpolate to OF mesh
fNamesData = {'0p05','0p5','1','2','3','4','5','6','7','8'};
fNamesOF = {'xp05','xp5','x1','x2','x3','x4','x5','x6','x7','x8'};
dataDir = 'C:\Users\omid_\Documents\postProcess\PH\Krank\KKW_DNS_Periodic_Hill_Re5600\KKW_DNS_Periodic_Hill_Re5600\data\'; %7.0454545455,
xAnchors = [0.04545454545500001, 0.4999999999999998, 1.0454545455, 2.0454545455, 3.0454545455, 4.0454545455, 5.0454545455, 6.045454545499999, 7.032200222776879,  8.0454545455];


load CMesh.mat; load brushedData.mat; 
% tol = 4e-2;
% x1 = 0.0454619;
% xUp = x1 + tol;
% xLow = x1 - tol;
figure; %hold on;
profileRefFieldInversion = 1e16.*ones(length(Cy), 1);

for i = 1:length(fNamesOF)
    data = table2array(readtable(strcat(dataDir, fNamesData{1,i},'.dat')));
    yMesh = table2array(readtable(strcat(dataDir, fNamesOF{1,i},'.csv')));
    uNormalised = data(:,2); yOF = data(:,1);
    [xData, yData] = prepareCurveData(yOF, uNormalised);
    ft = 'linearinterp';
    [fitresult, gof] = fit( xData, yData, ft, 'Normalize', 'on' );

    if i==9, tol = 4.5e-2; else tol = 4e-2; end 
    xRef = xAnchors(i); xUp = xRef + tol; xLow = xRef - tol; 
    %disp(i)
    y = []; u = [];
    for j = 1:length(Cx)
        x = Cx(j); 
        if (x >= xLow && x <= xUp)
            %plot(Cx(j), Cy(j), 'kx');
            profileRefFieldInversion(j,1) = feval(fitresult, Cy(j)); 
            y = [y; Cy(j)]; 
            u = [u; feval(fitresult, Cy(j))];
        end
    end
    plotData{i,1} = [u, y]; 
    %plot(u,y,'b-');
end
hold off; axis equal; 
for i=1:10
    d = plotData{i,1};
    subplot(2,5,i);
    plot(d(:,1), d(:,2), 'b-', 'linewidth', 1.5);
end


% write the OF file

file = fopen('profileRefFieldInversion.txt', 'w');
for i=1:length(Cy)
    fprintf(file, '%.16d\n', profileRefFieldInversion(i)); 
end 
fclose(file);



% prepare OF file
% load CyMesh.mat;
% UProfileMesh = 1e16.*ones(length(CyMesh),1);
% c = 0; 
% for j = 1:length(yMesh)
%     for k = 1:length(CyMesh)
%         if yMesh(j) == CyMesh(k)
%             c
%             UProfileMesh(k) = Umesh(j);
%             c = c + 1;
%         end 
%     end
% end
