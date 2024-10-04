
%% Attention task pipeline for external noise reduced data

MEG_DATA_FOLDER = getenv('MEG_DATA');

% Set path to KIT .con file of sub-03
DATASET_PATH = [MEG_DATA_FOLDER,'attention-task\'];

%THis needs fixing to sav eproperly
SAVE_PATH = [MEG_DATA_FOLDER, 'attention-task\'];

SUB_ID = 'sub-01\';

ATTEND_RIGHT_CON = [DATASET_PATH, SUB_ID, 'attention_attend_right_01.con'];

ATTEND_LEFT_CON = [DATASET_PATH, SUB_ID, 'attention_attend_left_01.con'];


%Trigger information: KIT channel indexing starts with 0 while MATLAB
%indexing starts with 1, so ch224 on KIT is ch225 in MATLAB

% % Attend left and target appearing right 
% trig.ch224 = [4  0  0]; %224 meg channel

% % Attend left and target appearing left
% trig.ch225 = [16  0  0];  %225 meg channel

% % Attend right and target appearing right
% trig.ch226 = [64 0 0]; % 226 meg channel

% % Attend right and target appearing left
% trig.ch227 = [0  1 0]; % 227 meg channel


    %% Preprocess data

    % Preprocess the MEG data
    cfg = [];
    cfg.dataset = ATTEND_RIGHT_CON;
    cfg.coilaccuracy = 0;
    data_MEG_RIGHT = ft_preprocessing(cfg);

    % Preprocess the MEG data
    cfg = [];
    cfg.dataset = ATTEND_LEFT_CON;
    cfg.coilaccuracy = 0;
    data_MEG_LEFT = ft_preprocessing(cfg);



    %% Filtering data
    
    
    % Notch filter the data at 50 Hz
    cfg = [];
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [49 51]; % Notch filter range
    data_MEG_RIGHT = ft_preprocessing(cfg, data_MEG_RIGHT);

    % Band-pass filter the data
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [4 40]; % Band-pass filter range
    cfg.bpfiltord = 4;    % Filter order
    data_MEG_RIGHT = ft_preprocessing(cfg, data_MEG_RIGHT);


    % Notch filter the data at 50 Hz
    cfg = [];
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [49 51]; % Notch filter range
    data_MEG_LEFT = ft_preprocessing(cfg, data_MEG_LEFT);

    % Band-pass filter the data
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [4 40]; % Band-pass filter range
    cfg.bpfiltord = 4;    % Filter order
    data_MEG_LEFT = ft_preprocessing(cfg, data_MEG_LEFT);


%%

   % %% Clean Data Attend Left
   % 
   %  cfg = []
   %  cfg.method = 'summary'
   %  cfg.channel = {'AG*'};
   %  data_clean_left = ft_rejectvisual(cfg, data_MEG_LEFT)
   % 
   % 
   % 
   % %% Clean Data Attend Right
   % 
   %  cfg = []
   %  cfg.method = 'summary'
   %  cfg.channel = {'AG*'};
   %  data_clean_right = ft_rejectvisual(cfg, data_MEG_RIGHT)
   % 
   %  % TODO: Use the clean data in the pipeline instead of the raw data

    %% Define trials and segment the data: Attend Left Target Right

    previewTrigger = data_MEG_LEFT.trial{1}(225, :);

    threshold = (max(previewTrigger) + min(previewTrigger)) / 2;

    cfg = [];
    cfg.dataset  = ATTEND_LEFT_CON;
    cfg.trialdef.eventvalue = 1; % placeholder for the conditions
    cfg.trialdef.prestim    = 0.5; % 1s before stimulus onset
    cfg.trialdef.poststim   = 1.2; % 1s after stimulus onset
    cfg.trialfun = 'ft_trialfun_general';
    cfg.trialdef.chanindx = 225;
    cfg.trialdef.threshold = threshold;
    cfg.trialdef.eventtype = 'combined_binary_trigger'; % this will be the type of the event if combinebinary = true
    cfg.trialdef.combinebinary = 1;

    TRIALS_AL_TR = ft_definetrial(cfg);
    
    SG_AL_TR = ft_preprocessing(TRIALS_AL_TR);
    
    %% Define trials and segment the data: Attend Left Target Left

    previewTrigger = data_MEG_LEFT.trial{1}(226, :);

    threshold = (max(previewTrigger) + min(previewTrigger)) / 2;

    cfg = [];
    cfg.dataset  = ATTEND_LEFT_CON;
    cfg.trialdef.eventvalue = 1; % placeholder for the conditions
    cfg.trialdef.prestim    = 0.5; % 1s before stimulus onset
    cfg.trialdef.poststim   = 1.2; % 1s after stimulus onset
    cfg.trialfun = 'ft_trialfun_general';
    cfg.trialdef.chanindx = 226;
    cfg.trialdef.threshold = threshold;
    cfg.trialdef.eventtype = 'combined_binary_trigger'; % this will be the type of the event if combinebinary = true
    cfg.trialdef.combinebinary = 1;
    
    TRIALS_AL_TL = ft_definetrial(cfg);
    
    SG_AL_TL = ft_preprocessing(TRIALS_AL_TL);

    %% Define trials and segment the data: Attend Right Target Right

    previewTrigger = data_MEG_RIGHT.trial{1}(227, :);

    threshold = (max(previewTrigger) + min(previewTrigger)) / 2;

    cfg = [];
    cfg.dataset  = ATTEND_RIGHT_CON;
    cfg.trialdef.eventvalue = 1; % placeholder for the conditions
    cfg.trialdef.prestim    = 0.5; % 1s before stimulus onset
    cfg.trialdef.poststim   = 1.2; % 1s after stimulus onset
    cfg.trialfun = 'ft_trialfun_general';
    cfg.trialdef.chanindx = 227;
    cfg.trialdef.threshold = threshold;
    cfg.trialdef.eventtype = 'combined_binary_trigger'; % this will be the type of the event if combinebinary = true
    cfg.trialdef.combinebinary = 1;
    
    TRIALS_AR_TR = ft_definetrial(cfg);
    
    SG_AR_TR = ft_preprocessing(TRIALS_AR_TR);


    %% Define trials and segment the data: Attend Right Target Left

    previewTrigger = data_MEG_RIGHT.trial{1}(228, :);

    threshold = (max(previewTrigger) + min(previewTrigger)) / 2;

    cfg = [];
    cfg.dataset  = ATTEND_RIGHT_CON;
    cfg.trialdef.eventvalue = 1; % placeholder for the conditions
    cfg.trialdef.prestim    = 0.5; % 1s before stimulus onset
    cfg.trialdef.poststim   = 1.2; % 1s after stimulus onset
    cfg.trialfun = 'ft_trialfun_general';
    cfg.trialdef.chanindx = 228;
    cfg.trialdef.threshold = threshold;
    cfg.trialdef.eventtype = 'combined_binary_trigger'; % this will be the type of the event if combinebinary = true
    cfg.trialdef.combinebinary = 1;
    
    TRIALS_AR_TL = ft_definetrial(cfg);
    
    SG_AR_TL = ft_preprocessing(TRIALS_AR_TL);

    %% Inspection and data quality of trials


    %% Visual Inspection ALTL
    
    cfg = [];
    cfg.method='summary';
    cfg.channel = {'AG*'};
    
    dataALTL_rej = ft_rejectvisual(cfg, SG_AL_TL);

 %% Visual Inspection ALTR
    cfg = [];
    cfg.method='summary';
    cfg.channel = {'AG*'};
    
    dataALTR_rej = ft_rejectvisual(cfg, SG_AL_TR);


 %% Visual Inspection ARTR
    cfg = [];
    cfg.method='summary';
    cfg.channel = {'AG*'};
    
    dataARTR_rej = ft_rejectvisual(cfg, SG_AR_TR);


    %% Visual Inspection ARTL
    cfg = [];
    cfg.method='summary';
    cfg.channel = {'AG*'};
    
    dataARTL_rej = ft_rejectvisual(cfg, SG_AR_TL);
    
    %% Averaging trials together

    cfg = [];
    
    avgALTL = ft_timelockanalysis(cfg, dataALTL_rej);
    avgALTR = ft_timelockanalysis(cfg, dataALTR_rej);
    avgARTR = ft_timelockanalysis(cfg, dataARTR_rej);
    avgARTL = ft_timelockanalysis(cfg, dataARTL_rej);

    %% Save trials
 
save avgALTL avgALTL
save avgALTR avgALTR
save avgARTR avgARTR
save avgARTL avgARTL


 %% LOAD averages

load avgALTL avgALTL
load avgALTR avgALTR
load avgARTR avgARTR
load avgARTL avgARTL
    

%% Prepare KIT layout

kit_layout = create_kit_layout(ATTEND_LEFT_CON);

cfg = [];
cfg.layout = kit_layout;  % Specify the layout
ft_layoutplot(cfg);       % Plot the layout of the sensors


%% Plotting in space

% for a single trial type, for each channel, average over time the trial
% and plot the average value on the helmet

% You can still see the time behavior when clicking on one sensor

cfg = [];
cfg.xlim = [0.05 1.2];
cfg.colorbar = 'yes';
cfg.layout = kit_layout;
ft_topoplotER(cfg, avgALTL);

cfg = [];
cfg.xlim = [0.05 1.2];
cfg.colorbar = 'yes';
cfg.layout = kit_layout;
ft_topoplotER(cfg, avgARTL);





%% Plot conditions on same plot  ALTL and ARTL




% Define the sensor of interest (for example, 'MZC01')
%sensor_name = 'AG181';
sensor_name = 'AG147';

% Find the index of the sensor in the layout
sensor_idx = find(strcmp(avgALTL.label, sensor_name));

% Extract time and data for the sensor from both conditions
time = avgALTL.time; % Assuming both conditions have the same time vector
data_ALTL = avgALTL.avg(sensor_idx, :);
data_ARTL = avgARTL.avg(sensor_idx, :);

% Plot both conditions for the same sensor
figure;
plot(time, data_ALTL, 'g', 'LineWidth', 2); % Plot avgALTL in blue
hold on;
plot(time, data_ARTL, 'r', 'LineWidth', 2); % Plot avgARTL in red

% Add labels and legend
xlabel('Time (s)');
ylabel('Amplitude');
legend('ALTL Condition', 'ARTL Condition');
title(['Comparison of Conditions for Sensor: ' sensor_name]);

% Add grid for better visualization
grid on;








%% Plot conditions on same plot  ARTR and ALTR




% Define the sensor of interest (for example, 'MZC01')
%sensor_name = 'AG181';
sensor_name = 'AG147';

% Find the index of the sensor in the layout
sensor_idx = find(strcmp(avgARTR.label, sensor_name));

% Extract time and data for the sensor from both conditions
time = avgALTL.time; % Assuming both conditions have the same time vector
data_ARTR = avgARTR.avg(sensor_idx, :);
data_ALTR = avgALTR.avg(sensor_idx, :);

% Plot both conditions for the same sensor
figure;
plot(time, data_ARTR, 'g', 'LineWidth', 2); % Plot avgALTL in blue
hold on;
plot(time, data_ALTR, 'r', 'LineWidth', 2); % Plot avgARTL in red

% Add labels and legend
xlabel('Time (s)');
ylabel('Amplitude');
legend('ARTR Condition', 'ALTR Condition');
title(['Comparison of Conditions for Sensor: ' sensor_name]);

% Add grid for better visualization
grid on;


%% Filtering


    % Band-pass filter the data
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [4 30]; % Band-pass filter range
    cfg.bpfiltord = 4;    % Filter order
    filtered_avgARTR = ft_preprocessing(cfg, avgARTR);



    % Band-pass filter the data
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [4 30]; % Band-pass filter range
    cfg.bpfiltord = 4;    % Filter order
    filtered_avgALTR = ft_preprocessing(cfg, avgALTR);




%% Plot for Filtered data

% Define the sensor of interest (for example, 'MZC01')
%sensor_name = 'AG181';
sensor_name = 'AG147';

% Find the index of the sensor in the layout
sensor_idx = find(strcmp(filtered_avgARTR.label, sensor_name));

% Extract time and data for the sensor from both conditions
time = avgALTL.time; % Assuming both conditions have the same time vector
data_ARTR = filtered_avgARTR.avg(sensor_idx, :);
data_ALTR = filtered_avgALTR.avg(sensor_idx, :);

% Plot both conditions for the same sensor
figure;
plot(time, data_ARTR, 'g', 'LineWidth', 2); % Plot avgALTL in blue
hold on;
plot(time, data_ALTR, 'r', 'LineWidth', 2); % Plot avgARTL in red

% Add labels and legend
xlabel('Time (s)');
ylabel('Amplitude');
legend('ARTR Condition', 'ALTR Condition');
title(['Comparison of Conditions for Sensor: ' sensor_name]);

% Add grid for better visualization
grid on;

%% 




cfg = [];
cfg.xlim = [0.05 1.2];
cfg.colorbar = 'yes';
cfg.layout = kit_layout;
ft_topoplotER(cfg, avgALTR);


cfg = [];
cfg.xlim = [0.05 1.2];
cfg.colorbar = 'yes';
cfg.layout = kit_layout;
ft_topoplotER(cfg, avgARTR);




%% Contrast

%% Plotting the contrast

cfg = [];
cfg .parameter = 'avg';
cfg.operation = 'x1-x2';

diff_ALTL_ARTR = ft_math(cfg, avgALTL, avgARTR);

cfg.layout = kit_layout;

ft_multiplotER(cfg,diff_ALTL_ARTR);


%% Plotting the contrast ARTR-ALTL

cfg = [];
cfg .parameter = 'avg';
cfg.operation = 'x1-x2';
% Correct by reducing the number of trials of the LF
% When we contrast, we do not want to bias one type of trial over the other if one type of trials has a higher number of trials than another type, which is the case in this experiment
diff_ARTR_ALTL = ft_math(cfg, avgARTR, avgALTL);

cfg.layout = kit_layout;

ft_multiplotER(cfg,diff_ARTR_ALTL);


%% 

cfg = [];
cfg.xlim = [0.05 0.7];
cfg.colorbar = 'yes';
cfg.layout = kit_layout;
ft_topoplotER(cfg, diff_ALTL_ARTR);



% Get the color axis limits
caxis_limits = caxis;


cfg = [];
cfg.xlim = [0.05 0.7];
cfg.colorbar = 'yes';
cfg.layout = kit_layout;
ft_topoplotER(cfg, diff_ARTR_ALTL);

% Apply the same color axis limits
clim(caxis_limits);



%% ALTL - ARTL

cfg = [];
cfg .parameter = 'avg';
cfg.operation = 'x1-x2';

diff_ALTL_ARTL = ft_math(cfg, avgALTL, avgARTL);

cfg.layout = kit_layout;

ft_multiplotER(cfg,diff_ALTL_ARTL);




%% ERP





%% Frequency Analysis


% TODO: Apply external noise filtering from magnetometers then repeat
% frequency analysis

% Frequency analysis in the alpha band 8-12Hz (same graph comparison for
% ALTL and ARTL :plot of both in frequencies (occipital lobe, higher
% amplitude in the right occipital) over time
% ARTR and ALTR : second plot of both in frequencies (occipital lobe,
% higher amplitude in the left occipital) over time

%ALTL trials

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:0.5:30;                        % analysis 2 to 30 Hz in steps of 2 Hz
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.2:0.05:0.9;                      % the time window "slides" from -0.5 to 1.5 in 0.05 sec steps
TFRhann_ALTL = ft_freqanalysis(cfg, dataALTL_rej);    % visual stimuli


%% Plot all sensors

% ALTL
cfg = [];
cfg.baseline     = [-0.5 -0.05];
cfg.baselinetype = 'absolute';
cfg.zlim         = [-2.5e-27 2.5e-27];
cfg.showlabels   = 'yes';
cfg.layout       = kit_layout;
figure
ft_multiplotTFR(cfg, TFRhann_ALTL);



%% ARTL Frequency Analysis computation

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:0.5:30;                        % analysis 2 to 30 Hz in steps of 2 Hz
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;   % length of time window = 0.5 sec
cfg.toi          = -0.2:0.05:0.9;                      % the time window "slides" from -0.5 to 1.5 in 0.05 sec steps
TFRhann_ARTL = ft_freqanalysis(cfg, dataARTL_rej);    % visual stimuli

%% ARTL Frequency Analysis visualisation
cfg = [];
cfg.baseline     = [-0.5 -0.05];
cfg.baselinetype = 'absolute';
cfg.zlim         = [-2.5e-27 2.5e-27];
cfg.showlabels   = 'yes';
cfg.layout       = kit_layout;
figure
ft_multiplotTFR(cfg, TFRhann_ARTL);

%% Single channel frequency analysis plot

cfg              = [];
cfg.baseline     = [-0.3 -0.1];
cfg.baselinetype = 'absolute';
cfg.maskstyle    = 'saturation';
cfg.zlim         = [-2e-27 2e-27];
cfg.channel      = 'AG206';
cfg.interactive  = 'no';
cfg.layout       = kit_layout;
figure
ft_singleplotTFR(cfg, TFRhann7);


%%
% Plot Single Channel


cfg = [];
cfg.baseline     = [-0.3 -0.1];
cfg.baselinetype = 'absolute';
cfg.maskstyle    = 'saturation';
cfg.zlim         = [-2.5e-27 2.5e-27];
cfg.channel      = 'AG206';
cfg.layout       = kit_layout;
figure
ft_singleplotTFR(cfg, TFRhann_ALTL);


