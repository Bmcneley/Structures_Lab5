clear, clc, clf
figure('Color','w'); 

%AERE 3220 Lab 5 Data
%Brice McNeley, Joseph Navin, Andrew Kura, Nico Mennano

compliance_data = readmatrix('compliance_S3G3_1.csv', 'NumHeaderLines', 2);
%Column 1 = Time (s)
%Column 2 = Elongation (in)
%Column 3 = Load (lbf)
time_compliance = compliance_data(:,1);
elongation_compliance = compliance_data(:,2);
load_compliance = compliance_data(:,3);

n = 2;
p = polyfit(load_compliance, elongation_compliance, n);
loadSmooth = linspace(min(load_compliance), max(load_compliance), 200);
LgFit = polyval(p, loadSmooth);

plot(load_compliance(1:15:end), elongation_compliance(1:15:end), '.k', 'MarkerSize', 8, 'DisplayName', 'Experimental Data');
hold on;
plot(loadSmooth, LgFit, '-b', 'LineWidth', 2, 'DisplayName', sprintf('Polynomial Fit (Degree %d)', n));
grid on;
title('Load vs. Elongation (Compliance)');
xlabel('Load (lbf)');
ylabel('Elongation (in)');
legend('Location', 'best'); 

tensile_data = readmatrix('tensile_S3G3_1.csv', 'NumHeaderLines', 2);
%Column 1 = Time (s)
%Column 2 = Elongation (in)
%Column 3 = Load (lbf)
%Column 4 = Video Extensometer Strain (in/in)
