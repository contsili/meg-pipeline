
BOX_DIR = getenv('BOX_DIR');

confile         = fullfile([BOX_DIR,'oddball\sub-03\meg-kit\sub-03-raw-kit.con']); 


% load in the data
cfg              = [];
cfg.dataset      = confile;
cfg.coilaccuracy = 0;
data_all         = ft_preprocessing(cfg);


% 
cfg = [];
cfg.viewmode = 'vertical';
cfg.blocksize = 300; % seconds
ft_databrowser(cfg, data_all);