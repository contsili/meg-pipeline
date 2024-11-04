% Coregister 5 HPI coils from mrk file with 8 points from polhemus laser scan

%% configure paths

MEG_DATA_FOLDER = getenv('MEG_DATA');

% Set path to KIT .con file of sub-03
DATASET_PATH = [MEG_DATA_FOLDER,'visual_crowding_preview'];

% This needs fixing to save properly
SAVE_PATH = [MEG_DATA_FOLDER, 'visual_crowding_preview'];

%% MEGFILES, POLHEMUS_FILES, MRK_FILES

% Get a list of all MEG data files
MEGFILES = dir(fullfile(DATASET_PATH, 'sub-*-vcp','meg-kit', 'sub-*-vcp-analysis_NR.con'));

% Get a list of all the Polhemus files
POLHEMUS_FILES = dir(fullfile(DATASET_PATH, 'sub-*-vcp','digitizer', 'sub-*-scan*.txt'));

% Get a list of all the .mrk files
MRK_FILES = dir(fullfile(DATASET_PATH, 'sub-*-vcp','meg-kit', '*.mrk'));

for k = 1

    % Get the current MEG data file name   
    confile = fullfile(MEGFILES(k).folder, MEGFILES(k).name);

    laser_stylus = fullfile(POLHEMUS_FILES(k).folder, POLHEMUS_FILES(k).name);
    laser_surf = fullfile(POLHEMUS_FILES(k+1).folder, POLHEMUS_FILES(k+1).name);

    mrkfile1 = fullfile(MRK_FILES(k).folder, MRK_FILES(k).name);
    mrkfile2 = fullfile(MRK_FILES(k+1).folder, MRK_FILES(k+1).name);

end

% Display the paths to ensure they are correct
disp(['Confile Path: ', confile]);
disp(['Laser Surface Path: ', laser_surf]);
disp(['Laser Points Path: ', laser_stylus]);


%% load lasershape

addpath C:\Users\user\Documents\GitHub\meg-pipeline\pipeline\field_trip_pipelines\matlab_functions
lasershape   = read_head_shape_laser(laser_surf, laser_stylus);
lasershape   = ft_convert_units(lasershape, 'mm');

% Keep only x, y, z (not dx, dy, dz)
lasershape.fid.pos = lasershape.fid.pos(:,1:3);

%% Define 'ctf' coordsys to the lasershape

laser2ctf = ft_headcoordinates(lasershape.fid.pos(1,:), lasershape.fid.pos(4,:), lasershape.fid.pos(5,:),'ctf'); % 6: NAS (or 1: nas??), 4: LPA 5"RPA

% Apply the transformation to the laser head scan and fiducials
lasershape = ft_transform_geometry(laser2ctf, lasershape);

% Plot to inspect the geometrical object and ensure that this obeys the CTF references
lasershape = ft_determine_coordsys(lasershape, 'interactive', 'no'); % it is ALS and is a coordsys defined my the fiducials

lasershape.coordsys = 'ctf';


%% load mrk

mrk1 = ft_read_headshape(mrkfile1);
mrk1 = ft_convert_units(mrk1, lasershape.unit);
mrk2 = ft_read_headshape(mrkfile2);
mrk2 = ft_convert_units(mrk2, lasershape.unit);

% Define the average marker positions, mrk1 correspond to HPI coils at the
% beginning and end of the experiment
mrka = mrk1;
mrka.fid.pos = (mrk1.fid.pos+ mrk2.fid.pos)/2;

%% plot mrk and lasershape points

% Plotting a 3D scatter plot of the head scan points and the coils before
% transforming 
scatter3(lasershape.fid.pos(:,1), lasershape.fid.pos(:,2), lasershape.fid.pos(:,3), 'filled'); % plot of the head scan points in 3D
hold on
scatter3(mrka.fid.pos(:, 1), mrka.fid.pos(:, 2), mrka.fid.pos(:, 3), 'filled') % plot of the coils 

% Adding labels to the coil points
for i = 1:length(mrka.fid.label)
    text(mrka.fid.pos(i,1), mrka.fid.pos(i, 2), mrka.fid.pos(i, 3), mrka.fid.label{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end

% Adding labels to the headshape points
for i = 1:length(lasershape.fid.label)
    text(lasershape.fid.pos(i,1), lasershape.fid.pos(i,2), lasershape.fid.pos(i,3), lasershape.fid.label{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
end

%% no coreg
% read sensors from confile
grad = ft_read_sens(confile, 'senstype', 'meg');
grad_mm_way1 = ft_convert_units(grad, lasershape.unit);

% check if HPI coils and laserscan are coregistered
figure;
ft_plot_sens(grad_mm_way1)
hold on
ft_plot_headshape(lasershape)

%% Coregister mrk with lasershape

%% way1: bring both mrk and lasershape to 'ctf' coordsys: NOTE THAT THE YOKOGAWA HELMET IS NOT DEFINED BASED ON THE MRK FID POINTS BUT BASED ON DEWAR POINTS THAT I DO NOT KNOW. SO TRANSFORMING THE FID TO 'CTF' COORDSYS ALIGNS THE FID POINTS IN MRK AND LASERSCAN - BUT IT DOES NOT ALIGN THE COORDSYS OF LASERSCAN (DEFINED BASED ON THE 3 FID) WITH THE COORDSYS OF THE SENSORS WHICH IS NOT DEFINED BASED ON THE 3 FID.  

% "black coil" is Number 1 (nas) in the .mrk which correspond to 6 (CF) in the stylus points
% "red coil" is number 2 (lpa) in the .mrk which correspond to 4 (LPA) in the stylus
% "yellow coil" is number 3 (rpa) in the .mrk which correspond to 5 (RPA) in the stylus
% "white coil" is number 4 (marker 4) in the .mrk which correspond to 7 (LF) in the stylus
% "blue coil" is number 5 (marker 5) in the .mrk which correspond to 8 (RF) in the stylus

t1 = ft_headcoordinates(mrka.fid.pos(1,:), mrka.fid.pos(2,:), mrka.fid.pos(3,:), 'ctf'); % mrk2ctf

% read sensors from confile
grad = ft_read_sens(confile, 'senstype', 'meg');
grad_transf1 = ft_transform_geometry(t1, grad);
grad_mm_way1 = ft_convert_units(grad_transf1, lasershape.unit);

% check if HPI coils and laserscan are coregistered
figure;
ft_plot_sens(grad_mm_way1)
hold on
ft_plot_headshape(lasershape)

%% (way2: bring mrk to the laserscan coordsys)

t1 = ft_headcoordinates(mrka.fid.pos(1,:), mrka.fid.pos(2,:), mrka.fid.pos(3,:), 'ctf'); % mrk2ctf
t2 = ft_headcoordinates(lasershape.fid.pos(1,:), lasershape.fid.pos(4,:), lasershape.fid.pos(5,:),'ctf'); % 6: NAS, 4: LPA 5:RPA

transform_mrk2laser = t2\t1;

grad    = ft_read_sens(confile,'senstype','meg'); % no .fid field
grad_mm = ft_convert_units(grad, lasershape.unit);

% before coreg
figure;
ft_plot_sens(grad_mm)
hold on
ft_plot_headshape(lasershape)
ft_plot_axes(grad_mm)

% is the coordsys of the MEG sensors defined based on the fiducial in the mrk file?
figure;
ft_plot_sens(grad_mm)
hold on
scatter3(mrka.fid.pos(:, 1), mrka.fid.pos(:, 2), mrka.fid.pos(:, 3), 'filled') % plot of the coils 
for i = 1:length(mrka.fid.label)
    text(mrka.fid.pos(i,1), mrka.fid.pos(i, 2), mrka.fid.pos(i, 3), mrka.fid.label{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end
ft_plot_axes(grad_mm)
ft_plot_axes(lasershape)

% ans.: NO!

%
grad_transf2 = ft_transform_geometry(transform_mrk2laser, grad);
grad_mm_way2 = ft_convert_units(grad_transf2, lasershape.unit);


% check if HPI coils and laserscan are coregistered
figure;
ft_plot_sens(grad_mm_way2)
hold on
ft_plot_headshape(lasershape)

% conclusion: not good coreg



%% way3: ft_electroderealign - coreg 3 points with 3 other

cd C:\Users\user\Documents\MATLAB\matlab_toolboxes\fieldtrip\fieldtrip\compat\obsolete

grad_mm.fid.pos(1,:) = mrka.fid.pos(1,:);     % location of the nose
grad_mm.fid.pos(2,:) = mrka.fid.pos(2,:);   % location of the left ear
grad_mm.fid.pos(3,:) = mrka.fid.pos(3,:);  % location of the right ear
grad_mm.fid.label    = {'NAS', 'LPA', 'RPA'};

lasershape.fid.pos = lasershape.fid.pos([1,4:5],:);
lasershape.fid.label = lasershape.fid.label([1,4:5],:);

% the configuration for FT_SENSORREALIGN should specify the three fiducials in
% head coordinates as obtained from the aligned MRI using FT_SOURCEPLOT
cfg = [];
cfg.method = 'template';
cfg.target  = lasershape.fid;
cfg.elec    = grad_mm.fid;
grad_aligned = ft_electroderealign(cfg);

grad_mm_way3 = ft_transform_geometry(grad_aligned.rigidbody, grad_mm, 'rigidbody');

figure;
ft_plot_sens(grad_mm_way3)
hold on
ft_plot_headshape(lasershape)

%% way4: interactive

grad_mm.fid.pos(1,:) = mrka.fid.pos(1,:);     % location of the nose
grad_mm.fid.pos(2,:) = mrka.fid.pos(2,:);   % location of the left ear
grad_mm.fid.pos(3,:) = mrka.fid.pos(3,:);  % location of the right ear
grad_mm.fid.label    = {'NAS', 'LPA', 'RPA'};

%

cfg=[];
cfg.individual.grad = grad_mm;
cfg.template.headshape = lasershape;
[cfg] = ft_interactiverealign(cfg)







%% check coregistration: plot mrk and lasershape points (way1)

t11 = t1(1:3,:);
TR = t11(:,1:3);
TT = t11(:,4);

transformed_coils = TR * mrka.fid.pos' + TT;

% extracting the coordinates of the transformed coils 
transformed_coils_x = transformed_coils(1,:);
transformed_coils_y = transformed_coils(2,:);
transformed_coils_z = transformed_coils(3,:);

% plot the transformed coils and the headscan/stylus points for
% confirmation
figure
scatter3(transformed_coils(1,:), transformed_coils(2,:),transformed_coils(3,:), 'filled') % plot of the transformed coils
hold on
scatter3(lasershape.fid.pos(:,1), lasershape.fid.pos(:,2), lasershape.fid.pos(:,3), 'filled'); % plot of the head scan points in 3D

% Adding labels to the headshape points
for i = 1:length(lasershape.fid.label)
    text(lasershape.fid.pos(i,1), lasershape.fid.pos(i,2), lasershape.fid.pos(i,3), lasershape.fid.label{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
end
% Add labels to the headshape points (assuming lasershape.fid.label exists)
for i = 1:length(mrka.fid.label)
    text(transformed_coils_x(i), transformed_coils_y(i), transformed_coils_z(i), mrka.fid.label{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
end

% Conclusion: RPA/LPA not well coregistered
%% check coregistration: plot mrk and lasershape points (way2)

transform_mrk2laser1 = transform_mrk2laser(1:3,:);
TR = transform_mrk2laser1(:,1:3);
TT = transform_mrk2laser1(:,4);

transformed_coils = TR * mrka.fid.pos' + TT;

% extracting the coordinates of the transformed coils 
transformed_coils_x = transformed_coils(1,:);
transformed_coils_y = transformed_coils(2,:);
transformed_coils_z = transformed_coils(3,:);

% plot the transformed coils and the headscan/stylus points for
% confirmation
figure
scatter3(transformed_coils(1,:), transformed_coils(2,:),transformed_coils(3,:), 'filled') % plot of the transformed coils
hold on
scatter3(lasershape.fid.pos(:,1), lasershape.fid.pos(:,2), lasershape.fid.pos(:,3), 'filled'); % plot of the head scan points in 3D

% Adding labels to the headshape points
for i = 1:length(lasershape.fid.label)
    text(lasershape.fid.pos(i,1), lasershape.fid.pos(i,2), lasershape.fid.pos(i,3), lasershape.fid.label{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
end
% Add labels to the headshape points (assuming lasershape.fid.label exists)
for i = 1:length(mrka.fid.label)
    text(transformed_coils_x(i), transformed_coils_y(i), transformed_coils_z(i), mrka.fid.label{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
end

% Conclusion: RPA/LPA not well coregistered