%AERE 3220 Lab 5: Raw Data Plots (Data section)
%Brice McNeley, Joseph Navin, Andrew Kura, Nico Mennano
clear, clc, close all
%Marker style for all data plots
ms = 2; %marker size

%Compliance Test (Raw)
compliance_data = readmatrix('compliance_S3G3_1.csv', 'NumHeaderLines', 2);
%Column 1 = blank (export artifact)
%Column 2 = Time (s)
%Column 3 = Elongation (in)
%Column 4 = Load (lbf)
time_compliance       = compliance_data(:,2);
elongation_compliance = compliance_data(:,3);
load_compliance       = compliance_data(:,4);

figure('Color','w');
plot(time_compliance, load_compliance, 'o', 'MarkerSize', ms, ...
    'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none');
grid on;
xlabel('Time (s)');
ylabel('Load (lbf)');
title('Compliance Test: Raw Load vs. Time');

figure('Color','w');
plot(time_compliance, elongation_compliance, 'o', 'MarkerSize', ms, ...
    'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'none');
grid on;
xlabel('Time (s)');
ylabel('Elongation (in)');
title('Compliance Test: Raw Elongation vs. Time');

%Tensile test (raw)
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

figure('Color','w');
plot(time_tensile, load_tensile, 'o', 'MarkerSize', ms, ...
    'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none');
grid on;
xlabel('Time (s)');
ylabel('Load (lbf)');
title('Tensile Test: Raw Load vs. Time');

figure('Color','w');
plot(time_tensile, elong_tensile, 'o', 'MarkerSize', ms, ...
    'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'none');
grid on;
xlabel('Time (s)');
ylabel('Elongation (in)');
title('Tensile Test: Raw Instron Elongation vs. Time');

figure('Color','w');
plot(time_tensile, vidStrain*1e6, 'o', 'MarkerSize', ms, ...
    'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'none');
grid on;
xlabel('Time (s)');
ylabel('Strain (\mu\epsilon)');
title('Tensile Test: Raw Video Extensometer Strain vs. Time');

%Strain gage (raw)
sg_lines = readlines('strain_gauge_S3G3.txt');
sg_lines = sg_lines(2:end); %drop header
sg_lines = sg_lines(strlength(strtrim(sg_lines)) > 0); %drop blank lines
sg_parts  = split(sg_lines, char(9)); %[timestamp, value]
sg_strain = str2double(sg_parts(:,2)); %microstrain
%Convert HH:MM:SS:ffff to elapsed seconds
sg_clock = regexp(sg_parts(:,1), '\d+:\d+:\d+:\d+', 'match', 'once');
hmsf     = split(sg_clock, ':');
sg_sec   = str2double(hmsf(:,1))*3600 + str2double(hmsf(:,2))*60 + ...
           str2double(hmsf(:,3)) + str2double(hmsf(:,4)) ./ 10.^strlength(hmsf(:,4));
time_sg  = sg_sec - sg_sec(1); %elapsed time (s)

figure('Color','w');
plot(time_sg, sg_strain, 'o-', 'MarkerSize', ms+1, 'LineWidth', 0.75, ...
    'Color', [0 0.45 0.2], 'MarkerFaceColor', [0 0.45 0.2], 'MarkerEdgeColor', 'none');
grid on;
xlabel('Time (s)');
ylabel('Strain (\mu\epsilon)');
title('Strain Gage: Raw Strain vs. Time');