%% script to generate simple attention task - adjusted for MEG 
% written September 2024, by Karima Raafat (kar618@nyu.edu) & Hadi Zaatiti (hz3752@nyu.edu)
%% initialize psychtoolbox 
clear all; clc 
addpath(genpath('/Applications/Psychtoolbox')); sca
sca
PsychDebugWindowConfiguration(0, .5); % 1 for running exp; 0.5 for debugging
PsychDefaultSetup(2); 
Screen('Preference', 'SkipSyncTests', 2); 

% open psychtoolbox window & define screen parameters 
screenNum = max(Screen('Screens'));
white = [255 255 255];
gray = (white/2)/255; 
black = [0 0 0]; sca
sca

red = [255 0 0]; 
alpha = 0.05; % transparency 
targetColorWithAlpha = [red, alpha]; % combine color with alpha

[window, windowRect] = PsychImaging('OpenWindow', screenNum, gray); % open a gray window
[xCenter, yCenter] = RectCenter(windowRect); % get the center of the screen

% define some stimuli parameters 
fixationCrossSize = 10; % fixation crossca
% s; made up of overlapping horizontal and vertical lines
fixationCrossWidth = 2.5; 

fixRectH = [xCenter-fixationCrossSize, yCenter, ...
    xCenter+fixationCrossSize, yCenter]; % horizontal line vertices
fixRectV = [ xCenter, yCenter-fixationCrossSize,...
        xCenter, yCenter+fixationCrossSize]; % vertical line vertices

% conditions
numConds = 2; leftID = 1; rightID = 2; 
cueArrowLeft = '<'; 
cueArrowRight = '>'; 
conditionCues = {cueArrowLeft cueArrowRight}; 
cueSize = 40; 

targetEccentricity = xCenter/2; % target eccentricity left or right

targetSize = 30; % flashing attention stimulus to prompt button press 
halfTarget = targetSize / 2; 
targetRect = [xCenter - halfTarget, yCenter - halfTarget, ...
              xCenter + halfTarget, yCenter + halfTarget]; 
centeredTargetLeft = CenterRectOnPointd(targetRect,xCenter-targetEccentricity,yCenter); % left 
centeredTargetRight = CenterRectOnPointd(targetRect,xCenter+targetEccentricity,yCenter); % right
targetPosition = [centeredTargetLeft; centeredTargetRight];
freq = .1; % frequency of flashing / jitter 

% define task timings; all in seconds -- we will change these accordingly
cueDuration = .5; % 35ms in paper
briefDelay = 1; %1000ms
initialCenterFixation = 1.5; % duration to fixate on the center at first and in between 

% create condition matrix 
targetDuration = 1; % 85ms
delayInBetween = 3; 
desiredConditionDuration = 32; 
totalDuration = round(desiredConditionDuration / (targetDuration + delayInBetween)) * (targetDuration + delayInBetween);
timesTargetsAppear = totalDuration/sum([targetDuration,delayInBetween]);



leftVector = repmat(leftID, 1, timesTargetsAppear/numConds); 
rightVector = repmat(rightID, 1, timesTargetsAppear/numConds); 
blockType = [leftID rightID];
blockITI = 2; 

attentionConditions = [leftVector rightVector]; 
attentionConditions = attentionConditions(randperm(length(attentionConditions))); 

totalTaskDuration = desiredConditionDuration*2; % total duration of the experiment in seconds 

% define some keys for response 
KbName('UnifyKeyNames');   % this command switches keyboard mappings to the OSX naming scheme, regardless of computer.
space = KbName('space'); % to start
% escape = KbName('ESCAPE'); 
leftArrowKey = KbName('LeftArrow'); 
rightArrowKey = KbName('RightArrow'); 

responses = []; 
performance = []; 

clc; disp(attentionConditions)


%% need to create a bigger matrix for the condition, and then within that is the sides equally distributed.

%% start task while loop 
% startTime = GetSecs(); % initialize timing 
% while GetSecs()-startTime < totalTaskDuration

    for b = 1:length(blockType) % 2 blocks, one side each 
         % initial central fixation
         DrawFixationCross()
         Screen('Flip', window)
         WaitSecs(initialCenterFixation) % wait for fixation duration

         % attend left. leave on screen for 35ms
         Screen('TextSize', window, cueSize);
         DrawFormattedText(window, cell2mat(conditionCues(b)), xCenter-cueSize/2, yCenter+cueSize/2, red);
         Screen('Flip', window)
         WaitSecs(cueDuration)

         Screen('Flip', window)
         WaitSecs(briefDelay)

         startCondition = GetSecs();
        while GetSecs()-startCondition < desiredConditionDuration
            for t = 1:timesTargetsAppear

                % peripheral target with central fixation
                DrawFixationCross()
                Screen('FillOval', window, targetColorWithAlpha, targetPosition(attentionConditions(t),:))
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

                        % %save in correct/incorrect matrix as 0 or 1 depending on condition
                        % if attentionConditions(t) == rightID % correct response
                        %     accuracy = 1;
                        % else
                        %     accuracy = 0;
                        % end
                    end

                end
                % if no response is made
                if keypresses == 0
                    buttonPressed = nan;
                    accuracy = nan;
                end
                responses = [responses buttonPressed];
                performance = [performance accuracy];

                Screen('DrawLine', window, white, xCenter-fixationCrossSize, ...
                    yCenter, xCenter+fixationCrossSize, yCenter, fixationCrossWidth);
                Screen('DrawLine', window, white, xCenter, yCenter-fixationCrossSize,...
                    xCenter, yCenter+fixationCrossSize, fixationCrossWidth);
                Screen('Flip', window)
                WaitSecs(delayInBetween)
            end
        end

    end
    
% 
% 
%     end
% 
%     Screen('Flip', window)
%     WaitSecs(peripheralFixation) 
% 
%     % once left target fixation time is up, flash attention stimulus
%     flashStart = GetSecs();
%     while GetSecs()-flashStart < targetDuration
%         Screen('FillOval', window, red, centeredTargetLeft)
%         Screen('Flip', window)
%         WaitSecs(freq)
% 
%         Screen('FillOval', window, gray, centeredTargetLeft)
%         Screen('Flip', window)
%         WaitSecs(freq)
%     end
% 
%     % draw target on the right. leave on screen for x minutes
%     Screen('FillRect', window, black, centeredRectRight_target)
% 
%     % draw fixation at the center of the target 
%     Screen('DrawLine', window, white, fixCenterRightH(1), fixCenterRightH(2), fixCenterRightH(3), fixCenterRightH(4), fixationCrossWidth);
%     Screen('DrawLine', window, white, fixCenterRightV(1), fixCenterRightV(2), fixCenterRightV(3), fixCenterRightV(4), fixationCrossWidth);
%     Screen('Flip', window)
%     WaitSecs(peripheralFixation)
% 
%     % once right target fixation time is up, flash attention stimulus
%     flashStart = GetSecs();
%     while GetSecs()-flashStart < targetDuration
%         Screen('FillOval', window, red, centeredTargetRight)
%         Screen('Flip', window)
%         WaitSecs(freq)
%         Screen('FillOval', window, gray, centeredTargetRight)
%         Screen('Flip', window)
%         WaitSecs(freq)
%     end
% 
%     % wait for x seconds before repeating
%     WaitSecs(ITI)
% end
% sca % close screen 

