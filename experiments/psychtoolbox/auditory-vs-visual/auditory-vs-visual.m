% Clear the workspace
clear; clc;

% Initialize Psychtoolbox
Screen('Preference', 'SkipSyncTests', 1); % Skips sync tests (remove for real experiments)
PsychDefaultSetup(2);

% Setup the screen
screenNumber = max(Screen('Screens'));
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, [0 0 0]); % Black background
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);

% Setup audio
InitializePsychSound;
audioFile = 'sound.wav'; % Replace with your audio file
[audioData, freq] = audioread(audioFile); % Read the audio file
audioData = audioData'; % Transpose for Psychtoolbox
audioDevice = PsychPortAudio('Open', [], [], 0, freq, 2); % Open audio device
PsychPortAudio('FillBuffer', audioDevice, [audioData; audioData]); % Load audio into buffer

% Experiment Parameters
nTrials = 20; % Number of trials
stimulusDuration = 1; % Stimulus duration in seconds
fixationDuration = 0.5; % Fixation cross duration
stimulusOrder = randperm(nTrials); % Randomize stimulus order

% Instructions
DrawFormattedText(window, 'Press any key to start the experiment.', 'center', 'center', [1 1 1]);
Screen('Flip', window);
KbStrokeWait; % Wait for key press

% Trial Loop
for trial = 1:nTrials
    % Fixation Cross
    Screen('TextSize', window, 40);
    DrawFormattedText(window, '+', 'center', 'center', [1 1 1]); % White fixation cross
    Screen('Flip', window);
    WaitSecs(fixationDuration);

    % Present stimulus
    if mod(stimulusOrder(trial), 2) == 0
        % Visual Stimulus (e.g., white square)
        baseRect = [0 0 200 200]; % Rectangle size
        centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter); % Centered rectangle
        Screen('FillRect', window, [1 1 1], centeredRect); % White rectangle
        Screen('Flip', window);
        WaitSecs(stimulusDuration); % Wait for stimulus duration
    else
        % Auditory Stimulus
        Screen('Flip', window); % Clear the screen
        PsychPortAudio('Start', audioDevice, 1, 0, 1); % Play the sound
        WaitSecs(stimulusDuration); % Wait for stimulus duration
        PsychPortAudio('Stop', audioDevice); % Stop audio
    end

    % Inter-trial interval
    Screen('Flip', window);
    WaitSecs(0.5);
end

% End of Experiment
DrawFormattedText(window, 'Experiment Complete.\nPress any key to exit.', 'center', 'center', [1 1 1]);
Screen('Flip', window);
KbStrokeWait;

% Close everything
sca; % Close screen
PsychPortAudio('Close'); % Close audio device
