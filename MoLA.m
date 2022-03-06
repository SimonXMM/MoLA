%% MoLA
function [aoa_tof_weight,aoa_tof_weight_packet,K] = MoLA(csi_trace, basic_parameters, search_range, ifparallel)

    frequency = basic_parameters.Freq;
    sub_freq_delta = basic_parameters.Sub_freq_delta;
    antenna_distance = basic_parameters.Antenna_distance;
    carrier_index = basic_parameters.Carrier_index_HT40;
    
    % theta in degree
    search_range.theta_num = search_range.theta_lb:search_range.theta_resolution:search_range.theta_ub;
    % tau in nanosecond
    search_range.tau_num = search_range.tau_lb:search_range.tau_resolution:search_range.tau_ub;
    
    %% Calculate the rainbow table
    steering_vector_table = SteeringVectorTableCalculation(search_range, frequency, sub_freq_delta, antenna_distance);
    %%     
    if (ifparallel ~= 1)
        for packet_index = 1:length(csi_trace)
          csi = csi_trace{packet_index};
            % Sanitize the phase
            [~,~,sanitized_csi] = PhaseSanitization(csi,carrier_index);
            % Smooth the matrix
            smoothed_sanitized_csi = SmoothCSI(sanitized_csi.');
            % Estimate the peaks
            [aoa_tof_weight_packet{packet_index}, K(packet_index)] = IMUSICAlgorithm(smoothed_sanitized_csi, steering_vector_table,search_range,...
                antenna_distance, frequency, sub_freq_delta, 1);
            fprintf('%d\n',packet_index);
        end
        
    elseif (ifparallel == 1)
        parfor (packet_index = 1:length(csi_trace),4)
            csi = csi_trace{packet_index};
            % Sanitize the phase
            [~,~,sanitized_csi] = PhaseSanitization(csi,carrier_index);
            % Smooth the matrix
            smoothed_sanitized_csi = SmoothCSI(sanitized_csi.');
            % Estimate the peaks
            [aoa_tof_weight_packet{packet_index}, K(packet_index)] = IMUSICAlgorithm(smoothed_sanitized_csi, steering_vector_table,search_range,...
                antenna_distance, frequency, sub_freq_delta, 0);
            fprintf('%d\n',packet_index);
        end
    end
    %%
    aoa_tof_weight =[];
    for i = 1:length(aoa_tof_weight_packet)
        temp = aoa_tof_weight_packet{i};
        aoa_tof_weight = [aoa_tof_weight;temp];
    end
    K = K.';
end