function anchor_matched = dynamic_observation_path(time_delay_matrix, time_delay_sequence,half_search_range,reward_weight)
% path_matched = graph_mapping(ftp, plcr_list, path_sample_rate, sample_rate)
% extracts path from spectrogram
%
% FTP         : The spectrogram.
% ftp_list   : tha path value candidates.
% path_sample_rate   : Sampling rate of PLCR series.
% SAMPLE_RATE : Sampling rate of spectrogram.
%
% path_matched        : Path matched.
[n_observing_interval,n_sampling_points]=size(time_delay_matrix);
pow_acc = zeros(n_observing_interval,n_sampling_points);
last_freq = zeros(n_observing_interval,n_sampling_points);
anchor_matched=zeros(n_sampling_points,1);
time_delay_matrix=time_delay_matrix./(max(time_delay_matrix)+1);
for ii = 1:n_sampling_points
    if ii == 1
        pow_acc(:,ii) = time_delay_matrix(:,ii);
        last_freq(:,ii) = 0;
    else
        for jj = 1:n_observing_interval
            search_range_low_bound=max(1,jj-half_search_range);
            search_range_high_bound=min(n_observing_interval,jj+half_search_range);
            search_range_list=(search_range_low_bound:search_range_high_bound)';
            [last_pow, idx] = min(pow_acc(search_range_list,ii-1)+reward_weight*abs(search_range_list-jj)/n_observing_interval);
            last_freq(jj,ii) = search_range_low_bound+idx-1;
            pow_acc(jj,ii) = last_pow + time_delay_matrix(jj,ii);
            
        end
    end
end
f = zeros(1, n_sampling_points);
[~, f(end)] = min(pow_acc(:,end));
ii = size(pow_acc,2);

while ii > 1
    anchor_matched (ii)= time_delay_sequence(f(ii),ii);
    f(ii-1) = last_freq(f(ii),ii);
    ii = ii - 1;
end
anchor_matched (ii)= time_delay_sequence(f(ii),ii);
end