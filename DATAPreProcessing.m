%%
clear
clc
%%
load('source.mat');

%% Extract the AoA packets from three APs

for i = 1:38
    aoa_packet_ap1(i,1) = {maofi_packet_AP1{i,3}{1,evaluation_AP1(i,4)}};
    aoa_packet_ap2(i,1) = {maofi_packet_AP2{i,3}{1,evaluation_AP2(i,4)}};
    aoa_packet_ap3(i,1) = {maofi_packet_AP3{i,3}{1,evaluation_AP3(i,4)}};
    aoa_packet_ap1{i,1}(:,2) = [];
    aoa_packet_ap2{i,1}(:,2) = [];
    aoa_packet_ap3{i,1}(:,2) = [];
%     time_dis(i,1) = mean(aoa_packet_ap1_1{i,1}(:,2));
%     time_dis(i,2) = time_dis(i,1) * 10^-9 * 3 * 10^8;
end