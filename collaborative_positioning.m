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

%%
% %% Cannot work by only using AoAs
% clear input coor error
% for i = 1:38
%     input(i,1) = X(i,1);
%     input(i,2) = X(i,2);
%     input(i,3) = X(i,3);
% 
%     coor(i,1:2) = LLS_DOA(input,'123');
%     error(i,1) = sqrt((coor(i,1)-coor_real(i,1)).^2 + (coor(i,2)-coor_real(i,2)).^2);  
% end


% %% Global weights finding
%     clear weights weights_temp s idx ll
%     ll = 1;
%     weights_temp = zeros(length(0:0.05:1)*3,3);
% for ii = 0:0.05:1
%     for jj = 0:0.05:1
%         for kk = 0:0.05:1
%             weights_temp(ll,1) = ii;
%             weights_temp(ll,2) = jj;
%             weights_temp(ll,3) = kk;
%             ll = ll + 1;
%         end
%     end
% end
% 
% s = weights_temp(:,1) + weights_temp(:,2) + weights_temp(:,3);
% weights = weights_temp(ismembertol(s,1),:);
% 
% clear weights_temp s idx ll ii jj kk
% 
% %%
% clear error_final_all temp x
% error_final_all = cell(length(weights),3);
% for ii = 1:length(weights)
%     temp = coor_lls(X,weights(ii,:),dis_real,coor_real);
%     [~,x] = ecdf(temp);
%     error_final_all(ii,1) = {temp};
%     error_final_all(ii,2) = {weights(ii,:)};
%     error_final_all(ii,3) = {median(x)};
% end
% %%
% clear error_point
% [M,I] = min(cell2mat(error_final_all(:,3)));
% fprintf('The minimal median error = %.2fm when AP1_weights = %.2f, AP2_weights = %.2f, AP3_weights = %.2f\n',M,cell2mat(error_final_all(I,2)));
% 
% for ii = 1:length(error_final_all)
%     error_point(:,ii) = error_final_all{ii,1};
% end
% %%
% h = figure(1);
% % scatter3(weights(:,1),weights(:,2),weights(:,3),100,cell2mat(error_final_all(:,3)),'filled');
% scatter3(weights(:,1),weights(:,2),weights(:,3),100,error_point(28,:),'filled');
% xlabel('AP1 Weights');
% ylabel('AP2 Weights');
% zlabel('AP3 Weights');
% colormap(h, flipud(jet))
% colorbar
% view(65,35)
% %%
% h1 = figure(1);
% 
% tiledlayout(1,4)
% ax1 = nexttile;
% scatter3(weights(:,1),weights(:,2),weights(:,3),50,error_point(6,:),'filled');
% xlabel('AP1 Weights');
% ylabel('AP2 Weights');
% zlabel('AP3 Weights');
% caxis(ax1,[0.1 3])
% colorbar
% view(65,35)
% 
% ax2 = nexttile;
% scatter3(weights(:,1),weights(:,2),weights(:,3),50,error_point(27,:),'filled');
% xlabel('AP1 Weights');
% ylabel('AP2 Weights');
% zlabel('AP3 Weights');
% caxis(ax2,[0.1 3])
% colorbar
% view(65,35)
% 
% 
% ax3 = nexttile;
% scatter3(weights(:,1),weights(:,2),weights(:,3),50,error_point(36,:),'filled');
% xlabel('AP1 Weights');
% ylabel('AP2 Weights');
% zlabel('AP3 Weights');
% caxis(ax3,[0.1 3])
% colorbar
% view(65,35)
% 
% ax4 = nexttile;
% scatter3(weights(:,1),weights(:,2),weights(:,3),50,error_point(25,:),'filled');
% xlabel('AP1 Weights');
% ylabel('AP2 Weights');
% zlabel('AP3 Weights');
% caxis(ax4,[0.1 10])
% colorbar
% view(65,35)
% 
% colormap(h1, flipud(jet))


