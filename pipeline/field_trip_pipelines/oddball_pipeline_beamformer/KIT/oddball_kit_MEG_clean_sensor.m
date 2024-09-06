clear all
close all
clc
%% This script processed KIT ERF odd-ball MEG data (3 conditions, Low Frequency LF 200Hz (~60 trials), ...
% High Frequency HF 500Hz( 10 trials), and White Noise WN (10 trials)
% from the KIT MEG at NYUAD.
% IT's tested on subject AS 

% addpath '/Users/osamaabdullah/Dropbox/matlab_codes_osama/fieldtrip-20240110'

kit_filename = 'sub-03-raw-kit.con'



%% concat the 2 .con files (containing Eyes Closed EC, and Eyes Open EO)
ft_defaults
% dat = ft_read_data(kit_filename);% read header from first file
% event = ft_read_event(kit_filename);% read header from first file

%% define trials for KIT .con file
cfg = [];
cfg.dataset  = kit_filename;
cfg.trialdef.eventvalue = 1;
cfg.trialdef.prestim    = 1;
cfg.trialdef.poststim   = 1;
cfg.trialfun = 'ft_trialfun_general';
cfg.trialdef.eventvalue     = [4 2 1]; % the values of the stimulus trigger for the three conditions LF ch225=4, WN ch226=2, HF ch227=1 
cfg.trialdef.chanindx = 225:227; % this will make the binary value either 100 LF(ch225) or WN 010(ch226) or HF 001(ch227)
cfg.trialdef.threshold = 0.5; % this is a meaningful value if the pulses have an amplitude of ~5 V
cfg.trialdef.eventtype = 'combined_binary_trigger'; % this will be the type of the event if combinebinary = true
cfg.trialdef.combinebinary = 1;
% cfg.trialdef.trigshift = 2; % return the value of the combined pulse 2 samples after the on-ramp (in case of small staircases)
cfg = ft_definetrial(cfg)

cfg.demean = 'yes'
cfg.channel = 'AG*'
data = ft_preprocessing(cfg)


%% 
% cfg = []
% ft_databrowser(cfg,data)

%% rejectvisual
cfg = []
cfg.method = 'summary'
data_clean = ft_rejectvisual(cfg, data)


%% Extracts conditions``

cfg = [];
cfg.trials = data_clean.trialinfo==1;
avgHF = ft_timelockanalysis(cfg, data_clean);
cfg.trials = data_clean.trialinfo==2;
avgWN = ft_timelockanalysis(cfg, data_clean);
cfg.trials = data_clean.trialinfo==4;
avgLF = ft_timelockanalysis(cfg, data_clean);



%% create KIT Layout as described here: https://www.fieldtriptoolbox.org/getting_started/yokogawa/
% read the position of the sensors from the data

layout = create_kit_layout(kit_filename)

%% plot 

cfg = [];
cfg.showlabels = 'yes';
cfg.fontsize = 6;
cfg.layout = layout
cfg.ylim = [-3e-13 3e-13];
ft_multiplotER(cfg, avgLF, avgHF, avgWN);

%%
cfg=[]
cfg.parameter = 'avg'
cfg.operation = "x1-x2"
diff = ft_math(cfg, avgHF, avgLF)
cfg.layout = layout

ft_multiplotER(cfg, diff);

% figure, plot(diff.time, diff.avg)

%% 
cfg=[]
cfg.xlim = [-0.2:0.1:1]
cfg.layout  = layout
ft_topoplotER(cfg,diff)
%% 

% fit 2 dipoles for all 3 conditions averaged together (fit position and
% strength)
% keep position fixed, and fit estimate strength to separate 3 conditions
% 

mrifile = 'anat/anat-T1w/anat_T1w_anat-T1w_20231122111832_6.nii.gz';
mri_orig = ft_read_mri(mrifile);

dataset = 'sub-03-raw-kit.con';

% read the gradiometer definition from file, this is in dewar coordinates
grad = ft_read_sens(dataset, 'senstype', 'meg');

cfg             = [];
cfg.method      = 'interactive';
cfg.coordsys    = 'ctf';
mri_aligned     = ft_volumerealign(cfg,mri_orig);

cfg             = [];
cfg.method      = 'ortho';
cfg.interactive = 'yes';
ft_sourceplot(cfg,mri_aligned);