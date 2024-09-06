clear all
close all
clc

fif = 'sub-03-raw-kit-raw.fif'
con = 'sub-03-raw-kit.con'



%% 
% cfg = [];
% cfg.dataset  = fif;
% cfg.trialdef.eventvalue = 1;
% cfg.trialdef.prestim    = 1;
% cfg.trialdef.poststim   = 1;
% cfg.trialfun = 'ft_trialfun_general';
% cfg.trialdef.eventvalue     = [4 2 1]; % the values of the stimulus trigger for the three conditions LF ch225=4, WN ch226=2, HF ch227=1 
% cfg.trialdef.chanindx = 225:227; % this will make the binary value either 100 LF(ch225) or WN 010(ch226) or HF 001(ch227)
% cfg.trialdef.threshold = 0.5; % this is a meaningful value if the pulses have an amplitude of ~5 V
% cfg.trialdef.eventtype = 'combined_binary_trigger'; % this will be the type of the event if combinebinary = true
% cfg.trialdef.combinebinary = 1;
% % cfg.trialdef.trigshift = 2; % return the value of the combined pulse 2 samples after the on-ramp (in case of small staircases)
% cfg = ft_definetrial(cfg)
% 
% 
% cfg         = [];
% cfg.dataset = fif;
% fifdata     = ft_preprocessing(cfg);
% fifdatahdr = ft_read_header(fif);% read header from first file
% 
% ft_write_data('fifdata_resaved.vhdr', fifdata, 'header', fifdatahdr);
% 
% 
% %% 
% cfg = [];
% cfg.dataset  = con;
% cfg.trialdef.eventvalue = 1;
% cfg.trialdef.prestim    = 1;
% cfg.trialdef.poststim   = 1;
% cfg.trialfun = 'ft_trialfun_general';
% cfg.trialdef.eventvalue     = [4 2 1]; % the values of the stimulus trigger for the three conditions LF ch225=4, WN ch226=2, HF ch227=1 
% cfg.trialdef.chanindx = 225:227; % this will make the binary value either 100 LF(ch225) or WN 010(ch226) or HF 001(ch227)
% cfg.trialdef.threshold = 0.5; % this is a meaningful value if the pulses have an amplitude of ~5 V
% cfg.trialdef.eventtype = 'combined_binary_trigger'; % this will be the type of the event if combinebinary = true
% cfg.trialdef.combinebinary = 1;
% % cfg.trialdef.trigshift = 2; % return the value of the combined pulse 2 samples after the on-ramp (in case of small staircases)
% cfg = ft_definetrial(cfg)
% 
% cfg.demean = 'yes'
% cfg.channel = 'AG*'
% data = ft_preprocessing(cfg)
% 
% %%
% 
% 
% % fit 2 dipoles for all 3 conditions averaged together (fit position and
% % strength)
% % keep position fixed, and fit estimate strength to separate 3 conditions
% % 
% 
% mrifile = '/Users/oa22/Desktop/toolkit2024/practice/meg_kit_oddball/sub-003/mri/orig.mgz';
% mri_orig = ft_read_mri(mrifile);
% 
% dataset = 'sub-03-raw-kit.con';
% 
% % read the gradiometer definition from file, this is in dewar coordinates
% grad = ft_read_sens(dataset, 'senstype', 'meg');
% 
% cfg             = [];
% cfg.method      = 'interactive';
% cfg.coordsys    = 'ctf';
% mri_aligned     = ft_volumerealign(cfg,mri_orig);
% 
% cfg             = [];
% cfg.method      = 'ortho';
% cfg.interactive = 'yes';
% ft_sourceplot(cfg,mri_aligned);