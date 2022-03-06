function [eigenvectors, K] = NoiseSubspaceEigenvectors(x)

    % Data covarivance matrix
    R = x * x';
    % Modified MUSIC
    Iv = fliplr(eye(30));
    Rx = R + Iv * conj(R) * Iv;
    % Find the eigenvalues and eigenvectors of the covariance matrix
    [eigenvectors, eigenvalue_matrix] = eig(Rx);
    
    
%% MDL

    D = sort(diag(eigenvalue_matrix),'descend');
    N = 32;
    P = 30;
    MDL = zeros(P,1);
    for k = 0:P-1
        mdl_tmp_d = D(k+1:P);
        mdl_tmp1 = prod(mdl_tmp_d.^(1/(P-k)));
        mdl_tmp2 = 1/(P-k)*sum(mdl_tmp_d);
        MDL(k+1) = N*(P-k)*log(mdl_tmp2/mdl_tmp1) + 0.5*k*(2*P-k)*log(N);% MDL
    end
  
    [~,K] = min(MDL);
    K = K - 1;

    eigenvectors = eigenvectors(:, 1:(30-K)); 
end