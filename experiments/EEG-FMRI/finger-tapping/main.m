
% EEG-FMRI experiment for finger tapping
% fingertapping: tap each finger then rest
% Author: Hadi Zaatiti <hadi.zaatiti@nyu.edu>

clear all
close all

global parameters;
global screen;
global tc;
global isTerminationKeyPressed;
global resReport;
global totalTime;

% datapixx = 1 means w're actually listening for the scanner to send us a
% trigger
% datapixx = 0 means w're in demo mode
global datapixx;

Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'Verbosity', 0);

timingsReport = {};

clear map
map = struct('block',0,...
    'startTime',0,...
    'endTime',0,...
    'totalBlockDuration',0);

timingsReport=cell2mat(timingsReport);
addpath('supportFiles');   
%   Load parameters
%--------------------------------------------------------------------------------------------------------------------------------------%
loadParameters();
 
%   Initialize the subject info
%--------------------------------------------------------------------------------------------------------------------------------------%
initSubjectInfo();

% %  Hide Mouse Cursor

if parameters.hideCursor
    HideCursor()
end

%   Initialize screen
%--------------------------------------------------------------------------------------------------------------------------------------%


initScreen(); %change transparency of screen from here

%   Convert values from visual degrees to pixels
%--------------------------------------------------------------------------------------------------------------------------------------%
visDegrees2Pix();

%   Initialize Datapixx
%-------------------------------------------------------------------------- ------------------------------------------------------------%

if ~parameters.isDemoMode
    % datapixx init
    datapixx = 0;               
    AssertOpenGL;   % We use PTB-3;
    isReady =  Datapixx('Open');
    Datapixx('StopAllSchedules');
    Datapixx('RegWrRd');    % Synchronize DATAPixx registers to local register cache
end

 


%  run the experiment
%--------------------------------------------------------------------------------------------------------------------------------------%
%  

% % %To suspend the output of keyboard to command line
ListenChar(2); 
% 
%  init start of experiment procedures 
%--------------------------------------------------------------------------------------------------------------------------------------%
% 
 %  init scanner
%--------------------------------------------------------------------------------------------------------------------------------------%
% 
if parameters.isDemoMode
    showTTLWindow_1();
else
    showTTLWindow_2();
end

%  iterate over all blocks 
%--------------------------------------------------------------------------------------------------------------------------------------%
%  
timing.soeDuration = 0;
isTerminationKeyPressed = false;

tic
for   tc =  1 : parameters.numberOfBlocks

    % hadi send trigger here
    
%     if mod(tc,2) ~= 0
%         blockText = parameters.blockOneMsg;
%         
%     else
%         blockText = parameters.blockTwoMsg;
%     end    

    % Determine the block group (1 to 10)
    block_group = ceil(tc / 20);
    
    % Determine the position within the current 20-block group
    position_in_group = mod(tc - 1, 20) + 1;
    
    % Determine the type based on position
    if position_in_group == 1
        block_type = block_group; % 1st block in each group has type equal to block_group
    else
        block_type = 2; % All other blocks in the group are type 2
    end
    
    [blockStartTime, blockEndTime] = showBlockWindow(blockText);

    %% Putti says: if we are moving the right hand, this means the right hemisphere is not being used
    %% in this case, we can use all the signals from the right hemisphere as a baseline
    %% According to the paper https://pmc.ncbi.nlm.nih.gov/articles/PMC3713710/pdf/HBM-33-1594.pdf
    %% it is best to have a random permutation of the finger order to get a better spatial accuracy
    %% according to Putti: we should correct for the MRI artifact (causing higher signal amplitudes with time) that has an upward trend with time (this is done by adding a linear drift vector at the end of the design matrix)
    %% Add a first vector of constant values in order to take the average of the BOLD signals from all fingers as a baseline
    %% In the paper the block duration is 3 seconds, however we can then take 12 seconds per finger

    timingsReport(:,tc).trial = tc;
    timingsReport(:,tc).startTime =  blockStartTime;
    timingsReport(:,tc).endTime =  blockEndTime;
    timingsReport(:,tc).totalBlockDuration = blockEndTime - blockStartTime;
end
%  init end of experiment procedures 
%--------------------------------------------------------------------------------------------------------------------------------------%
%
startEoeTime = showEoeWindow();

% 
%  save the data
%--------------------------------------------------------------------------------------------------------------------------------------%
% 

writetable(struct2table(timingsReport),parameters.datafile);


%   To allow the output of keyboard to command line
ListenChar(1);

% Show cursor back
ShowCursor('Arrow');
 
sca;

if ~parameters.isDemoMode
    % datapixx shutdown
    Datapixx('RegWrRd');
    Datapixx('StopAllSchedules');
    Datapixx('Close');
end
