function smoothed_csi = SmoothCSI(csi)
    smoothed_csi = zeros(size(csi, 2), size(csi, 2));
    %% Antenna 1
    m = 1;
    for ii = 1:1:15
        n = 1;
        for j = ii:1:(ii + 15)
            smoothed_csi(m, n) = csi(1, j);
            n = n + 1;
        end
        m = m + 1;
    end
    
    %% Antenna 2
    for ii = 1:1:15
        n = 1;
        for j = ii:1:(ii + 15)
            smoothed_csi(m, n) = csi(2, j);
            n = n + 1;
        end
        m = m + 1;
    end
    
    m = 1;
    for ii = 1:1:15
        n = 17;
        for j = ii:1:(ii + 15)
            smoothed_csi(m, n) = csi(2, j);
            n = n + 1;
        end
        m = m + 1;
    end
    
%% Antenna 3
    for ii = 1:1:15
        n = 17;
        for j = ii:1:(ii + 15)
            smoothed_csi(m, n) = csi(3, j);
            n = n + 1;
        end
        m = m + 1;
    end
end