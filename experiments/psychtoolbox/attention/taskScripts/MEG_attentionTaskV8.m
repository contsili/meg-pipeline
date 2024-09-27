%% script to generate simple attention task - adjusted for MEG
% written September 2024, by Karima Raafat (kar618@nyu.edu) & Hadi Zaatiti (hz3752@nyu.edu)

%% initialize variables 
clearvars; clc
addpath(genpath('/Applications/Psychtoolbox')); sca
PsychDebugWindowConfiguration(0, 1); % 1 for running exp; 0.5 for debugging
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 2);
screenNum = max(Screen('Screens'));

% define some keys for keyboard input 
KbName('UnifyKeyNames'); % this command switches keyboard mappings to the OSX naming scheme, regardless of computer.
space = KbName('space'); % to start & respond 

% define screen parameters
white = [255 255 255];
gray = (white/2)/255;
red = [255 0 0]; 
alpha = 0.05; % transparency
targetColor = [red, alpha]; % combine color with alpha

[window, windowRect] = PsychImaging('OpenWindow', screenNum, gray); % open a gray window
[xCenter, yCenter] = RectCenter(windowRect); % get the center of the screen

% define fixation parameters
fixationSize = 15; fixationWidth = 2.5;

fixRectHorizontal = [xCenter-fixationSize, yCenter, ...
    xCenter+fixationSize, yCenter]; % horizontal line vertices
fixRectVertical = [xCenter, yCenter-fixationSize,...
    xCenter, yCenter+fixationSize]; % vertical line vertices

% define attention target parameters 
targetEccentricity = xCenter/2; % to the left or right 
targetSize = 30; 
targetRect = [xCenter - targetSize/2, yCenter - targetSize/2, ...
    xCenter + targetSize/2, yCenter + targetSize/2];
centerLeft = CenterRectOnPointd(targetRect,xCenter-targetEccentricity,yCenter); % left
centerRight = CenterRectOnPointd(targetRect,xCenter+targetEccentricity,yCenter); % right
targetPosition = [centerLeft; centerRight];

% conditions
numOfConditions = 2; 
leftID = 1; rightID = 2;
cueArrowLeft = '<'; cueArrowRight = '>';
cueType = {cueArrowLeft cueArrowRight};
cueSize = 40;
cueColor = red; 

% define task timings in seconds
initialCenterFixation = 1.5; % duration to fixate on the center at first and in between
cueDuration = .5; % 35ms in paper 
delay = 1; %1000ms in paper
targetDuration = 1; % 85ms; time they have to respond 
delayInBetween = 2; % between target appearing on each side within block
blockDuration = 30;
% work out how many times targets appear in total based on above timings
timesTargetsAppear = blockDuration/sum([targetDuration,delayInBetween]); % per block 
totalTaskDuration = blockDuration*2; % total duration of the experiment in seconds
blockITI = 2;

% create attendion condition matrix to use within each block 
leftVector = repmat(leftID, 1, timesTargetsAppear/numOfConditions);
rightVector = repmat(rightID, 1, timesTargetsAppear/numOfConditions);
blockAttentionCondition = [leftID rightID]; 
targetSideCondition = [leftVector rightVector];
targetSideCondition = targetSideCondition(randperm(length(targetSideCondition))); % shuffle

responses = []; performance = [];

clc; disp(targetSideCondition)

DrawFixation()
Screen('Flip', window)
WaitSecs(initialCenterFixation) % wait for fixation duration

% attend left. leave on screen for 35ms
Screen('TextSize', window, cueSize);
DrawFormattedText(window, cell2mat(cueType(1)), xCenter-cueSize/2, yCenter+cueSize/2, cueColor);
Screen('Flip', window)
WaitSecs(cueDuration)

% blank screen for delay
DrawFixation()
Screen('Flip', window)
WaitSecs(delay)

WaitSecs(2)
sca
%% start task loop
for b = 1:length(blockType) % 2 blocks, one side each
    % initial central fixation
    DrawFixation()
    Screen('Flip', window)
    WaitSecs(initialCenterFixation) % wait for fixation duration

    % attend left. leave on screen for 35ms
    Screen('TextSize', window, cueSize);
    DrawFormattedText(window, cell2mat(cueType(b)), xCenter-cueSize/2, yCenter+cueSize/2, cueColor);
    Screen('Flip', window)
    WaitSecs(cueDuration)

    % blank screen for delay
    DrawFixation()
    Screen('Flip', window)
    WaitSecs(delay)

    startCondition = GetSecs();
    while GetSecs()-startCondition < desiredConditionDuration
        for t = 1:timesTargetsAppear

            % peripheral target with central fixation
            DrawFixation()
            Screen('FillOval', window, targetColor, targetPosition(attentionConditions(t),:))
            Screen('Flip', window)
            % WaitSecs(targetDuration)

            startResponse = GetSecs();
            keyIsDown = 0;
            keypresses = 0;
            while GetSecs()-startResponse < targetDuration

                % record button press (here, space)
                [keyIsDown,secs,keyCode,deltaSecs]=KbCheck;
                if keyIsDown && keyCode(space)

                    % check if target side matches attention cue side
                    % if attentionConditions(t) == leftID ...
                    %         && blockType(b) == leftID
                    if attentionConditions(t) == blockType(b)
                        accuracy = 1;
                    else
                        accuracy = 0;
                    end

                end

            end
            % if no response is made
            if keypresses == 0
                buttonPressed = nan;
                accuracy = nan;
            end
            responses = [responses buttonPressed];
            performance = [performance accuracy];

            Screen('DrawLine', window, white, xCenter-fixationSize, ...
                yCenter, xCenter+fixationSize, yCenter, fixationWidth);
            Screen('DrawLine', window, white, xCenter, yCenter-fixationSize,...
                xCenter, yCenter+fixationSize, fixationWidth);
            Screen('Flip', window)
            WaitSecs(delayInBetween)
        end
    end

end

