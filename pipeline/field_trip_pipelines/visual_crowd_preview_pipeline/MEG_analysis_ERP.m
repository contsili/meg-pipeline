% This script handles the preprocessing of the MEG data, including defining trials and data segmentation, 
% cleaning the data using filters and manual visual rejection, seperating
% trials into conditions and Timelockanalysis
% Finally, the ERPs are plotted

%%
% Add FieldTrip directory to the top of the MATLAB path to fix the error of
% the 'nearest' function
addpath('C:\Users\tasni\AppData\Roaming\MathWorks\MATLAB Add-Ons\Collections\FieldTrip\utilities');

% Set FieldTrip defaults
ft_defaults;

% Verify the correct 'nearest' function is being used
which nearest

%% Loading the MEG and MATLAB data

% Define the paths to the MEG data and MATLAB data folders
megDataFolder = 'MEG data';
matlabDataFolder = 'MATLAB Data';
resultsFolder = 'Averaging Results';

% Get a list of all MEG data files in the folder matching the specific pattern
megFiles = dir(fullfile(megDataFolder, 'Sub_*_01_vcp.con'));

% Get a list of all MATLAB data files in the folder matching the specific pattern
matFiles = dir(fullfile(matlabDataFolder, 'Sub_*_vcp.mat'));


segmented_data_all = cell(1, length(megFiles));

% Loop over each MEG data file
for k = 1:length(megFiles)
    % Get the current MEG data file name
    confile = fullfile(megDataFolder, megFiles(k).name);

    % Extract the subject identifier from the MEG file name
    [~, filename, ~] = fileparts(megFiles(k).name);
    numericalPart = filename(5:7); % Extract the numerical part, assuming 'Sub_###'
    subjectID = sprintf('Subject %s', numericalPart); % Format to 'Subject ###'

    % Construct the corresponding MATLAB data file path
    matFileName = sprintf('Sub_%s_vcp.mat', numericalPart);
    matFilePath = fullfile(matlabDataFolder, matFileName);

    % Check if the MATLAB data file exists in the list of matFiles
    if ~isfile(matFilePath)
        fprintf('MATLAB data file not found for subject: %s\n', subjectID);
        continue;
    end

    % Load the MATLAB data
    load_data_MAT = load(matFilePath);
    data_MAT = load_data_MAT.EXP.data; % Extracting the table from the structure

    % Preprocess the MEG data
    cfg = [];
    cfg.dataset = confile;
    cfg.coilaccuracy = 0;
    data_MEG = ft_preprocessing(cfg);

    %% Output the number of triggers on channel 227 for preview event
    % Number of triggers should corespond to the number of trials in the
    % experiment

    % Extract the trigger channel (channel 227)
    previewTrigger = data_MEG.trial{1}(227, :);

    % Define a threshold to detect transitions
    threshold = (max(previewTrigger) + min(previewTrigger)) / 2;

    % Detect transitions from low to high
    transitions = diff(previewTrigger > threshold);

    % Count the number of positive transitions (indicating trigger onsets)
    num_triggers = sum(transitions == 1);

    trigger_indices = find(transitions == 1);


    % Output the number of triggers
    fprintf('Number of triggers: %d\n', num_triggers);

    % figure
    % plot(previewTrigger)

    %% Deifne trials and segment the data

    cfg = [];
    cfg.dataset  = confile;
    cfg.trialdef.eventvalue = 1; % placeholder for the conditions
    cfg.trialdef.prestim    = 1; % 1s before stimulus onset
    cfg.trialdef.poststim   = 0.5; % 1s after stimulus onset
    cfg.trialfun = 'ft_trialfun_general';
    cfg.trialdef.chanindx = 227;
    cfg.trialdef.threshold = threshold;
    cfg.trialdef.eventtype = 'combined_binary_trigger'; % this will be the type of the event if combinebinary = true
    cfg.trialdef.combinebinary = 1;
    cfg = ft_definetrial(cfg);

    if size(cfg.trl, 1) > 300
        cfg.trl = cfg.trl(1:300, :);
    end
    % Update the fourth column (eventvalue placeholder) of cfg.trl with the conditions
    cfg.trl(:, 4) = data_MAT.crowding;

    % Segment the data based on the defined trials
    segmented_data = ft_preprocessing(cfg);

    %% Cleaning: Filtering the data using bandpass and notch filter

    % Band-pass filter the data
    cfg = [];
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [4 40]; % Band-pass filter range
    cfg.bpfiltord = 4;    % Filter order
    data_bp = ft_preprocessing(cfg, segmented_data);

    % Notch filter the data at 50 Hz
    cfg = [];
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [49 51]; % Notch filter range
    data_filtered = ft_preprocessing(cfg, data_bp);


    %% Cleaning: Inspect and exclude trials for artefacts

    % Identify the MEG channels (assuming MEG channels are 1 to 224)
    meg_channels = 1:208;

    % Use ft_databrowser for interactive visualization excluding trigger channels
    cfg_reject = [];
    cfg_reject.method   = 'summary';
    cfg_reject.ylim = [-1e-12 1e-12];  % Set appropriate ylim for MEG channels
    cfg_reject.megscale = 1;  % Scaling factor for MEG channels
    cfg_reject.channel = meg_channels;  % Include only MEG channels
    segmented_data_clean = ft_rejectvisual(cfg_reject, data_filtered);

    segmented_data_all{k} = segmented_data_clean;


    %% Cleaning: ICA



    %% separate the trials into the conditions

    cfg=[];

    cfg.trials = (segmented_data_clean.trialinfo==1);
    dataCrowding1 = ft_selectdata(cfg, segmented_data_clean);

    cfg.trials = (segmented_data_clean.trialinfo==2);
    dataCrowding2 = ft_selectdata(cfg, segmented_data_clean);

    cfg.trials = (segmented_data_clean.trialinfo==3);
    dataCrowding3 = ft_selectdata(cfg, segmented_data_clean);

    % Visualize the first trial of channel 20
    % figure
    % plot(dataCrowding1.time{1}, dataCrowding1.trial{1}(20,:))


    %% Timelockanalysis

    cfg = [];
    avgCWDG1 = ft_timelockanalysis(cfg, dataCrowding1);
    avgCWDG2 = ft_timelockanalysis(cfg, dataCrowding2);
    avgCWDG3 = ft_timelockanalysis(cfg, dataCrowding3);

    % Save the results for the current subject
    subjectResultsFolder = fullfile(resultsFolder, subjectID);
    if ~exist(subjectResultsFolder, 'dir')
        mkdir(subjectResultsFolder);
    end

    save(fullfile(subjectResultsFolder, sprintf('%s_avgCWDG1.mat', subjectID)), 'avgCWDG1');
    save(fullfile(subjectResultsFolder, sprintf('%s_avgCWDG2.mat', subjectID)), 'avgCWDG2');
    save(fullfile(subjectResultsFolder, sprintf('%s_avgCWDG3.mat', subjectID)), 'avgCWDG3');


    % Plot all ERPs in sensor space
    cfg = [];
    cfg.showlabels = 'no';
    cfg.fontsize = 6;
    %cfg.layout = 'CTF151_helmet.mat';
    cfg.baseline = [-0.2 0];
    cfg.xlim = [-0.2 1.0];
    cfg.ylim = [-3e-13 3e-13];
    ft_multiplotER(cfg, avgCWDG1, avgCWDG2, avgCWDG3);
    title(sprintf('ERP Activity in sensor space: %s', subjectID), 'Interpreter', 'none');

    saveas(gcf, fullfile(subjectResultsFolder, sprintf('%s_ERP_Sensor_Space.png', subjectID)));


    % Plot all ERPs from a specific channel
    cfg = [];
    cfg.xlim = [-0.2 1.0];
    cfg.ylim = [-1e-13 3e-13];
    cfg.channel = 'AG001';
    ft_singleplotER(cfg, avgCWDG1, avgCWDG2, avgCWDG3);
    title(sprintf('ERP Activity of Subject: %s', subjectID), 'Interpreter', 'none');

    saveas(gcf, fullfile(subjectResultsFolder, sprintf('%s_ERP.png', subjectID)));

    % Topographic plot of the ERP
    cfg = [];
    cfg.xlim =  [0.3 0.5];
    cfg.colorbar = 'yes';
    %cfg.layout = 'CTF151_helmet.mat';
    ft_topoplotER(cfg, avgCWDG1);
    title(sprintf('Topographic plot of condition 1: %s', subjectID), 'Interpreter', 'none');
    saveas(gcf, fullfile(subjectResultsFolder, sprintf('%s_Topographic_plot_cwdg_1.png', subjectID)));



    cfg = [];
    cfg.xlim = [0.3 0.5];
    cfg.colorbar = 'yes';
    %cfg.layout = 'CTF151_helmet.mat';
    ft_topoplotER(cfg, avgCWDG2);
    title(sprintf('Topographic plot of condition 2: %s', subjectID), 'Interpreter', 'none');
    saveas(gcf, fullfile(subjectResultsFolder, sprintf('%s_Topographic_plot_cwdg_2.png', subjectID)));



    cfg = [];
    cfg.xlim = [0.3 0.5];
    cfg.colorbar = 'yes';
    %cfg.layout = 'CTF151_helmet.mat';
    ft_topoplotER(cfg, avgCWDG3);
    title(sprintf('Topographic plot of condition 3: %s', subjectID), 'Interpreter', 'none');
    saveas(gcf, fullfile(subjectResultsFolder, sprintf('%s_Topographic_plot_cwdg_3.png', subjectID)));




end

