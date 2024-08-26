
% Load the AAL atlas
Atlas = ft_read_atlas('C:\Users\tasni\Desktop\Masterarbeit\atlas\aal\ROI_MNI_V4.nii');

% Load the MNI template MRI
mri = ft_read_mri('C:\Users\tasni\Desktop\Masterarbeit\anatomy\single_subj_T1.nii');

% Align MRI with MEG fiducials
cfg = [];
cfg.method = 'fiducial';
cfg.coordsys = 'neuromag';
cfg.fiducial.nas = lasershape.fid.pos(6,:); % nasion (CF) in the lasershape corresponds to index 6
cfg.fiducial.lpa = lasershape.fid.pos(4,:); % left preauricular point (LPA) in the lasershape corresponds to index 4
cfg.fiducial.rpa = lasershape.fid.pos(5,:); % right preauricular point (RPA) in the lasershape corresponds to index 5
cfg.target = mri;
mri_realigned = ft_volumerealign(cfg,mri);


%%

   % Segment the MRI
    cfg = [];
    cfg.output = {'brain', 'skull', 'scalp'};
    segmentedmri = ft_volumesegment(cfg, mri_realigned);

    % Create a mesh of the brain
    cfg = [];
    cfg.method = 'projectmesh';
    cfg.tissue = 'brain';
    cfg.numvertices = 10000;
    mesh = ft_prepare_mesh(cfg, segmentedmri);

    % Create the head model using the mesh
    cfg = [];
    cfg.method = 'singleshell';
    cfg.mesh = mesh;
    headmodel = ft_prepare_headmodel(cfg, mesh);

    % Visualize the head model
    figure;
    ft_plot_mesh(headmodel.bnd(1), 'facecolor', 'cortex', 'edgecolor', 'none');
    camlight;
    lighting gouraud;

    % Overlay atlas labels on MRI
    cfg = [];
    cfg.interpmethod = 'nearest';
    cfg.parameter = 'tissue';
    mri_resliced = ft_volumereslice(cfg, mri_realigned);

    % Plot the MRI with atlas labels
    figure;
    cfg = [];
    cfg.method = 'slice';
    cfg.funparameter = 'tissue';
    cfg.funcolorlim = [1 max(Atlas.tissue(:))];
    ft_sourceplot(cfg, Atlas);
    title('Brainnetome Atlas Labels on MRI');

%%

% Define source model using the atlas
cfg = [];
cfg.mri = mri_realigned;  % Use the realigned MRI
cfg.resolution = 1;       % Resolution in cm
cfg.atlas = Atlas;        % The atlas for source model
sourcemodel = ft_prepare_sourcemodel(cfg);

% Ensure the sensor information is correct
cfg = [];
cfg.dataset = 'C:\Users\tasni\Desktop\Masterarbeit\Paradigm\previw and crowding\EXP DATA\MEG data\Sub_004_01_vcp.con'; % Path to continuous MEG data (could be the same as segmented data if continuous is not available)
meg_continuous = ft_read_sens(cfg.dataset);


% Extract the channel labels from the segmented MEG data and the continuous data
segmented_labels = segmented_data_clean.label;
continuous_labels = meg_continuous.label;

% Find the common channels between the segmented MEG data and the continuous MEG data
common_channels = intersect(segmented_labels, continuous_labels);

% Redefine the data to include only the common channels
cfg = [];
cfg.channel = common_channels;
segmented_data_clean = ft_selectdata(cfg, segmented_data_clean);

% Ensure the source model labels match the common channels
sourcemodel.label = common_channels;

% Adjust the sensor information to include only the common channels
meg_sens = ft_read_sens(cfg.dataset);
meg_sens.label = common_channels;
meg_sens.chanpos = meg_sens.chanpos(ismember(meg_sens.label, common_channels), :);
meg_sens.chanori = meg_sens.chanori(ismember(meg_sens.label, common_channels), :);

% Ensure the sensor structure is consistent
meg_sens.label = common_channels;
meg_sens.chanpos = meg_sens.chanpos(1:length(common_channels), :);
meg_sens.chanori = meg_sens.chanori(1:length(common_channels), :);


% Compute leadfield matrix using MEG sensor information
cfg = [];
cfg.headmodel = headmodel;
cfg.sourcemodel = sourcemodel;
cfg.grad = meg_sens;  % Use the sensor information from the continuous MEG data
cfg.channel = common_channels;  % Use only the common channels
cfg.grid.unit = 'mm';  % Ensure the units are consistent
leadfield = ft_prepare_leadfield(cfg, segmented_data_clean);


% Perform source localization using segmented MEG data
cfg = [];
cfg.method = 'lcmv';
cfg.grid = leadfield;
cfg.headmodel = headmodel;
cfg.grad = meg_sens;
cfg.channel = common_channels;  % Use only the common channels
cfg.latency = [0 0.5]; % Time window for source localization
source = ft_sourceanalysis(cfg, segmented_data_clean);

% Visualize results
cfg = [];
cfg.parameter = 'pow'; % Power parameter for visualization
cfg.atlas = Atlas;
ft_sourceplot(cfg, source);
