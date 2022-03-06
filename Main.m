clear
clc
%% Addpath
% Data structure should be a 3D Cell with M * N * P
% M               -- index of the input packets
% N               -- index of the Test-Point (TP)
% P               -- index of different data set

csi_data = load('Your DATA.mat');

%% Parameters
%% Basic

% chn 6
% basic_parameters.Freq = 2.437e9;
% chn 10
% basic_parameters.Freq = 2.457e9;
% chn 149
% basic_parameters.Freq = 5.745e9;

% chn 161
basic_parameters.Freq = 5.805e9;
basic_parameters.Sub_freq_delta = 312.5*10^3*4;
basic_parameters.Antenna_distance = 0.03;
basic_parameters.Carrier_index_HT40 = [-58,-54,-50,-46,-42,-38,-34,-30,-26,-22,-18,-14,-10,-6,-2,2,6,10,14,18,22,26,30,34,38,42,46,50,54,58];

% Search range
search_range.theta_lb = 1;
search_range.theta_ub = 179;
search_range.theta_resolution = 1;

search_range.tau_lb = 0;
search_range.tau_ub = 100;
search_range.tau_resolution = 1;

% DBSCAN Setting
dbscan.Epsilion_preprocess = 15;
dbscan.Minpts_preprocess = 8;

dbscan.Epsilion_cluster = 0.1;
dbscan.Minpts_cluster = 20;
dbscan.Normalization_cluster = 1;

%% Advanced
% Parallel Compting
config.Parallel = 0;

%% AoA Estimation
[aoa_tof_weight,aoa_tof_weight_packet,K] = MoLA(csi_data,basic_parameters,search_range,config.Parallel);

% Cluster the points using DBSCAN
[estimated_aoa, estimated_aoa_cluster_O,~] = DBSCANCluster(aoa_tof_weight_packet,dbscan.Epsilion_cluster, dbscan.Minpts_cluster, dbscan.Normalization_cluster);
angle_of_arrival = weighted_likelihood(estimated_aoa_cluster_O, estimated_aoa);