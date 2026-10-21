clear, clc, close all
figure('Color','w');
%AERE 3220 Lab 5 Data
%Brice McNeley, Joseph Navin, Andrew Kura, Nico Mennano
compliance_data = readmatrix('compliance_S3G3_1.csv', 'NumHeaderLines', 2);
%Column 1 = blank
%Column 2 = Time (s)
%Column 3 = Elongation (in)
%Column 4 = Load (lbf)
time_compliance       = compliance_data(:,2);
elongation_compliance = compliance_data(:,3);
load_compliance       = compliance_data(:,4);

% Marker style for all data plots
ms = 2;   % marker size

n = 2;
p = polyfit(load_compliance, elongation_compliance, n);
loadSmooth = linspace(min(load_compliance), max(load_compliance), 200);
LgFit = polyval(p, loadSmooth);
plot(load_compliance(1:15:end), elongation_compliance(1:15:end), 'o', ...
    'MarkerSize', ms, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', ...
    'DisplayName', 'Experimental Data');
hold on;
plot(loadSmooth, LgFit, '-b', 'LineWidth', 2, 'DisplayName', sprintf('Polynomial Fit (Degree %d)', n));
grid on;
title('Elongation vs. Load (Compliance)');
xlabel('Load (lbf)');
ylabel('Elongation (in)');
legend('Location', 'best');

tensile_data = readmatrix('tensile_S3G3_1.csv', 'NumHeaderLines', 2);
%Column 1 = blank (export artifact)
%Column 2 = Time (s)
%Column 3 = Elongation (in)
%Column 4 = Load (lbf)
%Column 5 = Video Extensometer Strain (in/in)
time_tensile  = tensile_data(:,2);
elong_tensile = tensile_data(:,3);
load_tensile  = tensile_data(:,4);
vidStrain     = tensile_data(:,5);

% System elongation error Lg from the COMPLIANCE fit p
% (clamp keeps the polynomial inside the range it was fit on)
load_eval = min(max(load_tensile, min(load_compliance)), max(load_compliance));
Lg = polyval(p, load_eval);
% Corrected elongation
elong_corrected = elong_tensile - Lg;

figure('Color','w');
plot(load_tensile, elong_tensile, 'o', 'MarkerSize', ms, ...
    'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'DisplayName', 'Raw Instron elongation'); hold on;
plot(load_tensile, Lg, '-b', 'LineWidth', 2, 'DisplayName', 'System error L_g(load)');
plot(load_tensile, elong_corrected, 'o', 'MarkerSize', ms, ...
    'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'DisplayName', 'Corrected elongation');
grid on;
xlabel('Load (lbf)');
ylabel('Elongation (in)');
title('Compliance Correction of Tensile Elongation');
legend('Location', 'best');

% New .csv with updated values
results = table(time_tensile, load_tensile, elong_tensile, Lg, elong_corrected, vidStrain, ...
    'VariableNames', {'Time_s','Load_lbf','Elongation_raw_in', ...
    'SystemError_Lg_in','Elongation_corrected_in', ...
    'VideoStrain_in_per_in'});
writetable(results, 'tensile_S3G3_corrected.csv');

gage_length = 4;                    %4-inch gage length
width       = 2;                    %in
thickness   = 0.025;                %in
area        = width * thickness;    %in^2
average_strain      = elong_corrected / gage_length;  %in/in
average_microstrain = average_strain * 1e6;           %microstrain
stress              = load_tensile / area;            %psi

% Fit only the clean linear region (skip the low-load seating points)
fitMask = load_tensile > 20;        % lbf
pE = polyfit(average_strain(fitMask), stress(fitMask), 1);
E  = pE(1);                         % psi (slope of stress vs. strain)
strainFit = linspace(min(average_strain(fitMask)), max(average_strain(fitMask)), 100);
stressFit = polyval(pE, strainFit);

figure('Color','w');
plot(average_microstrain, stress, 'o', 'MarkerSize', ms, ...
    'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'DisplayName', 'Corrected data'); hold on;
plot(strainFit*1e6, stressFit, '-r', 'LineWidth', 2, ...
    'DisplayName', sprintf('Linear fit, E = %.2f Msi', E/1e6));
grid on;
xlabel('Average Strain (\mu\epsilon)');
ylabel('Stress (psi)');
title('Stress vs. Strain (Compliance-Corrected Instron Data)');
legend('Location', 'best');
fprintf('Young''s modulus E = %.3e psi (%.2f Msi)\n', E, E/1e6);

%Video extensometer: stress vs. strain, smoothing, and three fits
% Raw video strain (in/in) and microstrain
vid_raw = vidStrain;

% Running average
win = 5;
vid_smooth = movmean(vid_raw, win);

% Trim negative strains (sample wobble at start)
keep    = vid_smooth >= 0;
eps_v   = vid_smooth(keep);% in/in
sig_v   = stress(keep);% psi
N       = numel(eps_v);
fprintf('Video data: %d points, %d trimmed as negative\n', N, sum(~keep));

% Three fit ranges (by data index, in loading order)
idxAll   = 1:N; %all non-negative data
idxSkip  = (floor(N/3)+1):N; %skip first one-third
idxTop   = (floor(N/2)+1):N; %top one-half

ranges = {idxAll, idxSkip, idxTop};
labels = {'All data', 'Skip first 1/3', 'Top 1/2'};
colors = {[0.85 0.1 0.1], [0 0.45 0.74], [0.2 0.6 0.2]};
E_v    = zeros(1,3);

figure('Color','w');
plot(vid_raw*1e6, stress, 'o', 'MarkerSize', ms, ...
    'MarkerFaceColor', [0.7 0.7 0.7], 'MarkerEdgeColor', 'none', ...
    'DisplayName', 'Raw video strain'); hold on;
plot(eps_v*1e6, sig_v, 'o', 'MarkerSize', ms, ...
    'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none', ...
    'DisplayName', sprintf('Smoothed (%d-pt running avg)', win));

for k = 1:3
    idx  = ranges{k};
    pV   = polyfit(eps_v(idx), sig_v(idx), 1);
    E_v(k) = pV(1);
    eFit = linspace(min(eps_v(idx)), max(eps_v(idx)), 100);
    plot(eFit*1e6, polyval(pV, eFit), '-', 'Color', colors{k}, 'LineWidth', 1.75, ...
        'DisplayName', sprintf('%s: E = %.2f Msi', labels{k}, E_v(k)/1e6));
end

grid on;
xlabel('Video Extensometer Strain (\mu\epsilon)');
ylabel('Stress (psi)');
title('Stress vs. Video Extensometer Strain');
legend('Location', 'southeast');

for k = 1:3
    fprintf('%-15s E = %.3e psi (%.2f Msi)\n', labels{k}, E_v(k), E_v(k)/1e6);
end

%Strain gage: align with load, stress vs. strain, Young's modulus
sg_lines = readlines('strain_gauge_S3G3.txt');
sg_lines = sg_lines(2:end); %drop header
sg_lines = sg_lines(strlength(strtrim(sg_lines)) > 0); %drop blank lines
sg_parts = split(sg_lines, char(9));
sg_raw   = str2double(sg_parts(:,2)); %reader output (microstrain, full-bridge setting)

%Half-bridge II read in full-bridge mode: divide by 2
sg_ue = sg_raw / 2; %microstrain

%Align with loading: max reading = 200 lbf, count back 20 s
dt_sg     = 0.5; %s, sample interval
load_rate = 10; %lbf/s
t_load    = 200 / load_rate; %20 s of loading
[~, iMax] = max(sg_ue);
iStart    = iMax - round(t_load / dt_sg); %40 samples back

sg_load_ue = sg_ue(iStart:iMax) - sg_ue(iStart); %zero to initial reading
sg_strain  = sg_load_ue * 1e-6; %in/in

%"Reinvented" load every 0.5 s, then stress
sg_time   = (0:numel(sg_strain)-1)' * dt_sg; %s
sg_loadLb = load_rate * sg_time; %lbf, 0 to 200
sg_stress = sg_loadLb / area; %psi

fprintf('Gage alignment: start sample %d (raw %g), max sample %d (raw %g)\n', ...
    iStart, sg_raw(iStart), iMax, sg_raw(iMax));

%Linear fit for Young's modulus
pSG  = polyfit(sg_strain, sg_stress, 1);
E_sg = pSG(1); %psi
eFit = linspace(min(sg_strain), max(sg_strain), 100);

figure('Color','w');
plot(sg_load_ue, sg_stress, 'o', 'MarkerSize', ms+1, ...
    'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none', 'DisplayName', 'Strain gage data'); hold on;
plot(eFit*1e6, polyval(pSG, eFit), '-r', 'LineWidth', 1.75, ...
    'DisplayName', sprintf('Linear fit, E = %.2f Msi', E_sg/1e6));
grid on;
xlabel('Gage Strain (\mu\epsilon)');
ylabel('Stress (psi)');
title('Stress vs. Strain Gage Strain');
legend('Location', 'southeast');

fprintf('Strain gage Young''s modulus E = %.3e psi (%.2f Msi)\n', E_sg, E_sg/1e6);