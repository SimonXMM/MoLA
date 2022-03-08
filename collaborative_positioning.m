%%
clear
clc
%%
load('source.mat');
%% Extract the AoA packets from three APs
for i = 1:38
    SelectedAoAPacket.ap1(i,1) = {MoLAPacket.ap1{i,3}{1,MoLAPacket.eval1(i,4)}};
    SelectedAoAPacket.ap2(i,1) = {MoLAPacket.ap2{i,3}{1,MoLAPacket.eval2(i,4)}};
    SelectedAoAPacket.ap3(i,1) = {MoLAPacket.ap3{i,3}{1,MoLAPacket.eval3(i,4)}};
    SelectedAoAPacket.ap1{i,1}(:,2) = [];
    SelectedAoAPacket.ap2{i,1}(:,2) = [];
    SelectedAoAPacket.ap3{i,1}(:,2) = [];
%     time_dis(i,1) = mean(aoa_packet_ap1_1{i,1}(:,2));
%     time_dis(i,2) = time_dis(i,1) * 10^-9 * 3 * 10^8;
end

%% Segenment the DATA
clear InputAOAData
SegNumber = 1; % smaller than 6
InputAOAData = segmentation(SelectedAoAPacket.ap1,SelectedAoAPacket.ap2,SelectedAoAPacket.ap3,SegNumber);
%% Calculate the global weights based CDF
clear Temp ErrorGlobal Result

Temp.weights_global = [0,1,0];
% Weights = [repmat(Temp.weights_global(1),38,1),repmat(Temp.weights_global(2),38,1),repmat(Temp.weights_global(3),38,1)];

[Temp.error_global_packet,~] = coor_lls(InputAOAData,Weights,dis_real,coor_real);
ErrorGlobal = cell2mat(Temp.error_global_packet(:));
figure
cdfplot(ErrorGlobal);
[~,Result.GlobalWeightsBased] = ecdf(ErrorGlobal);
fprintf('median error = %.2fm\n',median(Result.GlobalWeightsBased));

%%
clear Temp

[Temp.error_weighted_packet,~] = coor_lls(InputAOAData,WeightsPoint,dis_real,coor_real);
ErrorPoint = cell2mat(Temp.error_weighted_packet(:));

hold on
cdfplot(ErrorPoint);
hold off

[~,x_temp] = ecdf(error_weighted);
fprintf('The median error = %.2f\n',median(x_temp));
%%
clear temp1 temp2 error_global_los error_weighted_los
figure(2)
temp1 = cell2mat(error_global_packet);
error_global_los = temp1(1:38,:);
error_global_los = error_global_los(:);
cdfplot(error_global_los);
hold on
temp2 = cell2mat(error_weighted_packet);
error_weighted_los = temp2(1:38,:);
error_weighted_los = error_weighted_los(:);
cdfplot(error_weighted_los);
hold off
legend('single','weighted')

