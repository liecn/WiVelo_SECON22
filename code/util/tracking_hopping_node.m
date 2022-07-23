function trail_sequence = tracking_hopping_node(node_selection)
% CORR_VAL=STATIC_CORRELATION(CSI_DATA, N_DEVICES, N_ANTENNAS,
% N_SUBCARRIERS, SAMPLE_RATE, MAX_FREQ, MIN_FREQ, START_TIME, DURATION)
% calculates the correlation of CSI subcarriers in static scenarios.
%
% CSI_DATA      : Raw CSI measurements, eg:dim($(time_series),n_antennas*n_subcarriers)
% N_ANTENNAS    : Number of antennas per devices
% N_SUBCARRIERS : Number of subcarriers in CSI
% SAMPLE_RATE   : Target sampling rate of interpolation
% START_TIME    : Start time for calculating correlation of CSI.
% DURATION      : Duration of data used for correlation.
%
% CORR_VAL      : Average correlation value per subcarrier, antenna
%

% Calculate correlation coefficient.
n_sample=min(size(node_selection{2},1),size(node_selection{1},1));
trail_sequence=zeros(n_sample,2);
a_list=node_selection{1}-2;
b_list=node_selection{2}-2;
for node_index=1:n_sample
    a=a_list(node_index);
    b=b_list(node_index);
    if(a==1&&b==1)
        trail_sequence(node_index,1:2)=trail_sequence(max(node_index-1,1),1:2)+[0,1];
    elseif (a==-1&&b==-1)
        trail_sequence(node_index,1:2)=trail_sequence(max(node_index-1,1),1:2)+[0,-1];
    elseif (a==1||a==-1)
        trail_sequence(node_index,1:2)=trail_sequence(max(node_index-1,1),1:2)+[a+0.3*b,-0.1*b];
    elseif (b==1||b==-1)
        trail_sequence(node_index,1:2)=trail_sequence(max(node_index-1,1),1:2)+[-b-0.3*a,0.1*a];
    else
       trail_sequence(node_index,1:2)=trail_sequence(max(node_index-1,1),1:2);
    end
end
end
