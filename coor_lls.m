function [error_final,coordinate_final] = coor_lls(X,weights,distance,coor_real)

    AP_coor = [12.121, 0;           % AP1
               13.149, 9.1287;      % AP2
               0     , 13.4717];    % AP3
    seg_number = length(X);
    coordinate = cell(1,seg_number);   
    for jj = 1:seg_number
        coordinate{jj} = cell(38,3);
        for ii = 1:38
            % AP1
            coordinate{jj}{ii,1}(:,1) = AP_coor(1,1) + distance(ii,1) .* cosd(X{jj}{ii,1}(:,1));
            coordinate{jj}{ii,1}(:,2) = AP_coor(1,2) + distance(ii,1) .* sind(X{jj}{ii,1}(:,1));
            % AP2
            coordinate{jj}{ii,2}(:,1) = AP_coor(2,1) - distance(ii,2) .* sind(X{jj}{ii,2}(:,1));
            coordinate{jj}{ii,2}(:,2) = AP_coor(2,2) + distance(ii,2) .* cosd(X{jj}{ii,2}(:,1));
            % AP3
            coordinate{jj}{ii,3}(:,1) = AP_coor(3,1) - distance(ii,3) .* cosd(X{jj}{ii,3}(:,1));
            coordinate{jj}{ii,3}(:,2) = AP_coor(3,2) - distance(ii,3) .* sind(X{jj}{ii,3}(:,1));
        end
    end

    %% 1/ Calculate the final coordinate(With the weights of different APs)
%     weights = [.8,.1,.1];
    coordinate_final = cell(1,seg_number);
    error_final = cell(1,seg_number);
    for jj = 1:seg_number
        coordinate_final{jj} = zeros(38,2);
        error_final{jj} = zeros(38,1);  
        for ii = 1:38
            coordinate_final{jj}(ii,1) = sum([coordinate{jj}{ii,1}(:,1);coordinate{jj}{ii,2}(:,1);coordinate{jj}{ii,3}(:,1)] .* ...
                                       [(X{jj}{ii,1}(:,2)) .* weights(ii,1);(X{jj}{ii,2}(:,2)) .* weights(ii,2);(X{jj}{ii,3}(:,2)) .* weights(ii,3)]);
            coordinate_final{jj}(ii,2) = sum([coordinate{jj}{ii,1}(:,2);coordinate{jj}{ii,2}(:,2);coordinate{jj}{ii,3}(:,2)] .* ...
                                       [(X{jj}{ii,1}(:,2)) .* weights(ii,1);(X{jj}{ii,2}(:,2)) .* weights(ii,2);(X{jj}{ii,3}(:,2)) .* weights(ii,3)]);

    %         coordinate_final(ii,1) = sum([coordinate{ii,1}(:,1);coordinate{ii,2}(:,1);coordinate{ii,3}(:,1)] .* ...
    %                                    [repmat(1/length(X{ii,1}),length(X{ii,1}),1) .* weights(1);repmat(1/length(X{ii,2}),length(X{ii,2}),1) .* weights(2);repmat(1/length(X{ii,3}),length(X{ii,3}),1) .* weights(3)]);
    %         coordinate_final(ii,2) = sum([coordinate{ii,1}(:,2);coordinate{ii,2}(:,2);coordinate{ii,3}(:,2)] .* ...
    %                                    [repmat(1/length(X{ii,1}),length(X{ii,1}),1) .* weights(1);repmat(1/length(X{ii,2}),length(X{ii,2}),1) .* weights(2);repmat(1/length(X{ii,3}),length(X{ii,3}),1) .* weights(3)]);

            error_final{jj}(ii,1) = sqrt((coordinate_final{jj}(ii,1)-coor_real(ii,1)).^2 + (coordinate_final{jj}(ii,2)-coor_real(ii,2)).^2);
        end
    end
end
