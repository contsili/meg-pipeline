%% This script uses beamformer technique for source localisation


Atlas = ft_read_atlas('C:\Users\tasni\Desktop\Masterarbeit\atlas\aal\ROI_MNI_V4.nii');

% Load the MNI template MRI
mri = ft_read_mri('C:\Users\tasni\Desktop\Masterarbeit\anatomy\Subject01.mri');


cfg = [];
cfg.method = 'headshape';
cfg.headshape = headshape;  % This is the aligned headshape struct
cfg.coordsys = 'ctf';       % Ensure consistency with your MEG data's coordinate system
% Align the MRI to the headshape
mri_aligned = ft_volumerealign(cfg, mri);


%%
% Is this the warping??? 

ft_path = fileparts(which('ft_defaults'));  % Get FieldTrip path
template_file = fullfile(ft_path, 'template', 'anatomy', 'single_subj_T1.nii');  % Path to template file

cfg = [];
cfg.template = template_file;  % Use the loaded MRI structure as the template
cfg.nonlinear = 'yes';
cfg.spmversion = 'spm12';
mri_warped = ft_volumenormalise(cfg, mri_aligned);  % Normalize your aligned MRI to this template

ft_sourceplot([], mri_warped);  % Check the warped MRI


%% segmentation MRI
cfg           = [];
cfg.output    = {'brain', 'skull', 'scalp'};
segmentedmri  = ft_volumesegment(cfg, mri_aligned);

cfg = [];
cfg.method='singleshell';
mriskullmodel = ft_prepare_headmodel(cfg, segmentedmri);



cfg = [];
cfg.tissue      = {'brain', 'skull', 'scalp'};
cfg.numvertices = [3000 2000 1000];
mesh = ft_prepare_mesh(cfg, segmentedmri);

cfg = [];
%   cfg.elec              = structure, see FT_READ_SENS
   cfg.grad              = grad;%structure, see FT_READ_SENS
%   cfg.opto              = structure, see FT_READ_SENS
  cfg.headshape         = mesh(3); %structure, see FT_READ_HEADSHAPE
  cfg.headmodel         = mriskullmodel; % structure, see FT_PREPARE_HEADMODEL and FT_READ_HEADMODEL
%   cfg.sourcemodel       = structure, see FT_PREPARE_SOURCEMODEL
%   cfg.dipole            = structure, see FT_DIPOLEFITTING
  cfg.mri               = mri_aligned;
  cfg.mesh              = headshape;
  cfg.axes              = 'yes';

ft_geometryplot(cfg)

ft_plot_mesh(mesh);  % Plot the MRI surface mesh
hold on;
plot3(headshape.pos(:,1), headshape.pos(:,2), headshape.pos(:,3), 'r.');  % Overlay laser scan points




%% Sourcemodel

% brain_mask = ft_volumesegment([], mri_aligned);  % Create a brain mask
brain_mask = segmentedmri.brain;
cfg = [];
cfg.grid.resolution = 10;  % Grid resolution in mm
cfg.grid.unit = 'mm';
cfg.mri = mri_aligned;  % Your aligned and resliced MRI data
cfg.headmodel = mriskullmodel;  % The head model representing the brain/skull
cfg.inwardshift = 5;  % Optional: Shift the grid inward
cfg.grid.tight = 'yes';  % Ensure the grid is tightly constrained to the brain
cfg.grid.inside = brain_mask(:);  % Restrict grid points to brain mask
sourcemodel = ft_prepare_sourcemodel(cfg);



inside_idx = find(sourcemodel.inside);
plot3(sourcemodel.pos(inside_idx, 1), sourcemodel.pos(inside_idx, 2), sourcemodel.pos(inside_idx, 3), 'o');
ft_plot_vol(mriskullmodel, 'facecolor', 'cortex', 'edgecolor', 'none');

%% Leadfield

cfg = [];
cfg.grid = sourcemodel;  % Use the refined sourcemodel
cfg.headmodel = mriskullmodel;  % The head model prepared earlier
cfg.grad = grad;  % MEG sensor positions
% TO TEST
cfg.resolution = 0.6;
cfg.sourcemodel.unit = 'cm';
% End to test
leadfield = ft_prepare_leadfield(cfg);


cfg = [];
cfg.method = 'lcmv';  % Beamforming method
cfg.sourcemodel = leadfield;  % Use the sourcemodel with leadfield
cfg.headmodel = mriskullmodel;  % Use the head model
cfg.lcmv.keepfilter = 'yes';  % Keep the spatial filter
cfg.lcmv.lambda = '5%';  % Regularization parameter % high means priority to prior; low means priority for measurement
cfg.lcmv.fixedori = 'yes';  % Use fixed orientation
source_lcmv = ft_sourceanalysis(cfg, dataCrowding1);  % 'meg_data' is your preprocessed MEG data


cfg = [];
cfg.parameter = 'pow';  % Power or any other parameter of interest
cfg.interpmethod = 'nearest';  % Interpolation method
cfg.atlas = Atlas;  % The AAL atlas you loaded earlier
%Interpolation computes for each voxel of the MRI the source activitz given
%the activitz at the points of the beamformer GRID
source_atlas = ft_sourceinterpolate(cfg, source_lcmv, Atlas);

cfg = [];
cfg.method = 'ortho';  % Orthogonal slices visualization
cfg.funparameter = 'pow';  % Parameter to plot
ft_sourceplot(cfg, source_lcmv);  % Visualize the source activity

cfg = [];
cfg.method = 'surface';
cfg.funparameter = 'pow';  % Parameter to plot
ft_sourceplot(cfg, source_atlas);  % Plot on the atlas
