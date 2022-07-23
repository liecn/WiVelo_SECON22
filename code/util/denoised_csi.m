function [csi_data,time_sequence] = denoised_csi(csi_subcarriers_selected, n_receivers,virtual_antenna_step, sample_rate)
% Doppler Spectrum For Each Antenna
csi_data= cell(n_receivers,1);
time_sequence=cell(n_receivers,1);
for receiver_index = 1:n_receivers
    csi_data_one=csi_subcarriers_selected{receiver_index};
    %% Denoise
    samples_sequence=1:size(csi_data_one,1);
    time_sequence{receiver_index}=samples_sequence/sample_rate;
    
    csi_data_one=sgolayfilt(csi_data_one,5,virtual_antenna_step+1);
    csi_data{receiver_index}=csi_data_one;
end
end