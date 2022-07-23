function [node_sequence,observing_phase_shift] = voting_hopping_sequence(correlation_val,phase_shift_val,n_receivers,det_threshold)
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
node_sequence=cell(n_receivers,1);
observing_phase_shift=cell(n_receivers,1);
for receiver_index=1:n_receivers
    correlation_val_per_receiver=correlation_val{receiver_index};
    phase_shift_per_receiver=phase_shift_val{receiver_index};
    [~,~,n_subcarriers_selected,n_observing_time_interval,n_sample]=size(phase_shift_per_receiver);
    corr_det_matrix=zeros(n_sample,1);
    node_sequence_per_receiver=ones(n_sample,1)*2;
    observing_phase_shift_per_receiver=zeros(n_observing_time_interval,n_sample);
    
    for jj=1:n_sample
        corr_det_per_sample=squeeze(correlation_val_per_receiver(:,:,jj));   
        corr_det_matrix(jj)=(det(corr_det_per_sample));
    end
    %     figure(receiver_index);
    corr_det_matrix=corr_det_matrix./max(sgolayfilt(corr_det_matrix,3,7));
    %     plot(corr_det_matrix);
    for sample_index=1:n_sample
        if corr_det_matrix(sample_index)>det_threshold
            dir_val=sign(phase_shift_per_receiver(:,:,:,:,sample_index));
            node_sequence_per_receiver(sample_index)=(numel(find(dir_val==1))>numel(find(dir_val==-1)))*2+1;
        end
    end
    
    for sample_index=2:n_sample
        node_tag=node_sequence_per_receiver(sample_index);
        vector_diff=squeeze(phase_shift_per_receiver(2,4-node_tag,:,:,sample_index)-phase_shift_per_receiver(2,2,:,:,sample_index-1))';
        observing_phase_shift_per_receiver(:,sample_index)=cal_distance( vector_diff, zeros(1,n_subcarriers_selected), 'emd' );
    end
    node_sequence{receiver_index}=node_sequence_per_receiver;
    observing_phase_shift{receiver_index}=observing_phase_shift_per_receiver;
end
end