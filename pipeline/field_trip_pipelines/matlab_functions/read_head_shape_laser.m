function shape = read_head_shape_laser(filename_surface, filename_stylus)
%% Function to produce FieldTrip headshape structure from Laser scanner and stylus points 
%% written by Osama Abdullah 5/31/2024
% assumming the filename_stylus and HPI marker coils follow the order
% described here https://meg-pipeline.readthedocs.io/en/latest/2-operationprotocol/operationprotocol.html

surface = load(filename_surface);
fid = load(filename_stylus);

shape.pos = surface;
shape.fid.label = {'NAS';'LT';'RT';'LPA';'RPA';'CF';'LF';'RF'};
shape.fid.pos = fid; % assume order taken from https://meg-pipeline.readthedocs.io/en/latest/2-operationprotocol/operationprotocol.html
shape.label = [];
% shape.coordsys = 'neuromag';
% shape.unit = 'cm';
shape
return
