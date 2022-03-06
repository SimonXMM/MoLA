function Pmusic = IMusicSpectrum(search_range,steering_vector_table,eigenvectors)    
    theta = search_range.theta_num;
    tau = search_range.tau_num;
    Pmusic = zeros(length(theta), length(tau));
    
    for ii = 1:length(theta) 
        for jj = 1:length(tau)                           
            PP = steering_vector_table{ii,jj}' * (eigenvectors * eigenvectors') * steering_vector_table{ii,jj};
            Pmusic(ii, jj) = abs(1 /  PP);
            Pmusic(ii, jj) = db(Pmusic(ii, jj),'power');
        end
    end
    Pmusic = Pmusic';
end