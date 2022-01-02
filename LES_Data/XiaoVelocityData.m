clc; clear; close all;

load tenPoints.mat; 

tol = 1e-4;

profileRefFieldInversion = 1e16.*ones(length(Cy), 1);

check = 0;

for i = 1:length(anchors)
    
    xRef = anchors(i,1); xUp = xRef + tol; xLow = xRef - tol;
    yRef = anchors(i,2); yUp = yRef + tol; yLow = yRef - tol; 
    
    for j = 1:length(Cy)
        
        x = Cx(j);  y = Cy(j);
        
        if (y >= yLow && y <= yUp && x >= xLow && x <= xUp)
            
            profileRefFieldInversion(j,1) = UxDNS(j,1); 
            
            check = check + 1;
        
        end
    end 
end 

file = fopen('profileRefXiao', 'w');
for i=1:length(Cy)
    fprintf(file, '%.16d\n', profileRefFieldInversion(i)); 
end 
fclose(file);
copyfile profileRefXiao interpolatedFiles
