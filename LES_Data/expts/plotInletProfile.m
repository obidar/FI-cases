clc; clear; close all;
load inletProfiles.mat;
plot(2.*inletProfile(:,1), inletProfile(:,2), 'r.');
hold on;
plot(d(:,2), d(:,1), 'b-','linewidth', 2); % profile data raw
plot(inletProfilePoint(:,1), inletProfilePoint(:,3), 'kx')
hold off; 
legend('cell interp', 'raw', 'point interp')
