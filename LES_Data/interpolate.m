clc; clear; close all;
load CMesh.mat; % OF mesh cell centres
load cellInterpolated.mat; % cell centre data exported from Paraview
%   cellInterpolated order (all normalised, except Cx and Cy)
%   1   2   3   4   5   6   7   8   9   10  11  12
%   p   u   uu  uv  uw  v   vv  vw  w   ww  Cx  Cy

%figure; hold on;
%-------------------------------------
% plot CMesh to confirm it is complete!
% for i = 1:length(Cx)
%     plot(Cx(i), Cy(i), 'k.');
% end 
%-------------------------------------


xTol = 2.53e-3;      yTol = 5e-3; 
check = 0; % check
p = zeros(length(Cx),1);
U = zeros(length(Cx),3);
Tau = zeros(length(Cx),6);
for i = 1:length(Cx)
    xRef = Cx(i,1); xUp = xRef + xTol; xLow = xRef - xTol;
    yRef = Cy(i,1); yUp = yRef + yTol; yLow = yRef - yTol; 
    for j = 1:length(Cx)
        x = cellInterpolated(j,11);
        y = cellInterpolated(j,12);
        if (y >= yLow && y <= yUp && x >= xLow && x <= xUp)
            %plot(Cx(i), Cy(i), 'k.'); % for verification
            p(i,1) = 2 * cellInterpolated(j,1);
            U(i,1) = 2 * cellInterpolated(j,2);
            U(i,2) = 2 * cellInterpolated(j,6);
            U(i,3) = 2 * cellInterpolated(j,9);
            Tau(i,1) = 2 * cellInterpolated(j,3); 
            Tau(i,2) = 2 * cellInterpolated(j,4);
            Tau(i,3) = 2 * cellInterpolated(j,5);
            Tau(i,4) = 2 * cellInterpolated(j,7);
            Tau(i,5) = 2 * cellInterpolated(j,8);
            Tau(i,6) = 2 * cellInterpolated(j,10);
            check = check + 1;
        end
    end 
end 
check;

% need to deal with the inlet and outlet
load inletProfiles.mat;
% fit the profile data
for m = 1:10
    [xData, yData] = prepareCurveData(inletProfiles(:,12), inletProfiles(:,m));
    ft = 'linearinterp';
    [fitresult, gof] = fit(xData, yData, ft, 'Normalize', 'on');
    fitresults{m,1} = fitresult; 
end 

tolTol = 6e-2; 
xAnchors = [0.04545454545500001, 8.95451];
for ii = 1:length(xAnchors)
    xxUp = xAnchors(ii) + tolTol;
    xxLow = xAnchors(ii) - tolTol;
    for jj = 1:length(Cx)
        xxMesh = Cx(jj);
        yyMesh = Cy(jj);
        if (xxMesh >= xxLow && xxMesh <= xxUp)
            p(jj,1) = 2 * feval(fitresults{1,1}, yyMesh); 
            U(jj,1) = 2 * feval(fitresults{2,1}, yyMesh);
            U(jj,2) = 2 * feval(fitresults{6,1}, yyMesh);
            U(jj,3) = 2 * feval(fitresults{9,1}, yyMesh);
            Tau(jj,1) = 2 * feval(fitresults{3,1}, yyMesh);
            Tau(jj,2) = 2 * feval(fitresults{4,1}, yyMesh);
            Tau(jj,3) = 2 * feval(fitresults{5,1}, yyMesh);
            Tau(jj,4) = 2 * feval(fitresults{7,1}, yyMesh);
            Tau(jj,5) = 2 * feval(fitresults{8,1}, yyMesh);
            Tau(jj,6) = 2 * feval(fitresults{10,1}, yyMesh);
            %plot(2.*feval(fitresult, yyMesh), yyMesh, 'kx'); % plot the inlet velocity profile for verification
            %plot(Cx(jj), Cy(jj), 'k.'); % plot the cell centre for verification
        end
    end 
end 
% hold off; axis equal; 
% axis([0,9,0,3.1])

% interpolate lower wall pressure
load pLowerWall.mat; load CxLowerWall.mat; 
xLES = pLowerWall(:,2);
pLES = pLowerWall(:,1); 
CxLW = CxLowerWall; 
[xData, yData] = prepareCurveData( xLES, pLES );
ft = 'linearinterp';
[fitresult, gof] = fit( xData, yData, ft, 'Normalize', 'on' );
pLowerOF = feval(fitresult, CxLW); 
figure; hold on;
plot(xLES, pLES, 'k-', CxLW, feval(fitresult, CxLW), 'b--'); 
legend('LES', 'Interpolated');

%-------------------------------
% write the openfoam files
f1 = fopen('UList', 'w');
f2 = fopen('TauList', 'w');
f3 = fopen('pList', 'w');
f4 = fopen('pLowerWall', 'w'); 
for k = 1:length(Cx)
     if k == length(Cx)
         fprintf(f1, '(%.16d %.16d %.16d)', [U(k,1), U(k,2), U(k,3)]);
         fprintf(f2, '(%.16d %.16d %.16d %.16d %.16d %.16d)', [Tau(k,1), Tau(k,2), Tau(k,3), Tau(k,4), Tau(k,5), Tau(k,6)]);
         fprintf(f3, '%.16d', p(k));
     else
         fprintf(f1, '(%.16d %.16d %.16d)\n', [U(k,1), U(k,2), U(k,3)]);
         fprintf(f2, '(%.16d %.16d %.16d %.16d %.16d %.16d)\n', [Tau(k,1), Tau(k,2), Tau(k,3), Tau(k,4), Tau(k,5), Tau(k,6)]);
         fprintf(f3, '%.16d\n', p(k));
     end
end 
copyfile UList interpolatedFiles
copyfile pList interpolatedFiles
copyfile TauList interpolatedFiles

for m = 1:length(CxLW)
    %if m == length(Cx)
    fprintf(f4, '%.16d\n', pLowerOF(m)-46.862998962402340); 
    %else
    %   fprintf(f4, '%.16d', pLowerOF(m)); 
    %end 
end 
copyfile pLowerWall interpolatedFiles