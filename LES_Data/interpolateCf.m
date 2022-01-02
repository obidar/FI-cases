clc; clear; close all;

load CxLowerWall.mat; 
load CfLES.mat;

[xData, yData] = prepareCurveData(CfLES(:,1), CfLES(:,2));
ft = 'linearinterp';

[fitresult, gof] = fit( xData, yData, ft, 'Normalize', 'on' );
pLowerOF = feval(fitresult, CxLowerWall); 
figure; 
CfOF = feval(fitresult, CxLowerWall); 
plot(CfLES(:,1), CfLES(:,2), 'k-', CxLowerWall, CfOF, 'b--'); 
legend('LES', 'Interpolated');

fid = fopen('CfLowerWall', 'w'); 
for i = 1:99
    fprintf(fid, '%d\n', CfOF(i));  
end 

copyfile CfLowerWall interpolatedFiles