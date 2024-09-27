% Simple Attention Task using Psychtoolbox
% Ensure that Psychtoolbox is installed and working properly
clear all; clc 
addpath(genpath('/Applications/Psychtoolbox'))
sca
% Initialize Psychtoolbox
%% initialize psychtoolbox 
PsychDebugWindowConfiguration(0, 0.5); % 1 for running exp; 0.5 for debugging
PsychDefaultSetup(2); 
Screen('Preference', 'SkipSyncTests', 2); % Disable sync tests for simplicity (remove in real experiments)

screenNum = max(Screen('Screens'));
[window, windowRect] = PsychImaging('OpenWindow', screenNum, [0 0 0]); % Open a black window
[xCenter, yCenter] = RectCenter(windowRect); % Get the center of the screen
fixationCrossSize = 10; % Size of the fixation cross
targetFlashDuration = 0.5; % Duration of target flash in seconds
fixationDuration = 1; % Duration to fixate on each target in seconds
totalDuration = 20; % Total duration of the experiment in seconds (20 minutes)

% Set the position of the left and right targets
leftTargetPos = [xCenter - 100, yCenter - 20, xCenter - 100 + 80, yCenter + 20]; % Left target rectangle
rightTargetPos = [xCenter + 20, yCenter - 20, xCenter + 100, yCenter + 20]; % Right target rectangle

% Initialize timing
startTime = GetSecs();
endTime = startTime + totalDuration;
black = [1 1 1]; 
line_width = 5; 

while GetSecs() < endTime
    % Left side fixation
    drawFixationCross(black, window, xCenter, yCenter, fixationCrossSize, line_width);
    Screen('Flip', window);
    WaitSecs(fixationDuration); % Fixate for 2 minutes

    % Flash left colored target
    for i = 1:4 % Flashing 4 times for demonstration
        DrawColoredTarget(window, leftTargetPos);
        Screen('Flip', window);
        WaitSecs(targetFlashDuration);
        Screen('Flip', window);
        WaitSecs(targetFlashDuration);
    end

    % Wait for button press
    KbWait([], 2); % Wait for a key press

    % Right side fixation
    drawFixationCross(black, window, xCenter, yCenter, fixationCrossSize, line_width);
    Screen('Flip', window);
    WaitSecs(fixationDuration); % Fixate for 2 minutes

    % Flash right colored target
    for i = 1:4 % Flashing 4 times for demonstration
        DrawColoredTarget(window, rightTargetPos);
        Screen('Flip', window);
        WaitSecs(targetFlashDuration);
        Screen('Flip', window);
        WaitSecs(targetFlashDuration);
    end

    % Wait for button press
    KbWait([], 2); % Wait for a key press
end

% Close the window
Screen('CloseAll');

% Function to draw a fixation cross
function drawFixationCross(color, window, xCenter, yCenter, fixationCrossSize, line_width)
    Screen('DrawLine', window, color, xCenter-fixationCrossSize, ...
        yCenter, xCenter+fixationCrossSize, yCenter, line_width);
    Screen('DrawLine', window, color, xCenter, yCenter-fixationCrossSize,...
        xCenter, yCenter+fixationCrossSize, line_width);
end

% Function to draw a colored target
function DrawColoredTarget(window, targetPos)
    targetColor = [255 0 0]; % Red color for target
    Screen('FillRect', window, targetColor, targetPos); % Draw the colored target
    % % Draw a fixation cross in the center of the target
    % drawFixationCross(color, window, mean(targetPos([1, 3])), mean(targetPos([2, 4])), 20);
end

