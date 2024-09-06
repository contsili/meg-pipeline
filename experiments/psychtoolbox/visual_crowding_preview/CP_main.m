clearvars
Screen('Preference', 'SkipSyncTests', 1);
AssertOpenGL;

Datapixx('Open');

Datapixx('DisablePixelMode');
Datapixx('RegWr');

Datapixx('SetPropixxDlpSequenceProgram', 0);
Datapixx('RegWr');


% PARTICIPANT DATA
name1='Participant Data';
prompt1={'Subject Number', ...
    'Subject ID', ...
    'Sex (f/m)', ...
    'Age', ...
    'Task order'};
numlines1=1;
defaultanswer1={ '0', 'p', 'M', '0', '1'};
answer1=inputdlg(prompt1,name1,numlines1,defaultanswer1);
DEMO.num = str2double(answer1{1});
DEMO.ID  = answer1{2};
DEMO.sex = answer1{3};
DEMO.age = str2double(answer1{4});
DEMO.order = str2double(answer1{5});
DEMO.date = datetime;

fixColor = [0 0 0]; % Fixation color (black)
fixColorCue = [0 128 0];
fixBadColor = [255 0 0]; % Fixation bad color (red)
fixRadius = 10;
black = [0 0 0];
fixTolerance = 500; % 75 pixels -> 2 dva
targetTolerance = 100;
saccadeOffset = 305; % pixel -> 8 dva
targetDuration = .5; % seconds
saccThreshold = 7; % pixel -> 0.18 dva

try

    % Screen setup
    s = max(Screen('Screens'));
    % Set the background color to white during window initialization
    [w, rect] = Screen('OpenWindow', s, [255 255 255]); %,[200 200 1000 1000]);
    Priority(MaxPriority(w));
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    pixelSizes = Screen('PixelSizes', s);
    fps = Screen('FrameRate', w);
    ifi = Screen('GetFlipInterval', w);
    [wx, wy] = RectCenter(rect);

    fixRect = CenterRectOnPoint([0, 0, fixRadius*2, fixRadius*2], wx, wy);


    if length([answer1{1} answer1{2}]) > 4
        error('EYELINK FILENAMES NEED TO BE LESS THAN 9 CHARACTERS LONG')
    end

    % TRIGGERS SETUP
    trig.SYNCTIME = 0;
    trig.START = 1;
    trig.PREVIEW = 2;
    trig.SACCADE = 3;
    trig.TARGET = 4;
    trig.RESPONSE = 5;

    % EYE-TRACKING SETUP
    el = EyelinkInitDefaults(w);
    el.backgroundcolour = 255;
    el.foregroundcolour = 0;
    el.calibrationtargetcolour = [0 0 0];
    el.msgfontcolour = 0;
    EyelinkUpdateDefaults(el);

    if ~EyelinkInit() % 1 means enable dummy mode
        fprintf('Eyelink Init aborted.\n');
        Eyelink('Shutdown');
        Screen('CloseAll');
    end

    Eyelink('command', 'screen_pixel_coords = %ld %ld %ld %ld', 0, 0, rect(4)-1, rect(3)-1);

    % Link to edf data
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT'); WaitSecs(0.05);
    Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT,HTARGET'); WaitSecs(0.05);

    % Link data to Matlab
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT'); WaitSecs(0.05);
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT,HTARGET'); WaitSecs(0.05);
    Eyelink('command', 'link_event_data = GAZE,GAZERES,HREF,AREA,VELOCITY'); WaitSecs(0.05);

    edfFile = [answer1{1} '_PR_' answer1{2} '.edf'];
    Eyelink('Openfile', edfFile);

    Eyelink('command', 'calibration_type = HV6'); WaitSecs(0.05);
    % Before recording, we place reference graphics on the host display
    % Must be offline to draw to EyeLink screen
    Eyelink('Command', 'set_idle_mode'); WaitSecs(0.05);

    EyelinkDoTrackerSetup(el); WaitSecs(0.05);

    trigger_test = 1;

    % Top left pixel that controls triggers in PixelMode
    if trigger_test == 0
        trigRect = [0 0 1 1];
        %centeredRect_trigger = CenterRectOnPointd(trigRect, 0.5, 0.5);
    elseif trigger_test == 1
        trigRect = [0 0 100 100];
        %centeredRect_trigger = CenterRectOnPointd(trigRect, 25, 25);
    end


    Screen('FillRect', w, black, trigRect);
    Screen('Flip', w);


    Datapixx('EnablePixelMode');  % to use topleft pixel to code trigger information, see https://vpixx.com/vocal/pixelmode/
    Datapixx('RegWr');


    % KEYBOARD SETUP
    responseKeys = {'c', 'v', 'a', 'y', 'n', 'return'}; % eyelink commands
    KbName('UnifyKeyNames');
    KbCheckList = [KbName('space'), KbName('ESCAPE'), KbName('leftarrow'), KbName('rightarrow')];
    for i = 1:length(responseKeys)
        KbCheckList = [KbName(responseKeys{i}), KbCheckList];
    end
    RestrictKeysForKbCheck(KbCheckList);
    ListenChar(-1)

    % Define trigger pixels for all usable MEG channels
    trig.ch224 = [4  0  0]; %224 meg channel
    trig.ch225 = [16  0  0];  %225 meg channel
    trig.ch226 = [64 0 0]; % 226 meg channel
    trig.ch227 = [0  1 0]; % 227 meg channel
    trig.ch228 = [0  4 0]; % 228 meg channel
    trig.ch229 = [0 16 0]; % 229 meg channel
    trig.ch230 = [0 64 0]; % 230 meg channel
    trig.ch231 = [0 0  1]; % 231 meg channel

    % Clear the screen with the background color (white)
    Screen('FillRect', w, [255 255 255]);
    Screen('FillRect', w, black, trigRect);
    Screen('Flip', w);


    if mod(DEMO.num,2) == 0 % if 0 -> even number
        stim_set = 'SET1';
    else                    % if 1 -> odd number
        stim_set = 'SET2';

    end

    stim_dir = dir(fullfile(stim_set, '*.jpg'));
    stim_fn = {stim_dir.name};

    quest_dir_fn = 'QuestImages';
    quest_dir = dir(fullfile(quest_dir_fn, '*.jpg'));
    quest_fn = {quest_dir.name};
    quest_fn = quest_fn(randperm(length(quest_fn)));

    CP_table;

    % START EXPERIMENT
    Screen('DrawText', w, 'PRESS SPACE TO START',  wx-150, wy, [0 0 0]);
    Screen('FillRect', w, black, trigRect);
    Screen('Flip', w);
    KbWait([], 2)

    % Trigger 1
    Screen('FillRect', w, trig.ch224, trigRect);
    Screen('Flip', w);
    Screen('FillRect', w, black, trigRect);
    Screen('Flip', w);

    Eyelink('Command', 'SetOfflineMode');
    Eyelink('StartRecording');
    Screen('FillOval', w, fixColor, fixRect);
    Screen('FillRect', w, fixColor, trigRect);
    Screen('Flip', w);
    WaitSecs(2);
    trig.SYNCTIMEsecs = GetSecs();
    Eyelink('Message', 'TRIGGER %d', trig.SYNCTIME);
    eyeUsed = Eyelink('EyeAvailable');
    eyeUsed = eyeUsed + 1;

    goodTrial = 1;
    nBadTrials = 0;
    i_trial = 1;
    numTrials = size(expTable, 1);
    questIdx = 1;






    while i_trial <= size(expTable, 1)

        preview_fn = [stim_set '_unconnect_' num2str(expTable.connection(i_trial)) '_crowd_' num2str(expTable.crowding(i_trial)) '_' num2str(i_trial), '.jpg'];
        disp('DEBUG 1')

        imageFilePath = fullfile(stim_set, preview_fn);

        if exist(imageFilePath, 'file')

            previewMatrix = imread(imageFilePath);
            previewTexture = Screen('MakeTexture', w, previewMatrix);
            targetTexture = previewTexture;

            % Trial settings for question/response
            question_fn = ['img_' num2str(i_trial) '.jpg'];
            % questRect = CenterRectOnPoint([0 0 size(previewMatrix, 1)*2 size(previewMatrix, 2)], wx , wy);

            if expTable.preview(i_trial) == 0
                previewTexture = Screen('MakeTexture', w, fliplr(previewMatrix));
            end
            expTable.imageFn{i_trial} = preview_fn;

            if expTable.questionType(i_trial) == 0
                questionTexture = targetTexture;

            else
                if questIdx <= length(quest_fn)
                    selectedTexture = quest_fn{questIdx};
                    selectedTextureMatrix = imread(fullfile(quest_dir_fn, selectedTexture));
                    questionTexture = Screen('MakeTexture', w, selectedTextureMatrix);
                    questIdx = questIdx + 1;
                end
            end

            % % OFFSCREEN WINDOWS
            wFixation = Screen('OpenOffscreenWindow', w, 255);
            % fixRect = CenterRectOnPoint([0, 0, fixRadius*2, fixRadius*2], wx, wy);
            Screen('FillOval', wFixation, black, fixRect);

            wPreview = Screen('OpenOffscreenWindow', w, 255);
            previewRect = CenterRectOnPoint([0 0 size(previewMatrix, 1) size(previewMatrix, 2)], wx+ saccadeOffset*expTable.side(i_trial), wy);
            Screen('FillOval', wPreview, black, fixRect);
            Screen('DrawTexture', wPreview, previewTexture, [], previewRect);

            wCue = Screen('OpenOffscreenWindow', w, 255);
            cueRect = CenterRectOnPoint([0 0 size(previewMatrix, 1) size(previewMatrix, 2)], wx+ saccadeOffset*expTable.side(i_trial), wy);
            Screen('FillOval', wCue, fixColorCue, fixRect);
            Screen('DrawTexture', wCue, previewTexture, [], cueRect);

            wTarget = Screen('OpenOffscreenWindow', w, 255);
            Screen('FillOval', wTarget, fixColorCue, fixRect);
            Screen('DrawTexture', wTarget, targetTexture, [], previewRect);

            wQuestion = Screen('OpenOffscreenWindow', w, 255);
            questRect = CenterRectOnPoint([0 0 size(previewMatrix, 1) size(previewMatrix, 2)], wx, wy);
            Screen('DrawTexture', wQuestion, previewTexture, [], questRect);
            Screen('DrawText', wQuestion, 'yes', wx - 305, wy + 150, black);
            Screen('DrawText', wQuestion, 'no', wx + 305, wy + 150, black);

            % ITI
            Screen('DrawTexture', w, wFixation);
            Screen('FillRect', w, black, trigRect);
            Screen('Flip', w);
            %
            %     if nBadTrials > 10
            %         nBadTrials = 0;
            %         repeat calibration
            %         Eyelink('StopRecording');
            %         Eyelink('Command', 'set_idle_mode');
            %         EyelinkDoTrackerSetup(el);
            %         Eyelink('StartRecording');
            %         Datapixx('DisablePixelMode');
            %         Datapixx('RegWr');
            %         Datapixx('Close');
            %     end
            %     WaitSecs(1);



            % FIXATION
            goodTrial = 1;
            errorMsg = 'BAD TRIAL';
            Screen('FillOval', w, black, fixRect);
            WaitSecs(2);
            Screen('FillRect', w, black, trigRect);
            Screen('Flip', w);

            fixOnsetTime = GetSecs();
            expTable.fixStartTime(i_trial) = GetSecs();
            Eyelink('Message', 'TRIGGER %d', trig.START);
            expTable.fixDuration(i_trial) = (1000+randperm(500,1))/1000; % random fixation duration
            eyeX = nan; eyeY = nan;
            disp('DEBUG 3')



            %     Datapixx('DisablePixelMode');
            %     Datapixx('RegWr');
            %
            %     Datapixx('SetPropixxDlpSequenceProgram', 0);
            %     Datapixx('RegWr');

            while goodTrial
                [~,~, keyCode] = KbCheck();
                if find(keyCode) == KbName('escape')
                    ShowCursor()
                    RestrictKeysForKbCheck([]);
                    Screen(w,'Close');
                    sca;
                    ListenChar(0)
                    return;
                end

                if Eyelink('NewFloatSampleAvailable')
                    eyeSample = Eyelink('NewestFloatSample');
                    eyeX = eyeSample.gx(eyeUsed);
                    eyeY = eyeSample.gy(eyeUsed);

                    if eyeX~=el.MISSING_DATA && eyeY~=el.MISSING_DATA % no blinks
                        dist_center = sqrt( (eyeX-wx)^2 + (eyeY-wy)^2 );
                        if dist_center < fixTolerance % fixation is good
                            if GetSecs() - expTable.fixStartTime(i_trial) > expTable.fixDuration(i_trial) % fixation is long enough
                                break;
                            end
                        else
                            for i=1:3
                                Screen('FillRect', w, fixBadColor, fixRect);
                                Screen('Flip', w);
                                WaitSecs(.1);
                                Screen('Flip', w);
                                WaitSecs(.1);
                            end
                            Screen('FillOval', w, fixColor, fixRect);
                            Screen('FillRect', w, trig.ch224, trigRect);
                            Screen('Flip', w);
                            Screen('DrawTexture', w, wPreview);
                            Screen('FillRect', w, fixColor, trigRect);
                            Screen('Flip', w);

                            expTable.fixStartTime(i_trial) = GetSecs();
                            Eyelink('Message', 'TRIGGER %d', trig.START);
                        end
                    else % blink
                        expTable.fixStartTime(i_trial) = GetSecs();
                        Eyelink('Message', 'TRIGGER %d', trig.START);

                    end
                end

                if GetSecs() - fixOnsetTime > 10
                    errorMsg = 'BAD FIXATION';
                    Eyelink('StopRecording');
                    EyelinkDoTrackerSetup(el);
                    Eyelink('StartRecording');
                    goodTrial = 0;

                end
            end


            %     Datapixx('DisablePixelMode');
            %     Datapixx('RegWr');

            % preview Trigger 2

            Screen('DrawTexture', w, wPreview);
            Screen('FillRect', w, trig.ch225, trigRect);
            Screen('Flip', w);
            Screen('DrawTexture', w, wPreview);
            Screen('FillRect', w, black, trigRect);
            Screen('Flip', w);

            expTable.previewOnsetTime(i_trial) = GetSecs();
            Eyelink('Message', 'TRIGGER %d', trig.PREVIEW);

            saccTrigger = 0;

            while goodTrial
                [~,~, keyCode] = KbCheck();
                if find(keyCode) == KbName('escape')
                    ShowCursor()
                    RestrictKeysForKbCheck([]);
                    Screen(w,'Close');
                    sca;
                    ListenChar(0)
                    return;
                end

                if Eyelink('NewFloatSampleAvailable')
                    eyeSample = Eyelink('NewestFloatSample');
                    eyeX = eyeSample.gx(eyeUsed);
                    eyeY = eyeSample.gy(eyeUsed);

                    if eyeX~=el.MISSING_DATA && eyeY~=el.MISSING_DATA % no blinks
                        dist_center = sqrt( (eyeX-wx)^2 + (eyeY-wy)^2 );
                        if dist_center < fixTolerance % fixation is good
                            if GetSecs() - expTable.fixStartTime(i_trial) > expTable.fixDuration(i_trial)+.5 % fixation is long enough
                                Screen('DrawTexture', w, wCue);
                                Screen('FillRect', w, trig.ch226, trigRect);
                                Screen('Flip', w);
                                Screen('DrawTexture', w, wCue);
                                Screen('FillRect', w, black, trigRect);
                                Screen('Flip', w);
                                WaitSecs(2)
                                break;
                            end
                        else
                            goodTrial = 0;
                        end
                    else % blink
                        goodTrial = 0;
                    end
                end
            end


            Eyelink('Message', 'TRIGGER %d', trig.SACCADE);
            Screen('FillRect', w, trig.ch227, trigRect);
            Screen('Flip', w);
            Screen('FillRect', w, black, trigRect);
            Screen('Flip', w);

            while goodTrial
                % detect saccadeOnset with threshold
                if Eyelink('NewFloatSampleAvailable')
                    eyeSample = Eyelink('NewestFloatSample');
                    newEyeX = eyeSample.gx(eyeUsed) - eyeX;
                    eyeX = newEyeX;
                    disp(['EyeX: ', num2str(eyeX)]); % Debugging output

                    if abs(newEyeX) > saccThreshold % if neeyeX > over the imaginary boundary
                        saccTrigger = saccTrigger+1;
                        if saccTrigger>1
                            expTable.saccadeOnsetTime(i_trial) = GetSecs();
                            saccadeOnsetTimeMEG = Datapixx('GetMarker');
                            disp('Saccade detected'); % Debugging output

                            break;
                        end
                    else
                        saccTrigger=0;
                    end
                end
            end

            % TARGET
            Screen('DrawTexture', w, wTarget);
            Screen('FillRect', w, trig.ch228, trigRect);
            Screen('Flip', w);
            Screen('DrawTexture', w, wTarget);
            Screen('FillRect', w, black, trigRect);
            Screen('Flip', w);

            expTable.targetOnsetTime(i_trial) = GetSecs();
            Eyelink('Message', 'TRIGGER %d', trig.TARGET);

            while goodTrial
                [~, ~, keyCode] = KbCheck();
                if find(keyCode) == KbName('escape')
                    ShowCursor();
                    RestrictKeysForKbCheck([]);
                    Screen('CloseAll');
                    sca;
                    ListenChar(0);
                    return; % Exit the script
                elseif Eyelink('NewFloatSampleAvailable')
                    eyeSample = Eyelink('NewestFloatSample');
                    eyeX = eyeSample.gx(eyeUsed);
                    eyeY = eyeSample.gy(eyeUsed);

                    if eyeX~=el.MISSING_DATA && eyeY~=el.MISSING_DATA % if there are no blinks
                        % dist_target = sqrt( (eyeX- (wx+saccadeOffset*expTable.side(i_trial)) )^2 + (eyeY-wy)^2 );
                        dist_target = eyeX - (wx+saccadeOffset*expTable.side(i_trial));
                        disp(['dist_target: ', num2str(dist_target)]);
                        if dist_target < fixTolerance % and the saccade landed inside the word
                            if GetSecs() - expTable.targetOnsetTime(i_trial) > targetDuration % and they fixated the word long enough
                                break;
                            end
                        else
                            errorMsg = 'BAD SACCADE';
                            goodTrial = 0;
                        end
                    else % blink
                        errorMsg = 'BAD BLINK';
                        goodTrial = 0;
                    end
                end
            end




            % Question
            Screen('DrawTexture', w, wQuestion);
            Screen('FillRect', w, trig.ch229, trigRect);
            Screen('Flip', w);
            Screen('DrawTexture', w, wQuestion);
            Screen('FillRect', w, black, trigRect);
            Screen('Flip', w);

            expTable.questionOnsetTime(i_trial) = GetSecs();
            questionOnsetTimeMEG = Datapixx('GetMarker');
            % expTable.responseOnsetTime(i_trial) = GetSecs();

            if goodTrial
                nBadTrials = 0;
                %         [ResponseTime, keyCode] = KbWait([], 2);
                [response, ResponseTime] = getButton();
                if ResponseTime - expTable.questionOnsetTime(i_trial) > 1.5 % slow response
                    Screen('DrawText', w, 'TOO SLOW !!',  wx - 150, wy, [0 0 0]);
                    Screen('Flip', w); WaitSecs(2);
                    errorMsg = 'SLOW RT';
                    Eyelink('Message', ['BAD :' errorMsg]);
                    expTable(end + 1, :) = expTable(i_trial, :);
                    expTable(i_trial, :) = [];
                    nBadTrials = nBadTrials + 1;
                    Eyelink('command', ['record_status_message "TRIAL BAD :' errorMsg '" ']);
                elseif find(keyCode) == KbName('escape') % exit response
                    ShowCursor();
                    RestrictKeysForKbCheck([]);
                    Screen('CloseAll');
                    sca;
                    ListenChar(0);
                    return; % Exit the script

                elseif response == 8 || response == 9 %good response 8 is yellow (yes)/ 9 is red (no)
                    Eyelink('Message', 'TRIGGER %d', trig.RESPONSE);


                    % Response correctness
                    % if keyCode(KbName('y'))
                    %     response = num2str('y');
                    % elseif keyCode(KbName('n'))
                    %     response = num2str('n');
                    % end

                    expTable.response(i_trial) = response;
                    expTable.responseOnsetTime(i_trial) = ResponseTime;

                    if (targetTexture == questionTexture && response == 8) || (targetTexture ~= questionTexture && response == 9)
                        expTable.correctness(i_trial) = 1; % response correct
                    else
                        expTable.correctness(i_trial) = 0; % response not correct
                    end

                    Eyelink('Message',  ['COND ' num2str(expTable.preview(i_trial)) num2str(expTable.side(i_trial)+1) num2str(expTable.crowding(i_trial))]);

                    i_trial = i_trial + 1;
                    Eyelink('command', 'record_status_message "TRIAL %d/%d"', i_trial, size(expTable, 1));
                end
            else
                disp(errorMsg)
                Eyelink('Message', ['BAD :' errorMsg]);
                expTable(end + 1, :) = expTable(i_trial, :);
                expTable(i_trial, :) = [];
                nBadTrials = nBadTrials + 1;
                Eyelink('command', ['record_status_message "TRIAL BAD :' errorMsg '" ']);
            end
        end
    end

    Screen('DrawText', w, 'GoodBye',  wx-150, wy, [0 0 0]);
    Screen('FillRect', w, black, trigRect);
    Screen('Flip', w);
    KbWait([], 2)

    Datapixx('DisablePixelMode');
    Datapixx('RegWr');
    Datapixx('Close');

    % SAVE DATA
    EXP.DEMO = DEMO;
    EXP.data = expTable;
    EXP.trig = trig;
    EXP.stim = stim_fn;
    save([answer1{1} '_PREVIEW_' answer1{2} '.mat'], 'EXP')

    % SAVE EYE DATA
    Eyelink('StopRecording');
    Eyelink('CloseFile');
    Eyelink('ReceiveFile');
    Eyelink('ShutDown');

    Datapixx('DisablePixelMode');
    Datapixx('RegWr');
    Datapixx('Close');

    % FINISH EXPERIMENT
    ShowCursor();
    RestrictKeysForKbCheck([]);
    Screen('CloseAll');
    sca;
    ListenChar(0);

catch
    % FINISH EXPERIMENT
    ShowCursor();
    RestrictKeysForKbCheck([]);
    Screen('CloseAll');
    sca;
    ListenChar(0);
    rethrow(lasterror);
end





