% This script was made by Mikkel Vinding, based on code courtesy of Bushra Riaz Syeda
% 
% if ispc
%     addpath C:\Users\Mikkel\Documents\MATLAB
%     [dirs, sub_info, lh_subs] = PD_proj_setup_WIN('tap');
%     fs_subject_dir  = 'Z:\PD_motor\fs_subjects_dir';
%     dirs.mriDir     = 'Z:\PD_motor\MRI';
%     dirs.transDir   = 'Z:\PD_motor\tap\trans_files';
%     src_path        = 'Z:\PD_motor\tap\mri';
% else
%     addpath /home/mikkel/PD_motor/global_scripts
%     [dirs, sub_info, lh_subs] = PD_proj_setup('tap');
%     fs_subject_dir  = '/home/mikkel/PD_motor/fs_subjects_dir';
%     dirs.mriDir     = '/home/mikkel/PD_motor/MRI';
%     dirs.transDir   = '/home/mikkel/PD_motor/tap/trans_files';
%     src_path        = '/home/mikkel/PD_motor/tap/mri';
% end
% 
% %% Overwrite old files?
% overwrite = 0;
% 
% %% Filenames and paths [CLEAN UP]
% % [ LOOP HERE ]
% sub='0313';
% 
% volname = 'Z:\PD_motor\tap\meg_data\0313\vol.fif';
% 
% meg_path    = fullfile(dirs.megDir,sub);    % Sub specific path to MEG data
% mriDir      = fullfile(dirs.megDir,sub);    % Sub specific path to

% savemrito='/home/mikkel/PD_motor/tap/mri';
% mkdir (savemrito);

% % It is important that you use T1.mgz instead of orig.mgz as T1.mgz is normalized to [255,255,255] dimension
% mridata     = fullfile(fs_subject_dir, sub, '/mri/T1.mgz');
% transfname  = fullfile('']);
% dataset     = fullfile(meg_path, [sub, '_tap_1-ica_raw.fif']);    % for sensor location and definition
% src_fname   = fullfile(src_path,[sub, '-ico4-src.fif']);
clear all
close all
clc
% It is important that you use T1.mgz instead of orig.mgz as T1.mgz is normalized to [255,255,255] dimension
mridata     = fullfile('/Users/oa22/Desktop/toolkit2024/practice/meg_kit_oddball/sub-003/mri/T1.mgz');
transfname  = fullfile('/Users/oa22/Desktop/toolkit2024/practice/meg_kit_oddball/sub-03-raw-kit-trans.fif');
dataset     = fullfile('/Users/oa22/Desktop/toolkit2024/practice/meg_kit_oddball/sub-03-raw-kit-raw.fif');    % for sensor location and definition
dataset_con     = fullfile('/Users/oa22/Desktop/toolkit2024/practice/meg_kit_oddball/sub-03-raw-kit.con');    % for sensor location and definition

volname   = fullfile('/Users/oa22/Desktop/toolkit2024/practice/meg_kit_oddball/sub-003/bem/sub-003-head.fif');
src_fname = 'sub-003-ico4-src.fif'

% Define outputs
meg_path = '/Users/oa22/Desktop/toolkit2024/practice/meg_kit_oddball'
src_outFname = fullfile(meg_path, 'source_surf.mat');
hdm_outFname = fullfile(meg_path, 'headmodel_surf.mat');



%% Read transformation (head -> MRI)
trans_orig = fiff_read_coord_trans(transfname);
% In FieldTrip every thing is in head cordinate therefore in next line we are inverting the transformation
trans.trans=inv(trans_orig.trans);

%% Read MRI (does not work on Win PC)
mri_orig = ft_read_mri(mridata);
mri_orig = ft_convert_units(mri_orig, 'cm');

%% The following lines are importing MNE coregistration to FieldTrip
trans_orig.trans(1:3,4) = trans_orig.trans(1:3,4)*100;  % translation: meters to cm
ttt= mri_orig.hdr.tkrvox2ras;                           % This is for FS T1.mgz!
ttt(1:3,:)=ttt(1:3,:)/10;

mri_orig.transform = inv(trans_orig.trans)*(ttt);
mri_orig = ft_determine_coordsys(mri_orig, 'interactive', 'no');
mri_orig.coordsys='ctf';

%% Read sensor and headpoints
grad    = ft_read_sens(dataset_con, 'senstype', 'meg');
grad    = ft_convert_units(grad, 'cm');
grad = ft_determine_coordsys(grad, 'interactive', 'no');
grad.coordsys='ctf';

%     ft_datatype_sens(grad)
shape   = ft_read_headshape(dataset);
shape   = ft_convert_units(shape, 'cm');

laser_surf = 'sub-03-basic-surface.txt'
laser_points = 'sub-03-stylus.txt'
shape2   = read_head_shape_laser(laser_surf,laser_points);
shape2   = ft_convert_units(shape2, 'cm');

% Plot for inspection
close all
h=figure;
ft_plot_headshape(shape)
ft_plot_headshape(shape2, 'vertexcolor', 'black')
ft_plot_sens(grad, 'style', '*g');
view([1 0 0])
title('MEG headshape and sensors', 'FontSize', 13)

%% Read potato
vol = ft_read_headmodel(volname);
headmodel = vol;
headmodel = ft_convert_units(headmodel,'m'); % Make sure units is in meters for transform

% Transform
headmodel_pos=headmodel.bnd.pos;
temp_vect=headmodel_pos;
temp_vect(:,4)=1;
headmodel_pos=temp_vect*trans.trans';
headmodel.pos=headmodel_pos(:,1:3);
headmodel = ft_convert_units(headmodel, 'cm');

%% Reading FreeSurfer Source Space
src = ft_read_headshape(src_fname, 'format', 'mne_source');

% Transform
temp_vect=src.pos;
temp_vect(:,4)=1;
src_pos=temp_vect*trans.trans';
src_pos=src_pos(:,1:3);

% Make source model
sourcemodel = src;
sourcemodel.pos = src_pos;
sourcemodel = ft_convert_units(sourcemodel, 'cm');
sourcemodel.inside = ones(length(sourcemodel.pos),1);

%% Check coregistration
cfg = [];
mri_orig = ft_determine_coordsys(mri_orig, 'interactive', 'no');
mri_orig.coordsys='ctf';
hold on; % add the subsequent objects to the same figure
ft_plot_headshape(shape);
ft_plot_mesh(headmodel, 'facealpha',0.25,'edgecolor', 'b','facecolor','b')
ft_plot_sens(grad, 'style', '*g','edgecolor','cyan');
ft_plot_mesh(sourcemodel, 'edgecolor','k')
view ([90 0])
title('MEG coregistration', 'FontSize', 13)

%% Save stuff
disp('Saving...');
save(src_outFname, 'sourcemodel', '-v7.3');
save(hdm_outFname, 'headmodel', '-v7.3');
disp('DONE')

%% get skull

% Prepare the mesh for the head shape (scalp)

seghead=ft_read_headshape({'/Users/oa22/Desktop/toolkit2024/practice/meg_kit_oddball/sub-003/surf/lh.seghead'}, 'unit', 'cm')


% Visualize the head shape
figure, ft_plot_mesh(seghead);

%% 
cfg=[]
cfg.mri  = mri_aligned
cfg.grad = grad
% cfg.headshape = shape
% cfg.headshape         =  seghead
ft_geometryplot(cfg)



mri_orig = ft_read_mri(mridata);
mri_orig = ft_convert_units(mri_orig, 'cm');
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'ctf';
mri_aligned = ft_volumerealign(cfg, mri_orig);
mri=mri_aligned
fid_pos = mri.cfg.fiducial;
fid_vox = [fid_pos.nas; fid_pos.lpa; fid_pos.rpa];
fid_mri = ft_warp_apply(mri.transform, fid_vox, 'homogeneous');

% Read HPIs & anatomical landmarks in MEG coordinate system from .con, .ave, or .mrk files
headshape = ft_read_headshape(dataset);
headshape = ft_convert_units(headshape, 'mm');

% HPIs (marker coils)
coil_pos = headshape.fid.pos(end-4:end,:);
coil_label = headshape.fid.label(end-4:end,:);

% Anatomical landmarks
fid_pos = headshape.fid.pos(1:3,:);
fid_label = headshape.fid.label(1:3,:);

headshape.fid.label
headshape.fid.pos   


%%
% % cfg=[]
% % cfg.method === headshape
% % cfg.XX = shape
% % ft_volumerealign(cfg, mri)