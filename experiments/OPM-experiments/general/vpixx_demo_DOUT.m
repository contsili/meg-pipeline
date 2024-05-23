function DatapixxDoutBasicDemo()
% DatapixxDoutBasicDemo()
%
% Demonstrates the basic functions of the DATAPixx TTL digital outputs.
% Prints the number of TTL outputs in the system,
% then waits for keypresses to:
%   -Set digital output 0 high
%   -Set all digital outputs high
%   -Bring all digital outputs back low
%
% Also see: DatapixxDoutTriggerDemo
%
% History:
%
% Oct 1, 2009  paa     Written
% Oct 29, 2014 dml     Revised

AssertOpenGL;   % We use PTB-3

% Open Datapixx, and stop any schedules which might already be running
Datapixx('Open');
Datapixx('StopAllSchedules');
Datapixx('RegWrRd');    % Synchronize DATAPixx registers to local register cache

% Show how many TTL output bits are in the Datapixx
nBits = Datapixx('GetDoutNumBits');
fprintf('\nDATAPixx has %d TTL output bits\n\n', nBits);


% Bring a counter number of bits high
HitKeyToContinue('\nHit any key to start an ascending counter signal on DOUT:');

% Initialize the counter
counter = 0;

% Loop until the counter reaches zero
while counter < 256
    % Display the current value of the counter
    disp(['Current counter value: ', num2str(counter)]);
    
    
    Datapixx('SetDoutValues', counter);
    Datapixx('RegWrRd');
    
    % Decrease the counter
    counter = counter + 1;
    
    % Pause for a short duration to observe the changes
    pause(1); % Pause for 10 milliseconds
end


% Bring 1 output high
HitKeyToContinue('\nHit any key to bring digital output bit 0 high:');
Datapixx('SetDoutValues', 1);
Datapixx('RegWrRd');


% Bring all the outputs high
HitKeyToContinue('\nHit any key to bring all the digital outputs high:');
Datapixx('SetDoutValues', (2^nBits) - 1);
Datapixx('RegWrRd');

% Bring all the outputs low
HitKeyToContinue('\nHit any key to bring all the digital outputs low:');
Datapixx('SetDoutValues', 0);
Datapixx('RegWrRd');

% Job done
Datapixx('Close');
fprintf('\n\nDemo completed\n\n');