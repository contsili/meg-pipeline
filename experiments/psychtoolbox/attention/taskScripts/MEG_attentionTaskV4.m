%% script to generate simple attention task - adjusted for MEG 
% written September 2024, by Karima Raafat (kar618@nyu.edu) & Hadi Zaatiti (hz3752@nyu.edu)
%% initialize psychtoolbox 
clear all; clc 
addpath(genpath('/Applications/Psychtoolbox')); sca
PsychDebugWindowConfiguration(0, 1); % 1 for running exp; 0.5 for debugging
PsychDefaultSetup(2); 
Screen('Preference', 'SkipSyncTests', 2); 

% open psychtoolbox window & define screen parameters 
screenNum = max(Screen('Screens'));
white = [255 255 255];
gray = (white/2)/255; 
black = [0 0 0]; 
red = [255 0 0]; 
[window, windowRect] = PsychImaging('OpenWindow', screenNum, gray); % open a gray window
[xCenter, yCenter] = RectCenter(windowRect); % get the center of the screen

% define some stimuli parameters 
fixationCrossSize = 10; % fixation cross; made up of overlapping horizontal and vertical lines
fixationCrossWidth = 2.5; 

fixRectH = [xCenter-fixationCrossSize, yCenter, ...
    xCenter+fixationCrossSize, yCenter]; % horizontal line vertices
fixRectV = [ xCenter, yCenter-fixationCrossSize,...
        xCenter, yCenter+fixationCrossSize]; % vertical line vertices

eccentricity = xCenter/2; % center H & V lines on either side of the screen 
fixCenterLeftH = CenterRectOnPointd(fixRectH, xCenter-eccentricity,yCenter); % left 
fixCenterLeftV = CenterRectOnPointd(fixRectV, xCenter-eccentricity,yCenter);

fixCenterRightH =  CenterRectOnPointd(fixRectH, xCenter+eccentricity,yCenter); % right
fixCenterRightV =  CenterRectOnPointd(fixRectV, xCenter+eccentricity,yCenter); 


squareSize = 100; % peripheral stimulus (square)
halfSquare = squareSize / 2; % center using half the size of the square 
squareRect = [xCenter - halfSquare, yCenter - halfSquare, ...
              xCenter + halfSquare, yCenter + halfSquare]; % define the square's vertices

centeredRectLeft_target = CenterRectOnPointd(squareRect,xCenter-eccentricity,yCenter); % center the square on either side of the screen; left  
centeredRectRight_target = CenterRectOnPointd(squareRect,xCenter+eccentricity,yCenter); % right


flashingCircleSize = 50; % flashing attention stimulus to prompt button press 
halfCircle = flashingCircleSize / 2; 
flashingCircleRect = [xCenter - halfCircle, yCenter - halfCircle, ...
              xCenter + halfCircle, yCenter + halfCircle]; 
centeredRectLeft_flash = CenterRectOnPointd(flashingCircleRect,xCenter-eccentricity,yCenter); % left 
centeredRectRight_flash = CenterRectOnPointd(flashingCircleRect,xCenter+eccentricity,yCenter); % right
freq = .1; % frequency of flashing / jitter 

% define task timings; all in seconds -- we will change these accordingly
centerFixationDuration = 1.5; % duration to fixate on the center at first and in between 
targetFixationDuration = 5; % duration to fixate on each target
targetFlashDuration = 1.5; % duration of flashing stimulus
totalTaskDuration = 20; % total duration of the experiment in seconds 
ITI = 1; % interval in between after left & right presentation (if needed)
%% start task while loop 
startTime = GetSecs(); % initialize timing 
while GetSecs()-startTime < totalTaskDuration

    % initial central fixation
    Screen('DrawLine', window, white, xCenter-fixationCrossSize, ...
        yCenter, xCenter+fixationCrossSize, yCenter, fixationCrossWidth);
    Screen('DrawLine', window, white, xCenter, yCenter-fixationCrossSize,...
        xCenter, yCenter+fixationCrossSize, fixationCrossWidth);
    Screen('Flip', window)
    WaitSecs(centerFixationDuration) % wait for fixation duration 

    % draw target on the left. leave on screen for x minutes
    Screen('FillRect', window, black, centeredRectLeft_target)

    % draw fixation at the center of the target 
    Screen('DrawLine', window, white, fixCenterLeftH(1), fixCenterLeftH(2), fixCenterLeftH(3), fixCenterLeftH(4), fixationCrossWidth);
    Screen('DrawLine', window, white, fixCenterLeftV(1), fixCenterLeftV(2), fixCenterLeftV(3), fixCenterLeftV(4), fixationCrossWidth);
    Screen('Flip', window)
    WaitSecs(targetFixationDuration) 

    % once left target fixation time is up, flash attention stimulus
    flashStart = GetSecs();
    while GetSecs()-flashStart < targetFlashDuration
        Screen('FillOval', window, red, centeredRectLeft_flash)
        Screen('Flip', window)
        WaitSecs(freq)

        Screen('FillOval', window, gray, centeredRectLeft_flash)
        Screen('Flip', window)
        WaitSecs(freq)
    end
    
    % draw target on the right. leave on screen for x minutes
    Screen('FillRect', window, black, centeredRectRight_target)
   
    % draw fixation at the center of the target 
    Screen('DrawLine', window, white, fixCenterRightH(1), fixCenterRightH(2), fixCenterRightH(3), fixCenterRightH(4), fixationCrossWidth);
    Screen('DrawLine', window, white, fixCenterRightV(1), fixCenterRightV(2), fixCenterRightV(3), fixCenterRightV(4), fixationCrossWidth);
    Screen('Flip', window)
    WaitSecs(targetFixationDuration)

    % once right target fixation time is up, flash attention stimulus
    flashStart = GetSecs();
    while GetSecs()-flashStart < targetFlashDuration
        Screen('FillOval', window, red, centeredRectRight_flash)
        Screen('Flip', window)
        WaitSecs(freq)
        Screen('FillOval', window, gray, centeredRectRight_flash)
        Screen('Flip', window)
        WaitSecs(freq)
    end
    
    % wait for x seconds before repeating
    WaitSecs(ITI)
end
sca % close screen 
