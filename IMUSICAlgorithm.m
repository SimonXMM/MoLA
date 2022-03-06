%% Run modified MUSIC algorithm
function [estimated_points, K] = IMUSICAlgorithm(x, steering_vector_table, search_range, antenna_distance, frequency, sub_freq_delta, ifplot)
    %% Calculate the noise subspace eigenvector with modified MUSIC and MDL
    [eigenvectors, K] = NoiseSubspaceEigenvectors(x);
    Pmusic_num = IMusicSpectrum(search_range,steering_vector_table,eigenvectors);
    
   %% Plot the music spectrum using numerical matrix
    if (ifplot == 1)
        [x,y] = meshgrid(search_range.theta_num, search_range.tau_num);
        
        figure(1);
        mesh(x,y,Pmusic_num);
        xlabel('AoA(Degree)');
        ylabel('ToF(ns)');
        zlabel('I-MUSIC Spectrum (dB)')
        xlim([search_range.theta_lb search_range.theta_ub]);
        ylim([search_range.tau_lb search_range.tau_ub]);
%         zlim([-15 10]);
        colorbar;
        
        figure(2);
        mesh(x,y,Pmusic_num);
        view(2);
        xlabel('AoA(Degree)');
        ylabel('ToF(ns)');
        xlim([search_range.theta_lb search_range.theta_ub]);
        ylim([search_range.tau_lb search_range.tau_ub]);
        colorbar;   
    end
   
    %% Using global optimization to find peaks
    
    % Passing theta and tau to the music spectrum handle function
    Pmusic = @(x) -music_spectrum_sym(x(1), x(2), frequency, sub_freq_delta, antenna_distance, eigenvectors);
    
    % Setting the initial point/lower band/upper band
    x0 = [length(search_range.theta_num)/2,length(search_range.tau_num)/2];
    lb = [search_range.theta_lb; search_range.tau_lb];
    ub = [search_range.theta_ub; search_range.tau_ub]; 
    
    % Options of optimization problem
    opts = optimoptions(...
        'fmincon',...
        'Algorithm','sqp');
    
    problem = createOptimProblem(...
        'fmincon',...
        'objective',Pmusic,...
        'x0',x0,'lb',lb,'ub',ub,...
        'options',opts);

    % Trying multistart approach to find all peaks
    ms = MultiStart('Display','off',...
        'UseParallel',true,...
        'FunctionTolerance',1e-2,...
        'XTolerance',1e-2);

    [~,~,~,~,solsms] = run(ms,problem,40);
    xMS = cell2mat({solsms(:).X}');
    
    % Delete the points that reach the lb/ub
    con = (xMS(:,1)>search_range.theta_lb & xMS(:,1)<search_range.theta_ub & xMS(:,2)>search_range.tau_lb & xMS(:,2)<search_range.tau_ub);
    xMS = xMS(con,:);
    
    % Points at (-1,-1) if there is no output
    if (isempty(xMS))
        xMS = [-1,-1];
    end
    
    % Calculate the weights
    for i = 1:size(xMS,1)
        weight(i) = -Pmusic(xMS(i,:));
    end
    xMS = [xMS,weight'];
    
    %% Delete the points smaller than the mean value of amplitude
    
    amp_mean = mean(Pmusic_num,'all');
    I = xMS(:,3)>(1.5*amp_mean);
    estimated_points = xMS(I,:);
    
    %% Plot the contour figure
    if (ifplot == 1)
        
        figure(3);
        contour(search_range.theta_num, search_range.tau_num, Pmusic_num);
        hold on
        scatter(estimated_points(:,1),estimated_points(:,2),'*')
        hold off
        xlabel('AoA(Degree)')
        ylabel('ToF(ns)')
    end
    
end