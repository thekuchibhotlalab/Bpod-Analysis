% load data
filez = dir('/Users/sarahelnozahy/Documents/KF003/*.mat'); % load all of files 
numFiles = length(filez); % number of files
filenames = strings(numFiles,1); % create empty string array for file names
rate = zeros(4,1); rate = rate'; % intialize empty array for outcome rates
probeRate = zeros(4,1); probeRate = probeRate'; % intialize empty array for probe outcome rates
outcome = []; probe = []; % initalize arrays holding all outcome and probe nums t
total = []; session = []; trialType =[];
for i= 1:numFiles
    hit = 0; miss = 0; correctReject = 0; falseAlarm = 0;  % initialize outcome variables for each session
    probeHit = 0; probeMiss = 0; probeCorrectReject = 0; probeFalseAlarm = 0; % initalize probe outcome variables for each session
    filenames(i) = strcat('/Users/sarahelnozahy/Documents/KF003/', filez(i).name); % increment through each file
    load(filenames(i)); % load each file
    temp = []; % temp holds num for each outcome
    probeTemp = []; % probe temp holds num for each outcome 
    totalTemp = []; sessionNum = []; trialTypeTemp = [];
    SessionData.nTrials = SessionData.nTrials-20;
    for j =20:SessionData.nTrials % increment through all the trials in one given session
        sessionNum(j,:) = i;
        if SessionData.TrialTypes(1,j) == 3 || SessionData.TrialTypes(1,j) == 4 % probe trials (in future data, this is distinguished by trial type (3 and 4))   
            trialTypeTemp(j,:) = 2;
            if ~isnan(SessionData.RawEvents.Trial{1,j}.States.OpenValve) % probe hit state
                probeTemp(j,:) = 1;
                totalTemp(j,:) = 1;
                probeHit = probeHit+1;
                probeRate = ([((probeHit/(probeHit+probeMiss))*100) ((probeMiss/(probeHit+probeMiss))*100) probeRate(3) probeRate(4)]);
            elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.Miss) % probe miss state
                probeTemp(j,:) = 2;
                totalTemp(j,:) = 2;
                probeMiss = probeMiss+1;
                probeRate = ([((probeHit/(probeHit+probeMiss))*100) ((probeMiss/(probeHit+probeMiss))*100) probeRate(3) probeRate(4)]);
            elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.CorrectReject) % probe cr state
                probeTemp(j,:) = 3; 
                totalTemp(j,:) = 3;
                probeCorrectReject = probeCorrectReject+1;
                probeRate = ([probeRate(1) probeRate(2) ((probeCorrectReject/(probeCorrectReject+probeFalseAlarm))*100) ((probeFalseAlarm/(probeCorrectReject+probeFalseAlarm))*100)]);
            elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.Punish) % probe punish state
                probeTemp(j,:) = 4;
                totalTemp(j,:) = 4;
                probeFalseAlarm = probeFalseAlarm+1;
                probeRate = ([probeRate(1) probeRate(2) ((probeCorrectReject/(probeCorrectReject+probeFalseAlarm))*100) ((probeFalseAlarm/(probeCorrectReject+probeFalseAlarm))*100)]);
            end
            probeTemp = nonzeros(probeTemp); % get rid of all 0's (anything not in probe)
        elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.OpenValve) % reinforced hit state
            trialTypeTemp(j,:) = 1;

            temp(j,:) = 1;
            totalTemp(j,:) = 1;
            hit = hit +1;
            rate = ([((hit/(hit+miss))*100) ((miss/(hit+miss))*100) rate(3) rate(4)]); 
        elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.Miss) % reinforced miss state
            trialTypeTemp(j,:) = 1;

            temp(j,:) = 2;
            totalTemp(j,:) = 2;
            miss = miss +1;
            rate = ([((hit/(hit+miss))*100) ((miss/(hit+miss))*100) rate(3) rate(4)]);
        elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.CorrectReject) % reinforced cr state
            trialTypeTemp(j,:) = 1;
           
            temp(j,:) = 3;
            totalTemp(j,:) = 3;
            correctReject = correctReject+1;
            rate = ([rate(1) rate(2) ((correctReject/(correctReject+falseAlarm))*100) ((falseAlarm/(correctReject+falseAlarm))*100)]);
        elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.Punish) % reinforced fa state
            trialTypeTemp(j,:) = 1;
           
            temp(j,:) = 4;
            totalTemp(j,:) =4;
            falseAlarm = falseAlarm +1;
            rate = ([rate(1) rate(2) ((correctReject/(correctReject+falseAlarm))*100) ((falseAlarm/(correctReject+falseAlarm))*100)]);
        end
    end % end for one session
temp = nonzeros(temp); % get rid of all 0's (anything not in probe)
trialTypeTemp = nonzeros(trialTypeTemp);
totalTemp = nonzeros(totalTemp);
sessionNum = nonzeros(sessionNum);
trialType = [trialType; trialTypeTemp];
session = [session; sessionNum]; 
total = [total;totalTemp];
outcome = [outcome; temp]; % concatenate all reinforced nums from all trials
probe = [probe; probeTemp]; % concatenate all probe nums from all trials
end
hit = 0; miss= 0; cr =0; fa=0;
phit = 0; pmiss = 0; pcr = 0; pfa =0;
% outcome = outcome(1:5700); % cut array into 6700 trials instead of 6707
% probe = probe(1:360);
% outcome = reshape(outcome, 100, 57); % separate into bins of 100
% probe = reshape(probe, 20, 18); % separate into bins of 100
numHits = []; numMisses = []; hitRate = [];  
numphits = []; numpmisses = []; probeHitRate = [];
numCRs = []; numFAs = []; faRate = [];
numpcrs =[]; numpfas = []; probeFARate = [];
for r = 1:57 % through all cols of total reinforcement outcomes
    col = outcome(:,r); % each col
    for d = 1:100 % through all rows of each col
        if col(d) == 1
            hit = hit +1;
        elseif col(d) == 2
            miss = miss +1;
        elseif col(d) == 3
            cr = cr+1;
        elseif col(d) ==4
            fa = fa+1;
        end
    end
    numHits(r) = hit; numMisses(r) = miss; % num of hits and misses in each 100 block
    hitRate(r) = [(numHits(r)/(numHits(r)+numMisses(r)))*100]; % hit rate per 100 block
    numCRs(r) = cr;numFAs(r) = fa; % num of Crs and FAs in each 100 block
    faRate(r) = [(numFAs(r)/(numCRs(r)+numFAs(r)))*100];  % false alarm rate per 100 block
    hit = 0; miss = 0; cr = 0; fa = 0; % clear outcome vars after 100
end
for m = 1:18 % through all cols of probe outcomes
    col = probe(:, m); % each col
    for k = 1:20 % through all rows of each col
        if col(k) == 1
            phit = phit +1;
        elseif col(k) == 2
            pmiss = pmiss +1;
        elseif col(k) == 3
            pcr = pcr+1;
        elseif col(k) == 4
            pfa = pfa+1;
        end
    end
    numphits(m) = phit; numpmisses(m) = pmiss;
    probeHitRate(m) = [(numphits(m)/(numphits(m)+numpmisses(m)))*100];
    numpcrs(m) = pcr; numpfas(m) = pfa;
    probeFARate(m) = [(numpfas(m)/(numpcrs(m)+numpfas(m)))*100]; 
    phit = 0; pmiss = 0; pcr = 0; pfa = 0; % clear outcome vars after 100 
end
figure('name','KF003 Analysis','Position', [1250 100 500 600]); % create figure for plots
smoothsize = 5; % size of smoothed line
x = 20:20:360; % HEREEEE
y = 100:100:5700;

subplot(211);
plot(y, hitRate, 'color', 'g');  hold on;
plot(y, faRate, 'color', 'r'); hold on;
plot(y, movmedian(hitRate,smoothsize),'Color','g','LineWidth',5); hold on; % smoothed line 
plot(y, movmedian(faRate,smoothsize),'Color','r','LineWidth',5); % smoothed line
xlabel('Trials'); ylim([0 110]); ylabel('Rate %'); xlim([0 5800]);% set x-axis  
title('Average learning trajectories in reinforced');
subplot(212);
plot(x, probeHitRate, 'color', 'g');  hold on;
plot(x, probeFARate, 'color', 'r'); hold on;
plot(x, movmedian(probeHitRate,smoothsize),'Color','g','LineWidth',5); hold on; % smoothed line 
plot(x, movmedian(probeFARate,smoothsize),'Color','r','LineWidth',5); % smoothed line
xlabel('Trials'); ylim([0 110]); ylabel('Rate %'); xlim([0 370]);% set x-axis  
title('Average learning trajectories in probe');
