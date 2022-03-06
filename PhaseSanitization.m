function [k, b, Phase_Corrected] = PhaseSanitization(csi_matrix,Carrier_index)
   
    phi = angle(csi_matrix);
    amp = abs(csi_matrix);

    fit_X_1order = [repmat(Carrier_index(:),3,1) ones(30*3,1)];
    fit_Y_1order = [phi(:,1);phi(:,2);phi(:,3)];
    coeff_1order = fit_X_1order\fit_Y_1order;
    k_1order = coeff_1order(1);
    b_1order = coeff_1order(2);
    y_1order = (Carrier_index .* k_1order + b_1order)';
    
    phi_corrected_1order = phi - repmat(y_1order,1,3);
    
    unwrap_phase = unwrap(phi_corrected_1order,[],1);
    
    fit_X = [repmat(Carrier_index(:),3,1) ones(30*3,1)];
    fit_Y = [unwrap_phase(:,1);unwrap_phase(:,2);unwrap_phase(:,3)];   
    coeff = fit_X\fit_Y;
    k = coeff(1);
    b = coeff(2);
    y = (Carrier_index .* k + b)';
    
    phi_corrected = unwrap_phase - repmat(y,1,3);
    Phase_Corrected = amp .* exp(1i .* phi_corrected);

end