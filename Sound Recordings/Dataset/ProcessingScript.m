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
Pos2 = load('DeskPosition2.mat');
Pos3 = load('DeskPosition3.mat');
Pos6 = load('DeskPosition6.mat');

% create sound matrix
for k = 1:20
    uncutSound(k,:) = Pos1.recordings(k).sound;
    uncutSound(20+k,:) = Pos2.recordings(k).sound;
    uncutSound(40+k,:) = Pos3.recordings(k).sound;
    uncutSound(60+k,:) = Pos6.recordings(k).sound;
end

% debugging: plot uncut signals
% figure(5)
% hold all;
% for k = 61:80
%     plot([1:88200]./44100, uncutSound(k,:));
% end
% legend(num2str((1:20)'));
    
%% Preprocessing

for r = 1:80
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


% TIME SERIES

figure(10)
hold all;
color = ['r', 'g', 'b', 'k'];
for k = 1:4
   for r = 1:20
      plot([1:cutlength]./44100, cutsounds((k-1)*20+r,:), color(k));
   end
end
xlabel('time');
ylabel('amplitude');
title('Thresholded signals');

% PCA

[COEFF, SCORE, LATENT] = pca(cutsounds);
   
figure(20);
hold all;
for k = 1:4
   for r = 1:20
      scatter(SCORE((k-1)*20+1:k*20,1), SCORE((k-1)*20+1:k*20,2), color(k));
   end
end
xlabel('Principle Component 1');
ylabel('Principle Component 2');

