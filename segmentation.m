function X_seg = segmentation(aoa_packet_ap1,aoa_packet_ap2,aoa_packet_ap3,seg_number)
    if seg_number == 0
      %% Delete negatives
        for i = 1:38
            if ~isempty(find(aoa_packet_ap1{i,1}(:,2)<0,1))
                aoa_packet_ap1{i,1}(:,2) = aoa_packet_ap1{i,1}(:,2) - min(aoa_packet_ap1{i,1}(:,2)); 
            end
            aoa_packet_ap1{i,1}(:,3) = aoa_packet_ap1{i,1}(:,2) ./ sum(aoa_packet_ap1{i,1}(:,2));

            if ~isempty(find(aoa_packet_ap2{i,1}(:,2)<0,1))
                aoa_packet_ap2{i,1}(:,2) = aoa_packet_ap2{i,1}(:,2) - min(aoa_packet_ap2{i,1}(:,2)); 
            end  
            aoa_packet_ap2{i,1}(:,3) = aoa_packet_ap2{i,1}(:,2) ./ sum(aoa_packet_ap2{i,1}(:,2));

            if ~isempty(find(aoa_packet_ap3{i,1}(:,2)<0,1))
                aoa_packet_ap3{i,1}(:,2) = aoa_packet_ap3{i,1}(:,2) - min(aoa_packet_ap3{i,1}(:,2));  
            end
            aoa_packet_ap3{i,1}(:,3) = aoa_packet_ap3{i,1}(:,2) ./ sum(aoa_packet_ap3{i,1}(:,2));
        end
        %% Contruct the input matrix "X"
        for i = 1:38
            X{i,1} = [aoa_packet_ap1{i,1}(:,1),aoa_packet_ap1{i,1}(:,3)];
            X{i,2} = [aoa_packet_ap2{i,1}(:,1),aoa_packet_ap2{i,1}(:,3)];
            X{i,3} = [aoa_packet_ap3{i,1}(:,1),aoa_packet_ap3{i,1}(:,3)];
        end  

    else
        for i = 1:38
            X{i,1} = [aoa_packet_ap1{i,1}(:,1),aoa_packet_ap1{i,1}(:,2)];
            X{i,2} = [aoa_packet_ap2{i,1}(:,1),aoa_packet_ap2{i,1}(:,2)];
            X{i,3} = [aoa_packet_ap3{i,1}(:,1),aoa_packet_ap3{i,1}(:,2)];
        end
        
        for ii = 1:38
            for jj = 1:3
                seg.length(ii,jj) = size(X{ii,jj},1);
            end   
        end
        seg.repeat_times = seg_number;
        seg.repeat_number = floor(seg.length ./ seg.repeat_times);
        for ii = 1:38
            for jj = 1:3
                if seg.repeat_times < seg.length(ii,jj)
                    seg.index{ii,jj} = [repmat(seg.repeat_number(ii,jj),1,seg.repeat_times - 1),...
                                        seg.length(ii,jj) - (seg.repeat_times - 1).* seg.repeat_number(ii,jj)];
                else
                    seg.index{ii,jj} = ones(1,seg.length(ii,jj));
                end
    %             seg.sum(ii,jj) = sum(seg.index{ii,jj});
            end
        end
        
        for ii = 1:38
            for jj = 1:3
                X_seg_temp1{ii,jj} = mat2cell(X{ii,jj},seg.index{ii,jj});               
            end
        end
        for jj = 1:seg_number
            for ii = 1:38
                X_seg_temp2(ii,:) = [X_seg_temp1{ii,1}(jj);X_seg_temp1{ii,2}(jj);X_seg_temp1{ii,3}(jj)];
                for kk = 1:3
                    X_seg_temp2{ii,kk}(:,2) = X_seg_temp2{ii,kk}(:,2) ./ sum(X_seg_temp2{ii,kk}(:,2));
                end
            end
            X_seg(jj) = {X_seg_temp2};
            clear X_seg_temp2
        end
        clear X_seg_temp1
    end
end
    