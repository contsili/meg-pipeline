
%% Data initialisation

% Tutorial reference: https://www.fieldtriptoolbox.org/tutorial/eventrelatedaveraging/

cfg                         = [];
cfg.dataset                 = '20240524_122045_sub-amalopm2_file-amalopm2_raw.fif';


data_all = ft_preprocessing(cfg);

% Read the header
hdr = ft_read_header(cfg.dataset);

% Display the header information
disp(hdr);


% The electrode positions for opm can be found in fieldtripdir/template/grad/fieldlinebeta2.mat






%% FFT analysis on HPI coils (This needs rework with Fieldline)

cfg            = [];
cfg.length     = 5;
cfg.overlap    = 0.8;


data_segmented = ft_redefinetrial(cfg, data_all);


cfg = [];
% cfg.dataset = '20240524_122045_sub-amalopm2_file-amalopm2_raw.fif';
cfg.method    = 'mtmfft';
cfg.channel = 'hpiin175';
cfg.foilim    = [0 100];
cfg.taper     = 'hanning';%'dpss';
%cfg.tapsmofrq = 0.2;
cfg.pad       = 10;
cfg.keeptrials    = 'yes';
freq          = ft_freqanalysis(cfg, data_segmented);

freq.powspctrm1 = squeeze(freq.powspctrm);

figure;
plot(freq.freq, log10(freq.powspctrm1(1,:)));
xlabel('frequency (Hz)');
ylabel('log_10 power')


%% HPI coils fft

%% FFT analysis

cfg            = [];
cfg.length     = 10;
cfg.overlap    = 0.8;
data_segmented = ft_redefinetrial(cfg, data_all);


cfg = [];
cfg.dataset = '20240524_122045_sub-amalopm2_file-amalopm2_raw.fif';
cfg.method    = 'mtmfft';
cfg.channel = {'R*', 'L*'};
cfg.foilim    = [0 40];
cfg.taper     = 'dpss';
cfg.tapsmofrq = 0.2;
cfg.pad       = 10;
freq          = ft_freqanalysis(cfg, data_segmented);

figure;
plot(freq.freq, log10(mean(freq.powspctrm)));
xlabel('frequency (Hz)');
ylabel('log_10 power')


%% Plot the trigger channel

cfg = [];
cfg.dataset = '20240524_122045_sub-amalopm2_file-amalopm2_raw.fif';
cfg.channel = 'di31';
data=ft_preprocessing(cfg);
figure;plot(data.time{1},data.trial{1});

%% Defining Trials

%value = 1 is the 500 Hz audio
%value = 2 is the white noise
%value = 3 is the 200 Hz audio

cfg = [];
cfg.dataset                 = '20240524_122045_sub-amalopm2_file-amalopm2_raw.fif';
cfg.trialfun = 'ft_trialfun_general'; % this is the default
cfg.trialdef.eventtype = 'di31';  % Specify the trigger channel
cfg.trialdef.eventvalue = [1, 2, 3];  % Define the value of the trigger
cfg.demean     = 'yes';
cfg.detrend = 'yes';
cfg.baselinewindow = [-0.2 0];
%cfg.lpfilter   = 'yes';                              % apply lowpass filter
%cfg.lpfreq     = 35;                                 % lowpass at 35 Hz.
cfg.trialdef.prestim        = 0.5; % in seconds
cfg.trialdef.poststim       = 1.2; % in seconds

cfg = ft_definetrial(cfg);

data = ft_preprocessing(cfg);


%% Visualise trials

cfg = ft_databrowser(cfg, data);



%% Filter trials on specific type (1)

cfg = [];
cfg.trials = data.trialinfo == 1;
dataLF = ft_redefinetrial(cfg, data);

save dataLF dataLF


%% Filter trials on specific type (2)

cfg = [];
cfg.trials = data.trialinfo == 2;
dataWN = ft_redefinetrial(cfg, data);

save dataWN dataWN


%% Filter trials on specific type (3)

cfg = [];
cfg.trials = data.trialinfo == 3;
dataHF = ft_redefinetrial(cfg, data);

save dataHF dataHF
 
%% Visual Inspection LF


cfg = [];
cfg.method='summary';
cfg.channel = {'L*', 'R*'};
 
dataLF_rej = ft_rejectvisual(cfg, dataLF);


save dataLF_rej dataLF_rej

%% Visual Inspection HF


cfg = [];
cfg.method='summary'; % Start first with eliminating trials rather than channels
cfg.channel = {'L*', 'R*'};
 
dataHF_rej = ft_rejectvisual(cfg, dataHF);

save dataHF_rej dataHF_rej

%% Visual Inspection WN


cfg = [];
cfg.method='summary';
cfg.channel = {'L*', 'R*'};
 
dataWN_rej = ft_rejectvisual(cfg, dataWN);

save dataWN_rej dataWN_rej


%% Plot each split trial data alone

ft_databrowser(cfg, dataLF_rej);




%% Timlockanalysis (can start from here)

% In an auditory experiment, we should see at 100ms the reaction due to the
% audio stimulus

load dataLF_rej
load dataHF_rej
load dataWN_rej

cfg = [];

avgLF = ft_timelockanalysis(cfg, dataLF_rej);
avgHF = ft_timelockanalysis(cfg, dataHF_rej);
avgWN = ft_timelockanalysis(cfg, dataWN_rej);

save avgLF avgLF
save avgHF avgHF
save avgWN avgWN

%% 

load avgLF
load avgHF
load avgWN

%% Plotting the averaged LF trials

% This will show the average over all trials for each channel for only one
% trigger condition

cfg = [];
cfg.showlabels = 'yes';
cfg.fontsize = 6;
cfg.layout = 'fieldlinebeta2bz_helmet.mat';
% cfg.ylim = [-3e-13 3e-13];
ft_multiplotER(cfg, avgLF);


%% Plotting the averaged WN trials

% This will show the average over all trials for each channel for only one
% trigger condition

cfg = [];
cfg.showlabels = 'yes';
cfg.fontsize = 6;
cfg.layout = 'fieldlinebeta2bz_helmet.mat';
% cfg.ylim = [-3e-13 3e-13];
ft_multiplotER(cfg, avgWN);





%% Plotting the averaged HF trials

% This will show the average over all trials for each channel for only one
% trigger condition

cfg = [];
cfg.showlabels = 'yes';
cfg.fontsize = 6;
cfg.layout = 'fieldlinebeta2bz_helmet.mat';
% cfg.ylim = [-3e-13 3e-13];
ft_multiplotER(cfg, avgHF);


%% Plotting all data

% Same as before but for all the stimulus type

cfg = [];
cfg.showlabels = 'yes';
cfg.fontsize = 6;

%This is saved under Fieldtrip_dir/template/layout
cfg.layout = 'fieldlinebeta2bz_helmet.mat';
cfg.baseline = [-0.2 0];
cfg.xlim = [-0.2 1.0];
% cfg.ylim = [-3e-13 3e-13];
ft_multiplotER(cfg, avgLF, avgWN, avgHF);








%% Plotting in space

% for a single trial type, for each channel, average over time the trial
% and plot the average value on the helmet

% You can still see the time behavior when clicking on one sensor

%LF
cfg = [];
cfg.xlim = [0.05 0.5];
cfg.colorbar = 'yes';
cfg.layout = 'fieldlinebeta2bz_helmet.mat';
ft_topoplotER(cfg, avgLF);


%White Noise

cfg = [];
cfg.xlim = [0.05 0.5];
cfg.colorbar = 'yes';
cfg.layout = 'fieldlinebeta2bz_helmet.mat';
ft_topoplotER(cfg, avgWN);


%High Frequency

cfg = [];
cfg.xlim = [0.05 0.5];
cfg.colorbar = 'yes';
cfg.layout = 'fieldlinebeta2bz_helmet.mat';
ft_topoplotER(cfg, avgHF);




%% Plotting the contrast

cfg = [];
cfg .parameter = 'avg';
cfg.operation = 'x1-x2';
diff = ft_math(cfg, avgHF, avgLF);

cfg.layout = 'fieldlinebeta2bz_helmet.mat';

ft_multiplotER(cfg,diff);


%% Topoplot on diff

cfg        = [];
cfg.xlim   = [-0.2 : 0.1 : 0.5];  % Define 12 time intervals
%cfg.zlim   = [-2e-13 2e-13];      % Set the 'color' limits.
cfg.layout = 'fieldlinebeta2bz_helmet.mat';
ft_topoplotER(cfg, diff);



%% Plotting in space

%Same as before, but not plotting the average rather than at specific times

cfg        = [];
cfg.xlim   = [-0.2 : 0.1 : 1.0];  % Define 12 time intervals
cfg.zlim   = [-2e-13 2e-13];      % Set the 'color' limits.
cfg.layout = 'fieldlinebeta2bz_helmet.mat';
ft_topoplotER(cfg, avgWN);






% %% Computing the gradient of the magnetic field
% 
% % For each channel you need to identify the neighbors and compute the
% % decrease in the field, this will give you the gradient
% 
% cfg                 = [];
% cfg.feedback        = 'yes';
% cfg.method          = 'template';
% cfg.neighbours      = ft_prepare_neighbours(cfg, avgFIC);
% 
% cfg.planarmethod    = 'sincos';
% avgFICplanar        = ft_megplanar(cfg, avgFIC);
% 
% 
% cfg = [];
% avgFICplanarComb = ft_combineplanar(cfg, avgFICplanar);
% 
% 
% cfg = [];
% cfg.xlim = [0.3 0.5];
% cfg.zlim = 'maxmin';
% cfg.colorbar = 'yes';
% cfg.layout = 'CTF151_helmet.mat';
% cfg.figure  = subplot(121);
% ft_topoplotER(cfg, avgFIC)
% 
% colorbar; % you can also try out cfg.colorbar = 'south'
% 
% cfg.zlim = 'maxabs';
% cfg.layout = 'CTF151_helmet.mat';
% cfg.figure  = subplot(122);
% ft_topoplotER(cfg, avgFICplanarComb);




%% Load segmented MRI

% load segment_mri_test.mat

%% MRI segmentation


% mri = ft_read_mri('Subject01.mri');
% 
% cfg = [];
% cfg.write      = 'no';
% [segmentedmri] = ft_volumesegment(cfg, mri);


%% Prepare headmodel

% cfg = [];
% cfg.method = 'singleshell';
% headmodel = ft_prepare_headmodel(cfg, segmentedmri);










%% Plot headmodel with layout from fif


%%To use the specific layout used during the recording, get the grad layout
%%from .fif loading

% Note: this layout from .fif doesn't seem to have the 8 reference points

% sensors = ft_convert_units(data_all.grad, 'mm');
% 
% figure
% ft_plot_sens(sensors);
% hold on
%ft_plot_headmodel(ft_convert_units(headmodel,'mm'));



%% Plot headmodel with layout from OPM tempalte 

% Load OPM sensor layout

%Note this seems to have the 8 reference points

% load fieldlinebeta2.mat
% 
% fieldlinebeta2 = ft_convert_units(fieldlinebeta2, 'mm');
% 
% 
% figure
% ft_plot_sens(fieldlinebeta2);
% hold on
% ft_plot_headmodel(ft_convert_units(headmodel,'mm'));


%% Data initialisation: Part II: Coregistration

% Tutorial reference: https://www.fieldtriptoolbox.org/tutorial/eventrelatedaveraging/

cfg                         = [];
cfg.dataset                 = '20240524_122045_sub-amalopm2_file-amalopm2_raw.fif';


data_all = ft_preprocessing(cfg);

% Read the header
hdr = ft_read_header(cfg.dataset);

% Display the header information
disp(hdr);


% The electrode positions for opm can be found in fieldtripdir/template/grad/fieldlinebeta2.mat


%% Import digitized head

%% read in the data and enforce the units to be in 'mm'

headshape = ft_read_headshape('converted_coordinates_sub_03.pos');
headshape = ft_convert_units(headshape, 'mm');


%% visualization, coordinate axes are initially ALS
figure
ft_plot_headshape(headshape)
ft_plot_axes(headshape)
view([-27 20])

nas = headshape.fid.pos(strcmp(headshape.fid.label, 'nas'),:);
lpa = headshape.fid.pos(strcmp(headshape.fid.label, 'lpa'),:);
rpa = headshape.fid.pos(strcmp(headshape.fid.label, 'rpa'),:);

T = ft_headcoordinates(nas, lpa, rpa, 'neuromag');
headshape = ft_transform_geometry(T, headshape);
headshape.coordsys = 'neuromag';


%% visualization, coordinate axes are now RAS
figure
ft_plot_headshape(headshape)
ft_plot_axes(headshape)
hold on
ft_plot_sens(sensors)
view([114 20])

%% Plot misalignment

% This stage requires the 8 reference points

% Load reference points from OPM layout


% Problem: the layout from the .fif doesn't match the layout from the OPM
% template

%standard layout for helmet
fieldlinebeta2 = ft_read_sens('fieldlinebeta2.mat'); % from fieldtrip/template/grad
fieldlinebeta2 = ft_convert_units(fieldlinebeta2, 'mm');
fid_helmet     = fieldlinebeta2.fid;

%layout from fif with actual sensor place during the scan
sensors = ft_convert_units(data_all.grad, 'mm');

figure
ft_plot_headshape(headshape)
ft_plot_axes(headshape)
hold on
ft_plot_sens(sensors)



%hold on
%ft_plot_sens(fieldlinebeta2)
view([114 20])


%% Coregistration


% Aligning the headshape with sensor position
transhp = headshape.pos';

transsensor = sensors.chanpos';

[TR, TT] = icp(transhp, transsensor);



%%
% Plotting after aligning with ICP

transformed_coords = TR*transsensor + TT

%transformed_points = ft_transform_geometry(TR, headshape.pos');

%% Plot after transforming

%headshape.pos = transformed_coords'

sensors.chanpos = transformed_coords'

figure
ft_plot_headshape(headshape)
ft_plot_axes(headshape)
hold on
ft_plot_sens(sensors)
%hold on
%ft_plot_sens(fieldlinebeta2)
view([114 20])


%The headshape is now aligned with the acquired sensor placements
% Question, in donders does the sensors can be displaced to account for
% head position or not?


%% Load MRI data

mri = ft_read_mri('sub-003-MRI.nii.gz');
mri = ft_convert_units(mri, 'mm');
mri = ft_determine_coordsys(mri, 'interactive', 'yes'); %The answers are X-axis = right, Y-axis = anterior, Z-axis = superior
%Origin is n(ot a landmark)

%%
save mri mri

%%

cfg = [];
cfg.write      = 'no';
[segmentedmri] = ft_volumesegment(cfg, mri); %The answers are X-axis = right, Y-axis = posterior, Z-axis = superior
%Origin is anterior commisure a


%%
save segmentedmri segmentedmri

%% Prepare the headmodel


load segmentedmri
cfg = [];
cfg.method = 'singleshell';
headmodel = ft_prepare_headmodel(cfg, segmentedmri);


%% Pick fiducials on mri

cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'ctf';

mri_init = ft_volumerealign(cfg,mri);

ft_determine_coordsys(mri_init, 'interactive', 'no');



%% Plot the headmodel from mri

figure
ft_plot_headmodel(headmodel)
ft_plot_headshape(headshape)
ft_plot_axes(headshape)
hold on
ft_plot_sens(sensors)



%% Source localization beginning





%% Defining Trials

%value = 1 is the 500 Hz audio
%value = 2 is the white noise
%value = 3 is the 200 Hz audio

cfg = [];
cfg.dataset                 = '20240524_122045_sub-amalopm2_file-amalopm2_raw.fif';
cfg.trialfun = 'ft_trialfun_general'; % this is the default
cfg.trialdef.eventtype = 'di31';  % Specify the trigger channel
cfg.trialdef.eventvalue = [1, 2, 3];  % Define the value of the trigger
cfg.demean     = 'yes';
cfg.detrend = 'yes';
cfg.baselinewindow = [-0.2 0];
%cfg.lpfilter   = 'yes';                              % apply lowpass filter
%cfg.lpfreq     = 35;                                 % lowpass at 35 Hz.
cfg.trialdef.prestim        = 0.5; % in seconds
cfg.trialdef.poststim       = 1.2; % in seconds

cfg = ft_definetrial(cfg);

data_all = ft_preprocessing(cfg);




%% Select the conditions and time window


cfg = [];
cfg.trials  = data_all.trialinfo == 1;
cfg.latency = [-0.2 -0.05];
dataPre     = ft_selectdata(cfg, data_all);

cfg.trials  = data_all.trialinfo == 1;
cfg.latency = [0.05 0.2];
dataPost    = ft_selectdata(cfg, data_all);



%% Compute spectral density matrix 
cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'powandcsd';
cfg.tapsmofrq = 4;
cfg.foilim    = [18 18];
freqPre = ft_freqanalysis(cfg, dataPre);

cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'powandcsd';
cfg.tapsmofrq = 4;
cfg.foilim    = [18 18];
freqPost = ft_freqanalysis(cfg, dataPost);



%% Define the beamformer grid

cfg                  = [];
cfg.grad             = freqPost.grad;
cfg.headmodel        = headmodel;

% use a 3-D grid with a 1 cm resolution
cfg.resolution       = 1;   
cfg.sourcemodel.unit = 'cm';
sourcemodel = ft_prepare_leadfield(cfg);



%% Source analysis Without contrasting condition

cfg              = [];
cfg.method       = 'dics';
cfg.frequency    = 18;

cfg.channel          = {'L*','R*'};
cfg.sourcemodel  = sourcemodel;
cfg.headmodel    = headmodel;
cfg.dics.projectnoise = 'yes';
cfg.dics.lambda       = 0;

sourcePost_nocon = ft_sourceanalysis(cfg, freqPost);



%% Interpolate power from grid points to the mri voxels



cfg = [];
mri_init = ft_volumereslice(cfg, mri_init);

cfg            = [];
cfg.downsample = 2;
cfg.parameter  = 'pow';
sourcePostInt_nocon  = ft_sourceinterpolate(cfg, sourcePost_nocon, mri);



%%Plot  the source

cfg              = [];
cfg.method       = 'slice';
cfg.funparameter = 'pow';
ft_sourceplot(cfg, sourcePostInt_nocon);



%% Correcting the Bias in center noise by computing the noise index


sourceNAI = sourcePost_nocon;
sourceNAI.avg.pow = sourcePost_nocon.avg.pow ./ sourcePost_nocon.avg.noise;

cfg = [];
cfg.downsample = 2;
cfg.parameter = 'pow';
sourceNAIInt = ft_sourceinterpolate(cfg, sourceNAI , mri);


%% Plotting source activity after noise correction

%% For LF stimulus without contrasting AFter Noise Correction

maxval = max(sourceNAIInt.pow, [], 'all');

cfg = [];
cfg.method        = 'slice';
cfg.funparameter  = 'pow';
%cfg.maskparameter = cfg.funparameter;
% cfg.funcolorlim   = [4.0 maxval]; %
% cfg.opacitylim    = [4.0 maxval]; %Only make the color seeable in that interval
% cfg.opacitymap    = 'rampup';
ft_sourceplot(cfg, sourceNAIInt);


% TODO: Correct the coregistration


%% With contrasting

dataAll = ft_appenddata([], dataPre, dataPost);

cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'powandcsd';
cfg.channel          = {'L*','R*'};
cfg.tapsmofrq = 4;
cfg.foilim    = [18 18];
freqAll = ft_freqanalysis(cfg, dataAll);


cfg              = [];
cfg.method       = 'dics';
cfg.frequency    = 18;
cfg.channel          = {'L*','R*'};
cfg.sourcemodel  = sourcemodel;
cfg.headmodel    = headmodel;
cfg.dics.projectnoise = 'yes';
cfg.dics.lambda       = '5%';
cfg.dics.keepfilter   = 'yes';
cfg.dics.realfilter   = 'yes';
sourceAll = ft_sourceanalysis(cfg, freqAll);


cfg.sourcemodel.filter = sourceAll.avg.filter;
sourcePre_con  = ft_sourceanalysis(cfg, freqPre );
sourcePost_con = ft_sourceanalysis(cfg, freqPost);

save sourcePre_con sourcePre_con
save sourcePost_con sourcePost_con

%%
sourceDiff = sourcePost_con;
sourceDiff.avg.pow = (sourcePost_con.avg.pow - sourcePre_con.avg.pow) ./ sourcePre_con.avg.pow;


cfg            = [];
%cfg.downsample = 2;
cfg.parameter  = 'pow';
cfg.channel          = {'L*','R*'};
sourceDiffInt  = ft_sourceinterpolate(cfg, sourceDiff , mri_init);


%% Plot the source frequencies with contrasting (pre and post)

maxval = max(sourceDiffInt.pow, [], 'all');

cfg = [];
cfg.method        = 'slice';
cfg.funparameter  = 'pow';
cfg.channel          = {'L*','R*'};
cfg.maskparameter = cfg.funparameter;
cfg.funcolorlim   = [0.0 maxval];
cfg.opacitylim    = [0.0 maxval];
cfg.opacitymap    = 'rampup';
ft_sourceplot(cfg, sourceDiffInt);

%% Coregistration of MRI headmodel with headshape

mri_init = ft_convert_units(mri_init, 'mm');
ft_determine_coordsys(mri_init, 'interactive', 'no')






%%

cfg =[];
cfg.method = 'fiducial'
%The fiducials can be found in mri_init.cfg.fiducial WE had specified them
%from the previous step

cfg.fiducial = mri_init.cfg.fiducial 


[realign, snap] = ft_volumerealign(cfg, mri_init, headshape.fid)

%lpa, nas, rpa
















%% 
save segmentedmri-sub003 segmentedmri-sub003


%%

load segmentedmri-sub003











%% Beamformer application

%


