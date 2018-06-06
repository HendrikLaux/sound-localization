clear all;

%% Script to obtain recordings of a real world localization scenario
% It is assumed, that the desired recording device is the standard
% recording device of you system.
% Specify the desired recording session delay, play-record-delay and record
% length/amount


%% Initialization
% recording sessions delay: wait xx seconds before starting the entire
% session (to move out of range)
RSD = 20;

% play-recording delay: wait xx seconds to play the sound after the
% recording has started
PRD = 0.25;

% record length: record each sound for xx seconds
RLength = 2;

% amount of recordings:
amount = 20;

% label for recordings:
label = 'Floor: Position 2';

% ID/Filename:
Filename = 'FloorPosition2';

% sound to play
%stimulation = audioread('example.wav');
stimulation = zeros(1000,1);
stimulation(1:100) = 1;
%stimulation = randn(22000,1);

% decide to plot all results
plt = 1;

%% Script

% this part requires no specification by the user
recDevice = audiorecorder(44100, 24, 1, -1);

pause(RSD)

for r = 1:amount
    disp(['Perform recording ' num2str(r)]);
    recordings(r).label = label;
    recordings(r).recNumber = r;
    recordings(r).SampleRate = 44100;

    record(recDevice,RLength)
    
    pause(PRD);
    
    sound(stimulation);
    
    pause(RLength-PRD + 0.2)

    recordings(r).sound = getaudiodata(recDevice);
end

save(Filename, 'recordings');

if(plt == 1)
   figure(10);
   hold all;
   
   for r = 1:amount
       s = recordings(r).sound;
       sr = recordings(r).SampleRate;
       plot([1:length(s)]./sr, s');
   end
    
    
end