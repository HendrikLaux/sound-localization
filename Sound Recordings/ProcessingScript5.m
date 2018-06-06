clear all;

%% Processing script for the "ideal measurement" recordings

% Remember to lower the quality of the recorded signal BEFORE cutting to 
% the relevant part, thresholding is one of the things most affected by 
% worse quality!

%% Initialization

% settings
cutlength = 10000; % number of samples to cut out
threshFactor = 20; % factor to multiply the mean absolute noise level with (Tresholding possibility 1)

% load data (sets 4 and 5 contain some "bad to handle" erroneous signals, 1,2,3 and 6 not)
Pos1 = load('DeskPosition1.mat');
Pos1D = load('DeskPosition1Disturbance.mat');
Pos2 = load('DeskPosition2.mat');
Pos3 = load('DeskPosition3.mat');
Pos6 = load('DeskPosition6.mat');

% create sound matrix
for k = 1:20
    uncutSound(k,:) = Pos1.recordings(k).sound;
    uncutSound(20+k,:) = Pos2.recordings(k).sound;
    uncutSound(40+k,:) = Pos3.recordings(k).sound;
    uncutSound(60+k,:) = Pos6.recordings(k).sound;
    uncutSound(80+k,:) = Pos1D.recordings(k).sound;% + 0.006*randn(88200,1);
end

% debugging: plot uncut signals
% figure(5)
% hold all;
% for k = 61:80
%     plot([1:88200]./44100, uncutSound(k,:));
% end
% legend(num2str((1:20)'));
    
%% Preprocessing

for r = 1:100
   disp(num2str(r));
   recording = uncutSound(r, :);
    
    
   % --- Thresholding possibility 1: mean absolute noise level ----
   
    % for(k = 1:length(recording)) % cut silence out
    %    if recording(k) > 1e-10
    %        break
    %    end
    % end
    
   % determine mean base noise level assuming minimum 100msec delay between
   % recording and playback
   
   % MBNL = 1/4410*sum(abs(recording(k:k+4410)));
   %    thresh = threshFactor*MBNL; % cut threshold
   
   % --- Thresholding possibility 2: max peak ---
   
   % Threshold the signal right before the highest peak (works better than
   %                                                        method 1)
   mx = max(recording);
   thresh = 0.9*mx; % cut threshold
   
   % Cut signal
   
   for k = 1:length(recording)
       if recording(k) > thresh
           if(k+cutlength > length(recording))
              disp('Could not threshold signal');
              break;
           end
           recording = recording(k:k+cutlength-1);
           cutsounds(r,:) = recording;
           break
       end
   end
 
end

%% PLOTS

% Uncomment for reflection changing disturbance simulation
%cutsounds(82,2000:3000) = cutsounds(82,2000:3000) + 1*cutsounds(82,3000:4000);
%cutsounds(82,150:650) = cutsounds(82,150:650) + 1*cutsounds(82,1000:1500);



% PCA
color = {'rx', 'g+', 'bd', 'k*', 'm.'};
[COEFF, SCORE, LATENT] = pca(cutsounds);
   
figure(20);
hold all;
for k = 1:5
   for r = 1:20
      scatter(SCORE((k-1)*20+1:k*20,1), SCORE((k-1)*20+1:k*20,2), color{k});
   end
end
xlabel('1st Principle Component');
ylabel('2nd Principle Component');
%legend('Position 1', 'Position 2', 'Position 3', 'Position 4');

% TIME SERIES

figure(10)
xlabel('Time (Seconds)');
ylabel('Amplitude');
hold all;
color = {'k', 'k', 'k', 'k', 'k'};
for k = 1:5
   for r = 1:20
      subplot(5,1,k); % TODO: Common x-Axis
      hold all
      plot([1:cutlength]./44100, cutsounds((k-1)*20+r,:), color{k});
      ylim([-0.03 0.03]);
   end
end
