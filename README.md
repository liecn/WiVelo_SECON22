# WiVelo

This repository contains scripts and instructions for reproducing the experiments in our SECON'22 paper "
WiVelo: Fine-grained Walking Velocity Estimation for Wi-Fi Passive Tracking". 
<!-- [PyramidFL: Fine-grained Data and System Heterogeneity-aware Client Selection for Efficient Federated Learning](https://www.usenix.org/conference/osdi21/presentation/lai)".  -->

# Overview

* [Demo Dataset](#dataset)
* [Repo Structure](#repo-structure)
* [Instructions](#instructions)
* [Acknowledgements](#acknowledgements)
* [Contact](#contact)

# dataset

#### Download datasets. We provide 144 CSI traces with 2 WiFI receivers from 3 users, 6 tracks, and 4 instances from https://drive.google.com/drive/folders/1XNAKy_SXm-bF929IUvcokgSlsOiuLd2E?usp=sharing

# Repo Structure
<pre>/WiVelo
 ┬  
 ├ [DIR] wivelo_dataset  
 ┬    
     ├ [DIR] CSI  
     ├ [DIR] GROUNDTRUTH  
     └ [DIR] FEATURE  
 ├ [DIR] code
</pre>

# Instructions                                                                              |
``` matlab
% remember to add the utility functions in ./util/ 
cd code    
matlab generate_ground_truth        % generate ground truth files
matlab main        % generate features and results, function generate_demo_real_trail() in line 110 will generate the real traces, its ground truth, locations of WiFi transmitter and receiver.
```

# Notes
please cite our paper if you think the source codes are useful in your research project.
```bibtex
@inproceedings{wivelo_secon22,
    author = {Li, Chenning and Liu, Li and Cao, Zhichao and Zhang, Mi},
    title = {WiVelo: Fine-grained Walking Velocity Estimation for Wi-Fi Passive Tracking},
    year = {2022},
    booktitle = {Proceedings of IEEE SECON},
}
```

# Contact
Zhichao Cao by caozc@msu.edu