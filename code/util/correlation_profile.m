function [correlation_val,phase_shift_val,time_sequence] = correlation_profile(csi_data, time_sequence,n_receivers,n_antennas,n_subcarriers,subcarrier_step,sample_step,half_n_virtual_antennas, half_time_delay_window,virtual_antenna_step,time_delay_window_step,time_delay_offset,half_time_window)
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
correlation_val=cell(n_receivers,1);
phase_shift_val=cell(n_receivers,1);

sample_tail_remaining=half_time_window+half_n_virtual_antennas+half_time_delay_window+1;
sample_header_remaining=half_time_window+half_n_virtual_antennas+1;
n_virtual_antennas=half_n_virtual_antennas*2/virtual_antenna_step+1;
n_time_delay=((half_time_delay_window-time_delay_window_step*time_delay_offset)/time_delay_window_step)+1;
n_subcarriers_selected=n_subcarriers-subcarrier_step;

for receiver_index=1:n_receivers
    csi_data_each_receiver=(csi_data{receiver_index});
    n_samples=size(csi_data_each_receiver,1);
    
    time_sequence_each_receiver=time_sequence{receiver_index};
    sampling_points_sequence=sample_header_remaining:sample_step:n_samples-sample_tail_remaining;
    
    n_sampling_points=size(sampling_points_sequence,2);
    timetable_each_receiver=zeros(n_virtual_antennas,n_time_delay,n_sampling_points);
    
    phase_shift_each_receiver=zeros(n_antennas,n_antennas,n_subcarriers_selected,n_time_delay,n_virtual_antennas,n_sampling_points);
    correlation_val_each_receiver=zeros(n_antennas,n_antennas,n_time_delay,n_virtual_antennas,n_sampling_points);
    
    for sampling_point_time_index = sampling_points_sequence
        sampling_point_index=(sampling_point_time_index-sample_header_remaining)/sample_step+1;
        virtual_antenna_sequence=sampling_point_time_index-half_n_virtual_antennas:virtual_antenna_step: sampling_point_time_index+half_n_virtual_antennas;
        for virtual_antenna_time_index = virtual_antenna_sequence
            virtual_antenna_index=(virtual_antenna_time_index-(sampling_point_time_index-half_n_virtual_antennas))/virtual_antenna_step+1;
            %% virtual massive antennas for time window estimation
            virtural_antenna_sequence_std=virtual_antenna_time_index-half_time_window:virtual_antenna_time_index+half_time_window;
            csi_data_each_receiver_sequence_std=csi_data_each_receiver(virtural_antenna_sequence_std,:);
            csi_data_each_receiver_sequence_std=csi_data_each_receiver_sequence_std-mean(csi_data_each_receiver_sequence_std);
            %% antennas as std sentinels
            time_delay_sequence=virtual_antenna_time_index+time_delay_window_step*time_delay_offset:time_delay_window_step:virtual_antenna_time_index+half_time_delay_window;
            timetable_each_receiver(virtual_antenna_index,:,sampling_point_index)=time_sequence_each_receiver(time_delay_sequence);
            for antenna_std_index = 1:n_antennas
                vector_subcarrier_list_std=csi_data_each_receiver_sequence_std(:,(antenna_std_index-1)*n_subcarriers+1:antenna_std_index*n_subcarriers);
                phase_shift_each_receiver_subcarrier_std=zeros(n_subcarriers_selected,1);
                for subcarrier_index=1:n_subcarriers_selected
                    vector_std_1=vector_subcarrier_list_std(:,subcarrier_index);
                    vector_std_2=vector_subcarrier_list_std(:,subcarrier_index+subcarrier_step);
                    [~,corr_index]=max(xcorr(vector_std_1,vector_std_2));
                    phase_shift_each_receiver_subcarrier_std(subcarrier_index) = (corr_index-size(vector_subcarrier_list_std,1));
                end
                %% dynamic observation time interval
                for time_delay_time_index=time_delay_sequence
                    time_delay_index=(time_delay_time_index-(virtual_antenna_time_index+time_delay_window_step*time_delay_offset))/time_delay_window_step+1;
                    virtural_antenna_sequence_delayed=time_delay_time_index-half_time_window:time_delay_time_index+half_time_window;
                    csi_data_each_receiver_sequence_delayed=csi_data_each_receiver(virtural_antenna_sequence_delayed,:);
                    csi_data_each_receiver_sequence_delayed=csi_data_each_receiver_sequence_delayed-mean(csi_data_each_receiver_sequence_delayed);
                    %% antennas as delayed sentinels
                    for antenna_delayed_index=1:n_antennas
                        vector_subcarrier_list_delayed=csi_data_each_receiver_sequence_delayed(:,(antenna_delayed_index-1)*n_subcarriers+1:antenna_delayed_index*n_subcarriers);
                        phase_shift_each_receiver_subcarrier_delayed=zeros(n_subcarriers_selected,1);
                        for subcarrier_index=1:n_subcarriers_selected
                            vector_delayed_1=vector_subcarrier_list_delayed(:,subcarrier_index);
                            vector_delayed_2=vector_subcarrier_list_delayed(:,subcarrier_index+subcarrier_step);
                            [~,corr_index]=max(xcorr(vector_delayed_1,vector_delayed_2));
                            phase_shift_each_receiver_subcarrier_delayed(subcarrier_index) =(corr_index-size(vector_subcarrier_list_delayed,1));
                        end
                        %% calculate the Cosine Correlation
                        corr=dot(sign(phase_shift_each_receiver_subcarrier_std),sign(phase_shift_each_receiver_subcarrier_delayed));
                        if(sampling_point_index==1)
                            correlation_val_each_receiver(antenna_std_index,antenna_delayed_index,time_delay_index,virtual_antenna_index,sampling_point_index) =corr;
                        else
                            correlation_val_each_receiver(antenna_std_index,antenna_delayed_index,time_delay_index,virtual_antenna_index,sampling_point_index) =corr;
                        end
                        phase_shift_each_receiver(antenna_std_index,antenna_delayed_index,:,time_delay_index,virtual_antenna_index,sampling_point_index)=phase_shift_each_receiver_subcarrier_delayed;
                    end
                end
            end
        end
    end
    %         correlation_val_each_receiver_mean=squeeze(mean(correlation_val_each_receiver,4));
    %         for ii=1:n_antennas
    %           for jj=1:n_time_delay
    %                 figure(jj);
    %                 plot(squeeze(correlation_val_each_receiver_mean(ii,:,jj,1:min(60,size(correlation_val_each_receiver_mean,4))))');
    %     %             plot(sgolayfilt(squeeze(correlation_val_each_receiver_mean(ii,:,jj,1:min(60,size(correlation_val_each_receiver_mean,4))))',3,5));
    %                 title('Cosine Similarity for different antenna pair')
    %                 legend([num2str(ii),'-1'],[num2str(ii),'-2'],[num2str(ii),'-3'])
    %           end
    %         end
    correlation_val_each_receiver_mean=squeeze(mean(correlation_val_each_receiver,[3,4]));
    %         for ii=1:n_antennas
    %
    %             figure(ii);
    %             plot(squeeze(correlation_val_each_receiver_mean(ii,:,1:min(60,size(correlation_val_each_receiver_mean,3))))');
    %     %         plot(sgolayfilt(squeeze(correlation_val_each_receiver_mean(ii,:,1:min(60,size(correlation_val_each_receiver_mean,3))))',3,5));
    %             title('Cosine Similarity for different antenna pair')
    %             legend([num2str(ii),'-1'],[num2str(ii),'-2'],[num2str(ii),'-3'])
    %
    %         end
    correlation_val{receiver_index}=correlation_val_each_receiver_mean;
    phase_shift_val{receiver_index}=reshape(phase_shift_each_receiver,n_antennas,n_antennas,n_subcarriers_selected,[],n_sampling_points);
    time_sequence{receiver_index}=reshape(timetable_each_receiver,[],n_sampling_points);
end