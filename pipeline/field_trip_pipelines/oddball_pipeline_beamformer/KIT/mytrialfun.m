function [trl, event] = mytrialfun(cfg)

% read the header information (including the sampling rate) and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset, 'chanindx', 225, 'threshold', 1, 'detectflank', 'up');

% search for "trigger" events according to 'trigchannel' defined outside the function
value  = [event(find(strcmp(cfg.trialdef.trigchannel, {event.type}))).value]';
sample = [event(find(strcmp(cfg.trialdef.trigchannel, {event.type}))).sample]';

% creating your own trialdefinition based upon the events
trl = [];
for j = 1:length(value);
  trlbegin = sample(j) - round(cfg.trialdef.prestim  * hdr.Fs);
  trlend   = sample(j) + round(cfg.trialdef.poststim * hdr.Fs);
  offset   = -round(cfg.trialdef.prestim  * hdr.Fs);
  newtrl   = [ trlbegin trlend offset];
  trl      = [ trl ; newtrl];
end
end