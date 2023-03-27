%% This code is for unsteady simulation data collection for smooth post-processing
% this code will read all the unsteady data and save it as matrices in the
% workspace to work in

% Aarohi A. Mudholkar
% 16.03.2023

clc;
clear;
cd('X:\Research Project\unsteady\E-7 data handling\');
% cd ('D:\Research Project\290K\')
% load the previous .mat data to avoid losses
% load data.mat
%% Make 3D matrices of all the data in csv files

% DONE
% [pts6_05_3, plt6_05_3, rex6_05_3, xdn6_05_3, ts6_05_3] = conversion('trial E-6\CFL_0.5_3');
% [pts6_05_4, plt6_05_4, rex6_05_4, xdn6_05_4, ts6_05_4] = conversion('trial E-6\CFL_0.5_4');
% [pts6_05_5, plt6_05_5, rex6_05_5, xdn6_05_5, ts6_05_5] = conversion('trial E-6\CFL_0.5_5');


%% E-7
% cd ('D:\Research Project\290K\')
% [ptsB, pltB, rexB, xdnB, tsB] = conversion('B\');
% [ptsC, pltC, rexC, xdnC, tsC] = conversion('C\');
% [ptsD, pltD, rexD, xdnD, tsD] = conversion('D\');
% [ptsE, pltE, rexE, xdnE, tsE] = conversion('E\');
% [ptsG, pltG, rexG, xdnG, tsG] = conversion('G\');
% 
cd ('X:\Research Project\unsteady\E-7 data handling\e-7 sim monitors\');
% [B7] = monitorprocess('B7*.csv');
% [C7] = monitorprocess('C7*.csv');
% [D7] = monitorprocess('D7*.csv');
% [E7] = monitorprocess('E7*.csv');
% [G7] = monitorprocess('G7*.csv');

phytime_iters = itertime();
%% Download it in the collected data workspace
cd('X:\Research Project\unsteady\E-7 data handling\');
% save data.mat
save monitordat_7.mat
%% Nomenclature 

% pts = 70% chord points 
% plt = along plate 
% rex = along Rex lines
% xdn = along whole domain in teh centre
% ts = matrix for that stores values per time step
% 
% xxx6_05_3 : E-6, CFL=0.5, 3 steps in temporal discretization
% xxx7_50_5 : E-7, CFL=50, 5 steps in temporal discretization 
% xxx5_auto_4 : E-4, CFL=auto, 4 steps in temporal discretization

%% FUNCTIONS

% read csv file and turn into 3D matrix and a data storage thing
function [matrix3D, ts_labels] = read_csv_files(file_root)
% this function will find all the csv files with the given root in the
% opened folder and will create a 3D matrix along with its labels for data
% manipulation 

file_list = dir([file_root]);       % list of all csv files that have the given file root
matrix3D = [];                      % Initialize the 3D matrix

% Loop through all CSV files in the folder
for i = 1:length(file_list)
    current_file_path = [file_list(i).name];    
    current_data = readmatrix(current_file_path);  % Read the current CSV file
    
    % Add the current data to the 3D matrix
    matrix3D(:, :, i) = current_data;           
    
    current_file_name = file_list(i).name;
    
    % Extract the remaining part of the file name using regular expressions
    if file_root == '70c_t_*.csv'
        file_number = regexp(current_file_name, '70c_t_(\d+)\.csv', 'tokens');
    elseif file_root == 'Rex_t_*.csv'
        file_number = regexp(current_file_name, 'Rex_t_(\d+)\.csv', 'tokens');
    elseif file_root == 'plt_t_*.csv'
        file_number = regexp(current_file_name, 'plt_t_(\d+)\.csv', 'tokens');
    elseif file_root == 'xdn_t_*.csv'
        file_number = regexp(current_file_name, 'xdn_t_(\d+)\.csv', 'tokens');
    else
        disp('Your files to be processed arent here')
    end

    file_number = file_number{1}{1};    
    % Store the file name in the cell array
    ts_label_cell_array{i} = file_number;
end 

% converting cell array to coloumn matrix 
for i = 1:length(ts_label_cell_array)
    ts_labels(i) = str2double(ts_label_cell_array{i});
end
ts_labels = ts_labels';
end 

% to go back to mother directory
function goback()
% cd('X:\Research Project\2-unsteady study\');
cd ('D:\Research Project\290K\');
end 

% sorting and changing all Inf values to NaN
function matrixx = sortnnan(og)
for k = 1:size(og,3)    % for each time step 
    a = og(:,:,k);   % holding in another variable
    a = sortrows(a,2);          % sorting wrt ypos
    a(isinf(a)) = NaN;          % changing all Inf values to NaN
    matrixx(:,:,k) = a;
end 
end 

% to find boundary layer thickness
function del = finddelta(M)         
% you put in a particular time step and turn it into a 2D matrix

a = M(:,9);          % make simpler and convert to an array 
flag = 0;           % set flag = 0

for i = 1:size(a)
    if (a(i) < 0) && (flag == 0)
    index = i-1;
    flag = 1;
    end
end

del = M(index,2);       % at this index, ypos = delta 
end

% to convert all the data into 3D matrices 
function [matrix7c, matrixplt, matrixrex, matrixxdir, matrixts] = conversion(path_of_files)

% opens the general folder (of the time step value)
cd(path_of_files);

% data at 70% chord
cd '0.7c'\;
[matrix7c, matrixts] = read_csv_files('70c_t_*.csv');
cd('..');

% along plate 
cd 'plt'\;
[matrixplt, matrixts] = read_csv_files('plt_t_*.csv');
cd('..');

% along Rex lines 
cd 'Rex'\;
[matrixrex, matrixts] = read_csv_files('Rex_t_*.csv');
cd('..');

% x direction probes 
cd 'xdn'\;
[matrixxdir, matrixts] = read_csv_files('xdn_t_*.csv');
cd('..');
goback();
% all the_ts should be the same. better make just one of those 
end 

% to process the monitor data 
function [matrix2D] = monitorprocess(model)
 
file_list = dir([model]);       % list of all csv files that have the given file root
% timetaken = (linspace(1,1000000,1000000))';         % same as total_solver_elapsed_time
% temp = NaN(size(timetaken));        % generic max no of iters = total_solver_elapsed_time size
% matrix2D(1:size(file_list),1:20) = 0;                  % Initialize the 2D matrix


% Loop through all CSV files in the folder
for i = 1:length(file_list)
    current_file_path = [file_list(i).name];    
    current_data = readmatrix(current_file_path);  % Read the current CSV file
    
    % Add the current data to the 3D matrix
%     matrix2D(:, i) = current_data;   
    if contains(file_list(i).name, '_cf0.7.csv')
        matrix2D(:,1) = current_data(:,1);      % 1: physical time
        matrix2D(:,4) = current_data(:,2);      % 4: Cf at 0.7c
    elseif contains(file_list(i).name, '_iters_phytime.csv')
        matrix2D(:,2) = current_data(:,2);      % 2: iterations
    elseif contains(file_list(i).name, '_solvertime_phytime.csv')
        matrix2D(:,3) = current_data(:,2);      % 3: total solver elapsed time
    elseif contains(file_list(i).name, '_wallshear0.7.csv')
        matrix2D(:,5) = current_data(:,2);      % 5: wall shear stress
    elseif contains(file_list(i).name, '_rho-mu-vol.csv')
        matrix2D(:,6) = current_data(:,2);      % 6: density
        matrix2D(:,7) = current_data(:,3);      % 7: dynamic viscosity
    elseif contains(file_list(i).name, '_mach0.7.csv')
        matrix2D(:,8) = current_data(:,2);      % 8: mach number at 0.7c
    elseif contains(file_list(i).name, '_Ub-surfav.csv')
        matrix2D(:,9) = current_data(:,2);      % 9: Ub instantaneous
    elseif contains(file_list(i).name, '_kmax-plate.csv')
        matrix2D(:,10) = current_data(:,2);      % 10: max tke over plate
    elseif contains(file_list(i).name, '_mdots.csv')
        matrix2D(:,11) = current_data(:,2);      % 11: inlet mass flow rate
        matrix2D(:,12) = current_data(:,3);      % 12: outlet mass flow rate
        matrix2D(:,13) = current_data(:,4);      % 13: LE mass flow rate
        matrix2D(:,14) = current_data(:,5);      % 14: TE mass flow rate
    elseif contains(file_list(i).name, '_solvertime_iters.csv')
        continue;
%         [row, ~] = find(timetaken(:,1) == current_data(:,1));
%         temp(row) = current_data(:,2);
    else
        disp('why is there an extra csv file?');
    end
end


end 


% Iteration data function
function [matrix2D] = itertime()
 
file_list = dir(['*_iters_phytime.csv']);       % list of all csv files that have the given file root

% Loop through all CSV files in the folder
for i = 1:length(file_list)
    current_file_path = [file_list(i).name];    
    current_data = readmatrix(current_file_path);  % Read the current CSV file
    
    % Add the current data to the 3D matrix
%     matrix2D(:, i) = current_data;   
    if contains(file_list(i).name, 'A')
        matrix2D(:,1) = current_data(:,2);      % 1: A iterations
    elseif contains(file_list(i).name, 'B')
        matrix2D(:,2) = current_data(:,2);      % 2: B iterations
    elseif contains(file_list(i).name, 'C')
        matrix2D(:,3) = current_data(:,2);      % 3: C iterations
    elseif contains(file_list(i).name, 'D')
        matrix2D(:,4) = current_data(:,2);      % 4: D iterations
    elseif contains(file_list(i).name, 'E')
        matrix2D(:,5) = current_data(:,2);      % 5: E iterations
    elseif contains(file_list(i).name, 'F')
        matrix2D(:,6) = current_data(:,2);      % 6: F iterations
    elseif contains(file_list(i).name, 'G')
        matrix2D(:,7) = current_data(:,2);      % 7: G iterations
    elseif contains(file_list(i).name, 'H')
        matrix2D(:,8) = current_data(:,2);      % 8: H iterations
    else
        disp('why is there an extra csv file?');
    end
end


end 
