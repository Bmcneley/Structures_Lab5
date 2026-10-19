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
time_tensile = tensile_data(:,1);  
elong_tensile = tensile_data(:,2);  
load_tensile = tensile_data(:,3);  
vidStrain = tensile_data(:,4);   

% System elongation error
load_eval = min(max(load_tensile, min(load_compliance)), max(load_compliance)); 
pt = polyfit(load_tensile, elong_tensile, n);
Lg = polyval(pt, load_eval);      

% Corrected elongation
elong_corrected = elong_tensile - Lg;      

figure('Color','w');
plot(load_tensile, elong_tensile, '.k', 'DisplayName', 'Raw Instron elongation'); hold on;
plot(load_tensile, Lg, '-b', 'LineWidth', 2, 'DisplayName', 'System error L_g(load)');
plot(load_tensile, elong_corrected, '.r', 'DisplayName', 'Corrected elongation');
grid on; 
xlabel('Load (lbf)'); 
ylabel('Elongation (in)');
title('Compliance Correction of Tensile Elongation');
legend('Location', 'best');

% New .csv with updates values
results = table(time_tensile, load_tensile, elong_tensile, Lg, elong_corrected, vidStrain, ...
    'VariableNames', {'Time_s','Load_lbf','Elongation_raw_in', ...
                      'SystemError_Lg_in','Elongation_corrected_in', ...
                      'VideoStrain_in_per_in'});

writetable(results, 'tensile_S3G3_corrected.csv');
