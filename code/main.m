clear;
clc;
close all;
%% Set Parameters for Transceivers
wave_length = 299792458 / 5.825e9;
sample_rate=1000;
n_receivers = 2;     % Receiver count
n_antennas = 3;    % Antenna count for each receiver
n_subcarriers=30;

%% Set Parameters for Data Description
total_user=12;
total_track = 6;
total_instance = 4;

%% Set Parameters for Signal Processing
half_n_virtual_antennas=48;

virtual_antenna_step=32;
half_time_delay_window=40;
time_delay_window_step=5;
half_time_window=48;
subcarrier_step=4;
sample_step=128;
time_delay_offset=5;
time_delay_header=half_n_virtual_antennas+(time_delay_offset-1)*time_delay_window_step+1;
%% Set Parameters for Anchor Selection
search_range=5;
reward_weight=0.5;
compensation_factor=2.5;
ellipse_weight=0.5;

%% fine-tune parameter
det_threshold=0.1;
translation_scaling=2;

%% Antenna Setting
antenna_spacing=0.2;
antenna_mid_left=-2.4;
antenna_mid_right=2.4;
antenna_coords1 = [antenna_mid_left+antenna_spacing,0;antenna_mid_left,0;antenna_mid_left-antenna_spacing,0];
antenna_coords2 = [antenna_mid_right-antenna_spacing,0;antenna_mid_right,0;antenna_mid_right+antenna_spacing,0];
T = [0,0];

%% Set Parameters for Loading Data
data_root = 'D:\papers\WiVelo\dataset/';
csi_dir = [data_root,'CSI/'];

%% Set Path for Loading Groundtruth
groundtruth_dir = [data_root,'GROUNDTRUTH/'];
if ~exist(groundtruth_dir)
    mkdir(groundtruth_dir);
end
%% Set Path for Loading Feature
feature_dir = [data_root,'FEATURE/'];
if ~exist(feature_dir)
    mkdir(feature_dir);
end

%% Signal Processing and Feature Extraction
for user_index=[1,8,12]
    for track_index = 1:total_track
        for instance_index = 1:total_instance
            data_file_name = [num2str(user_index), '-1-', num2str(track_index),'-', num2str(instance_index)];
            %% load ground truth
            groundtruth_path = [num2str(track_index),...
                '-', num2str(instance_index)];
            disp(["Loading ",groundtruth_path])
            load([groundtruth_dir,groundtruth_path, '.mat']);
            
            feature_path = [feature_dir, data_file_name, '.mat'];
            
            disp(["Loading ",feature_path])
            if ~exist(feature_path)
                %% Signal pre-processing
                tic;
                csi_data= extract_csi_power([csi_dir, data_file_name],n_receivers, n_antennas, n_subcarriers);
                [csi_data,time_sampling]= denoised_csi(csi_data,n_receivers, half_time_window,sample_rate);
                %% voting for anchor sequence
                [correlation_val,distribution_val,time_matrix] = correlation_profile(csi_data, time_sampling,n_receivers,n_antennas,n_subcarriers,subcarrier_step,sample_step,half_n_virtual_antennas, half_time_delay_window,virtual_antenna_step,time_delay_window_step,time_delay_offset,half_time_window);
                [node_sequence,observing_phase_shift]= voting_hopping_sequence(correlation_val,distribution_val,n_receivers,det_threshold);
                %% tracking virtual sequence
                real_trail = tracking_hopping_node(node_sequence);
                real_trail=real_trail./max(abs(real_trail(:)))*compensation_factor+ground_truth(1,:);
                save(feature_path, 'real_trail', 'observing_phase_shift','time_matrix');
            else
                load(feature_path);
            end
            
            feature_path = [feature_dir, data_file_name, '_trace','.mat'];
            
            disp(["Loading ",feature_path])
            if ~exist(feature_path)
                n_sampling_for_trail=size(real_trail,1);
                disp(data_file_name)
                %% Translation
                anchor_time_pick_sequence= anchor_selection(observing_phase_shift,time_matrix,search_range,reward_weight);
                all_scaler=(anchor_time_pick_sequence*sample_rate-(time_delay_header+sample_step*(0:n_sampling_for_trail-1)'))/sample_step;
                dir_sequence=(real_trail(2:n_sampling_for_trail,1:2)-real_trail(1:n_sampling_for_trail-1,1:2));
                physical_dis=zeros(n_sampling_for_trail-1,1);
                for hop_index = 2:n_sampling_for_trail
                    %% nomodel setting
                    [~,physical_dis(hop_index)] = go_to_next(antenna_coords1, antenna_coords2, T, real_trail(hop_index-1,:), dir_sequence(hop_index-1,1), dir_sequence(hop_index-1,2));
                    real_trail(hop_index,:)=real_trail(hop_index-1,:)+dir_sequence(hop_index-1,:)*(ellipse_weight*physical_dis(hop_index)./all_scaler(hop_index)+(1-ellipse_weight)*translation_scaling);
                end
                save(feature_path, 'real_trail','anchor_time_pick_sequence');
            else
                load(feature_path);
            end
            generate_demo_real_trail((track_index-1)*total_instance+instance_index,real_trail,ground_truth);
        end
    end
end

disp(['All finished'])