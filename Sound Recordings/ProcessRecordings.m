left = load('DeskPosition1.mat');
right = load('DeskPosition2.mat');

cutlength = 10000; % in samples
recAmount = length(right.recordings) + length(left.recordings)

sounds = zeros(recAmount, length(left.recordings(1).sound));
cutsounds = zeros(recAmount, cutlength);

for lr = 1:length(left.recordings)
    sounds(lr,:) = left.recordings(lr).sound;
end
for rr = 1:length(right.recordings)
    sounds(lr+rr, :) = right.recordings(rr).sound;
end


for r = 1:recAmount
   % determine base noise variance assuming minimum 100msec delay between
   % recording and playback
   recording = sounds(r, :);
   
   for(k = 1:length(recording)) % cut silence out
       if recording(k) > 1e-10
           break
       end
   end
   
   % mean absolute noise level
   MANL = 1/4410*sum(abs(recording(k:k+4410)));
   thresh = 7*MANL; % cut threshold
   
   for k = 1:length(recording)
       if abs(recording(k)) > thresh
           recording = recording(k:k+cutlength-1);
           break
       end
   end
   
   cutsounds(r,:) = recording;
    
end

%% Time Series

figure(19);
hold all;
for r = 1:20
    plot(cutsounds(r,:), 'b')
end
for r = 21:40
    plot(cutsounds(r,:), 'g')
end

%% PCA

figure(20);
[COEFF, SCORE, LATENT] = pca(cutsounds);
hold all
scatter(SCORE(1:20,1), SCORE(1:20,2));
scatter(SCORE(21:40,1), SCORE(21:40,2));

