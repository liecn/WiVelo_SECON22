function time_sequence = anchor_selection(observing_phase_shift, time_matrix,search_range,reward_weight)
% path_matched = graph_mapping(ftp, plcr_list, path_sample_rate, sample_rate)
% extracts path from spectrogram
%
% FTP         : The spectrogram.
% ftp_list   : tha path value candidates.
% path_sample_rate   : Sampling rate of PLCR series.
% SAMPLE_RATE : Sampling rate of spectrogram.
%
% path_matched        : Path matched.
a=observing_phase_shift{1};
b=observing_phase_shift{2};
sampling=min(size(a,2),size(b,2));
observing_phase_shift_mean=(a(:,1:sampling)+b(:,1:sampling))/2;
time_sequence=dynamic_observation_path(observing_phase_shift_mean, time_matrix{1},search_range,reward_weight);
end