% Initialization
addpath(genpath('/Applications/Psychtoolbox'))
PsychDebugWindowConfiguration(0, 0.5);
% Simple Attention Task using Psychtoolbox
% Initialize Psychtoolbox
Screen('Preference', 'SkipSyncTests', 1); % Skip sync tests for simplicity (not recommended for actual experiments)
PsychDefaultSetup(2);
screenNumber = max(Screen('Screens'));
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
gray = (white + black) / 2;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray);
[xCenter, yCenter] = RectCenter(windowRect);

% Set up fixation cross parameters
fixationCrossSize = 40;
fixationColor = black;
lineWidth = 4;

% Set up target parameters
targetSize = 50;
targetColor = black;
flashColor = [255 0 0]; % Red for flashing
flashDuration = 0.1; % Duration of flash in seconds
flashInterval = 0.5; % Interval between flashes in seconds

% Set up timing parameters
totalTaskTime = 20 * 60; % Total task time in seconds
sideTime = 10 * 60; % Time spent on each side in seconds
fixationDuration = 2 * 60; % Fixation duration on each side in seconds

% Define positions for the targets
leftTargetPos = [-300, yCenter]; % X coordinate is negative for left side
rightTargetPos = [300, yCenter]; % X coordinate is positive for right side

% Set up key response
KbName('UnifyKeyNames');
responseKey = KbName('Space'); % Use the space bar for responses

% Initialize random seed
rng('shuffle');

% Main task loop
startTime = GetSecs;
side = 1; % Start with left side
while (GetSecs - startTime) < totalTaskTime
    % Determine current side
    if side == 1
        targetPos = leftTargetPos;
        fixationCrossPos = leftTargetPos;
    else
        targetPos = rightTargetPos;
        fixationCrossPos = rightTargetPos;
    end
    
    % Display fixation cross
    DrawFixationCross(window, xCenter, yCenter, fixationCrossSize, fixationColor, lineWidth);
    Screen('Flip', window);
    WaitSecs(fixationDuration);
    
    % Display peripheral target
    DrawTarget(window, targetPos, targetSize, targetColor);
    Screen('Flip', window);
    WaitSecs(fixationDuration);
    
    % Show flashing target
    startFlashTime = GetSecs;
    while (GetSecs - startFlashTime) < fixationDuration
        if mod(GetSecs - startFlashTime, flashInterval * 2) < flashDuration
            DrawTarget(window, targetPos, targetSize, flashColor);
        else
            DrawTarget(window, targetPos, targetSize, targetColor);
        end
        Screen('Flip', window);
    end
    
    % Wait for response
    responded = false;
    while ~responded
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown && keyCode(responseKey)
            responded = true;
        end
    end
    
    % Switch side
    side = 3 - side; % Toggle between 1 (left) and 2 (right)
end

% Cleanup
Screen('CloseAll');
ListenChar(0);
ShowCursor;

% Function to draw a fixation cross
function DrawFixationCross(window, x, y, size, color, lineWidth)
    lineCoords = [-size/2, y; size/2, y; x, -size/2; x, size/2];
    Screen('DrawLines', window, lineCoords(:)', lineWidth, color);
end

% Function to draw a target
function DrawTarget(window, position, size, color)
    Screen('FillRect', window, color, [position(1)-size/2, position(2)-size/2, position(1)+size/2, position(2)+size/2]);
end
