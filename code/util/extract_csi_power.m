function [csi_data] = extract_csi_power(data_file, n_receivers, n_antennas,n_subcarriers)
csi_data= cell(n_receivers,1);
for receiver_index = 1:n_receivers
    spth = [data_file, '-r', num2str(receiver_index), '.dat'];
    try
        tic;
        [csi_data_one, timestamp] = generate_csi_from_dat(spth,n_antennas,n_subcarriers);
        disp(['Loaded csi for',spth])
    catch err
        disp(['ERROR in loading csi',err.message])
        continue
    end
    csi_data_one=abs(csi_data_one).^2;
    csi_data{receiver_index}=csi_data_one;
end
end