function steering_vector_table = SteeringVectorTableCalculation(search_range, frequency, sub_freq_delta, antenna_distance)
    theta = search_range.theta_num;
    tau = search_range.tau_num .* 10^-9;
%%
    steering_vector_table = cell(length(theta),length(tau));
    for ii = 1:length(theta)
        for jj = 1:length(tau)
            steering_vector_table(ii,jj) = {compute_steering_vector(theta(ii), tau(jj), frequency, sub_freq_delta, antenna_distance)};
        end
    end

    %%   
    function steering_vector = compute_steering_vector(theta, tau, freq, sub_freq_delta, ant_dist)
        steering_vector = zeros(30, 1);
        k = 1;
        base_element = 1;
        for kk = 1:2
            for ll = 1:15
                steering_vector(k, 1) = base_element * omega_tof_phase(tau, sub_freq_delta)^(ll - 1);
                k = k + 1;
            end
            base_element = base_element * phi_aoa_phase(theta, freq, ant_dist);
        end
    end
    %%   
    function time_phase = omega_tof_phase(tau, sub_freq_delta)
        time_phase = exp(-1i * 2 * pi * sub_freq_delta * tau);
    end
    %% 
    function angle_phase = phi_aoa_phase(theta, frequency, d)
        c = 3.0 * 10^8;
        theta = theta / 180 * pi;
        angle_phase = exp(-1i * 2 * pi * d * cos(theta) * (frequency / c));
    end
end