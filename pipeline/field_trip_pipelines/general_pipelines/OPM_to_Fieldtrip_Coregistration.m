% MRI-MEG OPM coregisteration

clear all
close all
clc

%% Get input files

% Set an environment variable BOX_DIR to your BOX MEG data folder 
% (e.g., C:\Users\userID\Box\MEG\Data\)

BOX_DIR = getenv('BOX_DIR');
disp(BOX_DIR)

%Anatomical files
% It is important that you use T1.mgz instead of orig.mgz as T1.mgz is normalized to [255,255,255] dimension
mrifile         = fullfile([BOX_DIR,'oddball\sub-03\anat\sub-003\sub-003\mri\T1.mgz']);

%OPM MEG Data files
fiffile         = fullfile([BOX_DIR, 'oddball\sub-03\meg-opm\20240524_122045_sub-03_raw.fif'])

% Headscan files
laser_surf      = fullfile([BOX_DIR,'oddball\sub-03\meg-kit\sub-03-basic-surface.txt']);
%The cleaned stylus points removes the last three columns (dx, dx, dz) and
%keeps only x,y,z
laser_points    = [BOX_DIR, 'oddball\sub-03\meg-opm\sub-03-stylus-cleaned.txt'];


%% HPI coils referencing

% load in the data
cfg              = [];
cfg.dataset      = 'example2_magneticphantom_HPIplusdipoleset6_raw.fif';
cfg.coilaccuracy = 0;
data_all         = ft_preprocessing(cfg);





%% Read Laser headshape (points and fudicials)

% lasershape is a structure containing the head points and fiducials 
% in the order specified at 
% https://meg-pipeline.readthedocs.io/en/latest/2-operationprotocol/operationprotocol.html
lasershape   = read_head_shape_laser(laser_surf,laser_points);


% This function estimates the current SI unit based on a typical head
% lenght (20cm) and converts it to any SI unit
lasershape   = ft_convert_units(lasershape, 'cm');


% From Fieldtrip we quote the right questions to ask for coordinate systems
% What is the definition of the origin of the coordinate system, i.e. where is [0,0,0]?
% In which directions are the x-, y- and z-axis pointing, i.e. is +x towards the right or towards anterior?
% In what units are coordinates expressed, i.e. does the number “1” mean 1 meter, 1 centimeter or 1 millimeter?
% Is the geometry scaled to some template or atlas, or does it still match the individual’s head/brain size?

% The NAS (Nasion) is the first point in the stylus file
% The LPA (Left Pre Aucular) is the 4th point in the stylus file
% The RPA (Right Pre Aucular) is the 5th point in the stylus file

%Quoting from fieldtrip ft_headcoordinates docstring
% The CTF, 4D, YOKOGAWA and EEGLAB coordinate systems are defined as follows:
%   the origin is exactly between lpa and rpa
%   the X-axis goes towards nas
%   the Y-axis goes approximately towards lpa, orthogonal to X and in the plane spanned by the fiducials
%   the Z-axis goes approximately towards the vertex, orthogonal to X and Y

% Return the transformation matrix from the fiducials coordinate space to
% CTF
% The transformation matrix is a 4x4 matrix the first 3x3 matrix is the
% rotation matrix
% The last column is the translation vector
laser2ctf = ft_headcoordinates(lasershape.fid.pos(1,:),lasershape.fid.pos(4,:),lasershape.fid.pos(5,:),'ctf');

%Apply the transformation to the laser head scan and fiducials
lasershape = ft_transform_geometry(laser2ctf, lasershape)

%Plot to inspect the geometrical object and ensure that this obeys the CTF
%references
ft_determine_coordsys(lasershape, 'interactive', 'no')

% Deface the laser mesh under a certain plan (change the 140) Define the configuration for ft_defacemesh
planecut = 140;
cfg = [];
cfg.method    = 'plane';       % Use a plane for exclusion
cfg.translate = [0 planecut 0]; % A point on the plane (adjust z_value as needed)
cfg.rotate    = [0 0 0];       % Rotation vector, modify if the plane is not axis-aligned
cfg.selection = 'outside';     % Remove points below the plane

% Apply ft_defacemesh to remove points below the plane
mesh = ft_defacemesh(cfg, lasershape);

% Plot the resulting mesh to check the results
ft_plot_mesh(mesh);
lasershape = mesh


%% read in the data and enforce the units to be in 'mm'

headshape = ft_read_headshape('example1_head_markers.pos');

headshape = ft_convert_units(headshape, 'mm');

%% visualization, coordinate axes are initially ALS
figure
ft_plot_headshape(headshape)
ft_plot_axes(headshape)
view([-27 20])

headshape.coordsys = 'ctf';
headshape = ft_convert_coordsys(headshape, 'neuromag');  % this rotates it such that the X-axis points to the right

%% visualization, coordinate axes are now RAS
figure
ft_plot_headshape(headshape)
ft_plot_axes(headshape)
view([114 20])

%% select the reference points on the helmets, with their corresponding label
fid_measured = [];
fid_measured.pos(1,:) = headshape.pos(end-7,:);
fid_measured.pos(2,:) = headshape.pos(end-6,:);
fid_measured.pos(3,:) = headshape.pos(end-5,:);
fid_measured.pos(4,:) = headshape.pos(end-4,:);
fid_measured.pos(5,:) = headshape.pos(end-3,:);
fid_measured.pos(6,:) = headshape.pos(end-2,:);
fid_measured.pos(7,:) = headshape.pos(end-1,:);
fid_measured.pos(8,:) = headshape.pos(end-0,:);
fid_measured.label = {'A5', 'A6', 'A7', 'A8', 'A1', 'A2', 'A3', 'A4'};


[fid_measured.label, indx] = sort(fid_measured.label);
fid_measured.pos = fid_measured.pos(indx,:);

headshape.fid = fid_measured;

fieldlinebeta2 = ft_read_sens('fieldlinebeta2.mat'); % from fieldtrip/template/grad
fieldlinebeta2 = ft_convert_units(fieldlinebeta2, 'mm');
fid_helmet     = fieldlinebeta2.fid;

% dewar3.pos = dewar2.pos(7:end, :);
% dewar3.label = {'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8'};
% 
% 
% % Now we need to define the helmet coordinates based on the excel spreadsheet
% helmet.pos(1, :) = [55.703, 119.485, -0.749];
% helmet.pos(2, :) = [92.105, 59.254, -28.708];
% helmet.pos(3, :) = [102.325, 0.221, 16.345];
% helmet.pos(4, :) = [58.503, -94.717, -69.944];
% helmet.pos(5, :) = [-55.703, 119.485, -0.749];
% helmet.pos(6, :) = [-92.105, 59.254, -28.708];
% helmet.pos(7, :) = [-102.325, 0.221, 16.345];
% helmet.pos(8, :) = [-58.503, -94.717, -69.944];
% helmet.label = {'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8'};


% find the rigid body transform to the helmet coordinates as defined by the
% spreadsheet:
cfg = [];
cfg.method = 'template';
cfg.target = fid_helmet;
cfg.elec = fid_measured;
helmet2 = ft_electroderealign(cfg); 

% Check: We verify what is helmet2.chanpos is the same as helmet.pos.


%%

helmet3.pos = ft_warp_apply(helmet2.rigidbody, fid_measured.pos, 'rigidbody');
% helmet3.fid.pos = helmet2.elecpos;
% helmet3.fid.label = helmet2.label;
% helmet3.coordsys = 'neuromag';

figure;
% ft_plot_sens(helmet2, 'marker', 'o'); 
ft_plot_headshape(helmet3, 'vertexcolor', 'b');
ft_plot_sens(fieldlinebeta2, 'vertexcolor', 'm')
title('Coordinate system from 8 points in the helmet as given by FieldLine');
% looks good