function [estimated_aoa, X_cluster_O, X_cluster_N] = DBSCANCluster(aoa_tof_packet, epsilion, minpts, normalization)
     
    input_matrix = aoa_tof_packet;
    
    N = normalize(input_matrix(:,1:2));    
    idx = dbscan(N,epsilion,minpts);
    N = [N input_matrix(:,3)];
    

    %% Outlier removal using DBSCAN

    j = 1;
    for i = 1:length(idx)
        if (idx(i) ~= -1)
            X(j,:) = input_matrix(i,:);
            X_N(j,:) = N(i,:);          
            idx_c(j,:) = idx(i);
            j = j + 1;
        end
    end
    
    %% Calculate the number of clusters
    cluster_number = length(unique(idx))-1;

    %% Subcontracting of different clusters

    for k = 1:cluster_number
        j = 1;
        for i = 1:length(idx_c)
            if (idx_c(i) == k)
                idx_loc{k}(j,1) = i;
                j = j + 1;
            end
        end
    end

    for i = 1:cluster_number
        X_cluster_O{i} = X(idx_loc{i},:);
        X_cluster_N{i} = X_N(idx_loc{i},:);
    end
%%  
%     if (normalization == 0)
        X_cluster = X_cluster_O;
%     else
        X_cluster = X_cluster_N;
%     end
    
    %% Calculate SSE to determine which cluster is more dense  
%     %% 计算质心
%     for i = 1:cluster_number
%         mean_original(:,i) = mean(X_cluster_O{i});
%     end
%     
%     for i = 1:cluster_number
%         mean_normalized(:,i) = mean(X_cluster_N{i});
%     end
    
    %% Calculate the centroid (weighted)
    % Calculate the weights
    if (normalization == 0)       
        for j = 1:cluster_number
            amplitude_sigma_original(j) = sum(X_cluster_O{j}(:,3));
            for i = 1:size(X_cluster_O{j},1)
                X_cluster_O{j}(i,4) = X_cluster_O{j}(i,3)/amplitude_sigma_original(j);
            end
            mean_original_weighted(1,j) = sum(X_cluster_O{j}(:,1) .* X_cluster_O{j}(:,4));
            mean_original_weighted(2,j) = sum(X_cluster_O{j}(:,2) .* X_cluster_O{j}(:,4));
            mean_original_weighted(3,j) = sum(X_cluster_O{j}(:,3) .* X_cluster_O{j}(:,4));
        end  
    else       
        for j = 1:cluster_number
            amplitude_sigma_normalized(j) = sum(X_cluster_N{j}(:,3));
            for i = 1:size(X_cluster_N{j},1)
                X_cluster_N{j}(i,4) = X_cluster_N{j}(i,3)/amplitude_sigma_normalized(j);
            end
            mean_normalized_weighted(1,j) = sum(X_cluster_N{j}(:,1) .* X_cluster_N{j}(:,4));
            mean_normalized_weighted(2,j) = sum(X_cluster_N{j}(:,2) .* X_cluster_N{j}(:,4));
            mean_normalized_weighted(3,j) = sum(X_cluster_N{j}(:,3) .* X_cluster_N{j}(:,4));
        end     
    end
  
 %%     
    if (normalization == 0)
        dis = zeros(cluster_number,1);
        for j = 1:cluster_number
            for i = 1:size(X_cluster_O{j},1)
                dis_temp = sqrt((X_cluster_O{j}(i,1) - mean_original_weighted(1,j)).^2 + (X_cluster_O{j}(i,2) - mean_original_weighted(2,j)).^2);
                dis(j) = dis(j) + dis_temp;
            end
            dis(j) = dis(j)/length(X_cluster_O{j});
        end
        estimated_aoa = mean_original_weighted.';
        estimated_aoa(:,4) = dis(:,1);
    %     [~,I] = sort(estimated_aoa(:,4));
    %     estimated_aoa_O = estimated_aoa(I,:);
    else
        %Calculate the SSE  
        dis = zeros(cluster_number,1);
        for j = 1:cluster_number
            for i = 1:size(X_cluster_N{j},1)
                dis_temp = sqrt((X_cluster_N{j}(i,1) - mean_normalized_weighted(1,j)).^2 + (X_cluster_N{j}(i,2) - mean_normalized_weighted(2,j)).^2);
                dis(j) = dis(j) + dis_temp;
            end
            dis(j) = dis(j)/length(X_cluster_N{j});
        end
        estimated_aoa = mean_normalized_weighted.';
        estimated_aoa(:,4) = dis(:,1);
%       [~,I] = sort(estimated_aoa(:,4));
%       estimated_aoa = estimated_aoa(I,:);
    
 %% inverse unity
        s = std(aoa_tof_packet(:,1:2));
        x_bar = mean(aoa_tof_packet(:,1:2));
         
        for j = 1:2
            for i = 1:size(estimated_aoa,1)
                estimated_aoa(i,j) = estimated_aoa(i,j) * s(j) + x_bar(j);
            end
        end
    
    end
%%
    %% Plot
    
    figure(1);
    gscatter(input_matrix(:,2),input_matrix(:,1),idx);
    xlabel('ToF(ns)')
    ylabel('AoA(Degree)')
    xlim([0 100])
    ylim([0 180])
    hold on
    plot(estimated_aoa(:,2),estimated_aoa(:,1),'kx',...
         'MarkerSize',15,'LineWidth',3)   
    hold off
    legend('Removed the points','Cluster 1','Cluster 2','Cluster 3','Cluster 4')
    
    %
    if (normalization == 0)
        figure(2);
        gscatter(X(:,2),X(:,1),idx_c);
        hold on
        plot(mean_original_weighted(2,:),mean_original_weighted(1,:),'kx',...
             'MarkerSize',15,'LineWidth',3)
        hold off
    else
        %
        figure(2);
        gscatter(X_N(:,2),X_N(:,1),idx_c);
        hold on
        plot(mean_normalized_weighted(2,:),mean_normalized_weighted(1,:),'kx',...
             'MarkerSize',15,'LineWidth',3)
% 
        hold off
        
        legend('Cluster 1','Cluster 2','Cluster 3','Cluster 4','Weighted mean value')
        
        xlim([-2 2])
        ylim([-2 2])
        xlabel('Normalized ToF')
        ylabel('Normalized AoA')
    end
end
