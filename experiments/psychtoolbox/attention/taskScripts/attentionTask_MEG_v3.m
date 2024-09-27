%% script to generate simple attention task - adjusted for MEG 
% clear vars, command window
clear all; clc 
%% initialize psychtoolbox 
addpath(genpath('/Applications/Psychtoolbox')); sca
PsychDebugWindowConfiguration(0, .5); % 1 for running exp; 0.5 for debugging
PsychDefaultSetup(2); 
Screen('Preference', 'SkipSyncTests', 2); % Disable sync tests for simplicity (remove in real experiments)

screenNum = max(Screen('Screens'));
% define black, white, & gray 
white = [255 255 255];
gray = (white/2)/255; 
black = [0 0 0]; 
red = [255 0 0]; 

[window, windowRect] = PsychImaging('OpenWindow', screenNum, gray); % Open a black window
[xCenter, yCenter] = RectCenter(windowRect); % Get the center of the screen
fixationCrossSize = 10; % Size of the fixation cross
fixationWidth = 2.5; 

centerFixationDuration = 1.5; % duration to fixate on the center at first
targetFixationDuration = 10; % Duration to fixate on each target in seconds
targetFlashDuration = 1.5; % Duration of target flash in seconds
totalTaskDuration = 40; % Total duration of the experiment in seconds (20 minutes)

% Set the position of the left and right targets
leftTargetPos = [xCenter - xCenter/2, yCenter - yCenter/2, xCenter - xCenter/2, yCenter + yCenter/2]; % left target square
rightTargetPos = [xCenter + xCenter/2, yCenter - yCenter/2, xCenter + xCenter/2, yCenter + yCenter/2]; % right target square

% Initialize timing
% startTime = GetSecs();
% endTime = startTime + totalTaskDuration;
ITI = 1; 

squareSize = 100; % Size of the square
halfSquare = squareSize / 2; % Half size to center it
squareRect = [xCenter - halfSquare, yCenter - halfSquare, ...
              xCenter + halfSquare, yCenter + halfSquare]; % Define the square's rectangle

eccentricity = xCenter/2; 
centeredRectLeft_target = CenterRectOnPointd(squareRect,xCenter-eccentricity,yCenter); % left 
centeredRectRight_target = CenterRectOnPointd(squareRect,xCenter+eccentricity,yCenter); % right

fixRectH = [xCenter-fixationCrossSize, yCenter, ...
    xCenter+fixationCrossSize, yCenter];
fixRectV = [ xCenter, yCenter-fixationCrossSize,...
        xCenter, yCenter+fixationCrossSize];

fixCenterLeftH = CenterRectOnPointd(fixRectH, xCenter-eccentricity,yCenter);
fixCenterLeftV = CenterRectOnPointd(fixRectV, xCenter-eccentricity,yCenter);

fixCenterRightH =  CenterRectOnPointd(fixRectH, xCenter+eccentricity,yCenter); 
fixCenterRightV =  CenterRectOnPointd(fixRectV, xCenter+eccentricity,yCenter); 

% flashing stimulus
flashingCircleSize = 50; % Size of the square
halfCircle = flashingCircleSize / 2; % Half size to center it
flashingCircleRect = [xCenter - halfCircle, yCenter - halfCircle, ...
              xCenter + halfCircle, yCenter + halfCircle]; 
centeredRectLeft_flash = CenterRectOnPointd(flashingCircleRect,xCenter-eccentricity,yCenter); % left 
centeredRectRight_flash = CenterRectOnPointd(flashingCircleRect,xCenter+eccentricity,yCenter); % right

freq = .1; 
%%
startTime = GetSecs();
while GetSecs()-startTime < totalTaskDuration
% 
    % draw fixation at the center of the screen 
    Screen('DrawLine', window, white, xCenter-fixationCrossSize, ...
        yCenter, xCenter+fixationCrossSize, yCenter, fixationWidth);
    Screen('DrawLine', window, white, xCenter, yCenter-fixationCrossSize,...
        xCenter, yCenter+fixationCrossSize, fixationWidth);
    Screen('Flip', window)
    WaitSecs(centerFixationDuration)

    % draw target on the left. leave on screen for x minutes
    Screen('FillRect', window, black, centeredRectLeft_target)
    % draw fixation at the center of the target 
    Screen('DrawLine', window, white, fixCenterLeftH(1), fixCenterLeftH(2), fixCenterLeftH(3), fixCenterLeftH(4), fixationWidth);
    Screen('DrawLine', window, white, fixCenterLeftV(1), fixCenterLeftV(2), fixCenterLeftV(3), fixCenterLeftV(4), fixationWidth);
    Screen('Flip', window)

    WaitSecs(targetFixationDuration)

    % once target fixation time is up, flash attention stimulus
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
    Screen('DrawLine', window, white, fixCenterRightH(1), fixCenterRightH(2), fixCenterRightH(3), fixCenterRightH(4), fixationWidth);
    Screen('DrawLine', window, white, fixCenterRightV(1), fixCenterRightV(2), fixCenterRightV(3), fixCenterRightV(4), fixationWidth);
    Screen('Flip', window)

    WaitSecs(targetFixationDuration)
    flashStart = GetSecs();
    while GetSecs()-flashStart < targetFlashDuration
        Screen('FillOval', window, red, centeredRectRight_flash)
        Screen('Flip', window)
        WaitSecs(freq)
        Screen('FillOval', window, gray, centeredRectRight_flash)
        Screen('Flip', window)
        WaitSecs(freq)
    end
    
    WaitSecs(ITI)
   
end
