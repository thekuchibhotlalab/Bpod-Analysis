%% load data
subj = 'KF002'; % INPUT SUBJECT NAME HERE 
subjectPath = strcat('/Users/sarahelnozahy/Documents/MATLAB/', subj, '/*.mat'); % may have to alter file path here and on line 9
file = dir(subjectPath); % load all of files 
numFiles = length(file); % number of files
filenames = strings(numFiles,1); % create empty string array for file names
outcome = []; session = []; context =[]; lever = []; lick = []; tone = []; trialNum = []; % initalize all vars
for i = 1:numFiles
    filenames(i) = strcat('/Users/sarahelnozahy/Documents/MATLAB/', subj, '/', file(i).name); % increment through each file
    load(filenames(i)); % load each file
    outcomeTemp = []; sessionNum = []; contextTemp = []; leverTemp = []; lickTemp = []; toneTemp = []; % initialize temp vars
    SessionData.nTrials = SessionData.nTrials-20; % get rid of last 20 trials
    for j= 20:SessionData.nTrials % increment through all the trials in one given session but get rid of first 20 trials
        % LICK LATENCY
        if ~isnan(SessionData.RawEvents.Trial{1,j}.States.Miss)
            lickTemp(j,:) = NaN;
        elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.CorrectReject)
            lickTemp(j,:) = NaN;
        else % if licking does occur during trial
            licking = SessionData.RawEvents.Trial{1,j}.Events.Port1In'; % times that lick occurs
            licking = licking - SessionData.RawEvents.Trial{1,j}.States.WaitForLick(1); % calculate difference from time point of beginning of response window
            licking = licking(licking>0); % take all positive times
            lickTemp(j,:) = licking(1); % take first lick 
        end % need to remove NaN's!!
        % RAW DATA
        sessionNum(j,:) = i; % session number data
        if SessionData.TrialTypes(1,j) == 3 || SessionData.TrialTypes(1,j) == 4 % probe trials (in future data, this is distinguished by trial type (3 and 4))   
            contextTemp(j,:) = 2; % add 2 for probe context
            if ~isnan(SessionData.RawEvents.Trial{1,j}.States.OpenValve) % probe hit state
                outcomeTemp(j,:) = 1; % add 1 for hit to total data 
                toneTemp(j,:) = 1; % add 1 for tone type (GO)
            elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.Miss) % probe miss state
                outcomeTemp(j,:) = 2; % add 2 for miss to total data
                toneTemp(j,:) = 1; % add 1 for tone type (GO)
            elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.CorrectReject) % probe cr state
                outcomeTemp(j,:) = 3; % add 3 for correct reject to total data
                toneTemp(j,:) = 2; % add 2 for tone type (NOGO)
            elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.Punish) % probe punish state
                outcomeTemp(j,:) = 4; % add 4 for false alarm to total data
                toneTemp(j,:) = 2; % add 2 for tone type (NOGO)
            end
        elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.OpenValve) % reinforced hit state
            contextTemp(j,:) = 1; % add 1 for reinforced context
            outcomeTemp(j,:) = 1; % add 1 for hit to total data 
            toneTemp(j,:) = 1; % add 1 for tone type (GO)
        elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.Miss) % reinforced miss state
            contextTemp(j,:) = 1; % add 1 for reinforced context
            outcomeTemp(j,:) = 2; % add 2 for miss to total data
            toneTemp(j,:) = 1; % add 1 for tone type (GO)
        elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.CorrectReject) % reinforced cr state
            contextTemp(j,:) = 1; % add 1 for reinforced context
            outcomeTemp(j,:) = 3; % add 3 for correct reject to total data
            toneTemp(j,:) = 2; % add 2 for tone type (NOGO)
        elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.Punish) % reinforced fa state
            contextTemp(j,:) = 1; % add 1 for reinforced context
            outcomeTemp(j,:) = 4; % add 4 for false alarm to total data
            toneTemp(j,:) = 2; % add 2 for tone type (NOGO)
        end
    end % through all trials of one session
sessionNum = nonzeros(sessionNum); session = [session; sessionNum]; % get rid of zero gaps, add session data to all
contextTemp = nonzeros(contextTemp); context = [context; contextTemp]; % get rid of zero gaps, add context data to all
toneTemp = nonzeros(toneTemp); tone = [tone; toneTemp]; % get rid of zero gaps, add tone data to all
outcomeTemp = nonzeros(outcomeTemp); outcome = [outcome; outcomeTemp]; % get rid of zero gaps, add outcome data to all
lickTemp = nonzeros(lickTemp); lick = [lick; lickTemp]; % get rid of zero gaps, add lick data to all
end % through one session
for h = 1:length(outcome) % number of trials for cell
    trialNum(h,:) = h;
end

% COMPILE ALL DATA
labels = {'Session' 'Trial' 'Context' 'Tone' 'LickResponse' 'LickLatency'}; % data labels
all = [session, trialNum, context, tone, outcome, lick]; % compile all of data
data =[labels;num2cell(all)]; % load data

% PROBE CALCULATIONS
transitions = diff(context); % check when transitions occur in context (from 1 to 2)
probeStarts = find(transitions == 1) +1; % overall trial number for probe start
probeEnds = find(transitions == -1); % overall trial number for probe end
probeTrials = [probeStarts, probeEnds]; % table of probe start and ends
probePoints = median(probeTrials,2); % average of each probe session for point on plot
probehit = 0; probemiss= 0; probecr =0; probefa=0; probehitRate = []; probefaRate = []; probeGraph = []; % initalize probe vars
for u = 1:length(probeTrials) % increment through each probe session
    probeBlock = data(probeTrials(u,1)+1:probeTrials(u,2)+1, 5); % compile outcome for each probe session
    for p = 1:length(probeBlock) % increment through each outcome in session
        if probeBlock{p} == 1 % hit
            probehit = probehit+1; 
        elseif probeBlock{p} == 2 % miss
            probemiss = probemiss+1;
        elseif probeBlock{p} == 3 % correct reject
            probecr = probecr +1;
        elseif probeBlock{p} == 4 % false alarm
            probefa = probefa +1;
        end
    end
    probehitRate(u,:) = [(probehit/(probehit+probemiss))*100]; % calculate probe hit rate
    probefaRate(u,:) = [(probefa/(probecr+probefa))*100]; % calculate probe false alarm rate
end
probeGraph = [probePoints, probehitRate, probefaRate]; % data for probe plotting

% REINFORCED CALCULATIONS
s1 = size(outcome, 1); % take all of outcome data
block  = s1 - mod(s1, 100); % split outcome data into bins of 100
bins  = reshape(outcome(1:block), 100, []); % reshape bins into blocks of 100
s2 = size(bins); % number of bins
hit = 0; miss= 0; cr =0; fa=0; hitRate = []; faRate = []; % initalize variables

for t = 1:s2(2) % through bins
    for l = 1:s2(1) % through trials in each bin
        if bins(l,t) == 1
            hit = hit+1;
        elseif bins(l,t) == 2
            miss = miss +1;
        elseif bins(l,t) == 3
            cr = cr+1;
        elseif bins(l,t) == 4
            fa = fa+1;
        end
    end
    hitRate(t) = [(hit/(hit+miss))*100]; % hit rate per 100 block
    faRate(t) = [(fa/(cr+fa))*100];  % false alarm rate per 100 block
    hit = 0; miss = 0; cr = 0; fa = 0; % clear outcome vars after 100
end
for o = block+1:length(outcome) % for leftover data after 100!
    if outcome(o) == 1
        hit = hit+1;
    elseif outcome(o) == 2
        miss = miss +1;
    elseif outcome(o) == 3
        cr = cr+1;
    elseif outcome(o) == 4
        fa = fa+1;
    end
end
hitRate(t+1) = [(hit/(hit+miss))*100]; % hit rate per 100 block
faRate(t+1) = [(fa/(cr+fa))*100];  % false alarm rate per 100 block

% PLOT
figureTitle = strcat(subj, ' Analysis');
figure('name', figureTitle,'Position', [1250 100 500 600]); % create figure for plots
smoothsize = 5; % size of smoothed line
y = 100:100:block+100; % blocks of 100 
subplot(211); % reinforced plot
plot(y, hitRate, 'color', 'g');  hold on; plot(y, faRate, 'color', 'r'); hold on;
plot(y, movmedian(hitRate,smoothsize),'Color','g','LineWidth',5); hold on; % smoothed line 
plot(y, movmedian(faRate,smoothsize),'Color','r','LineWidth',5); % smoothed line
xlabel('Trials'); ylim([0 110]); ylabel('Rate %'); xlim([0 block+500]);% set x-axis 
title('Average Learning Trajectories in Reinforcement Context');
subplot(212); % probe plot
plot(probeGraph(:,1), probeGraph(:,2), 'color', 'g');  hold on; plot(probeGraph(:,1), probeGraph(:,3), 'color', 'r'); hold on;
plot(probeGraph(:,1), movmedian(probeGraph(:,2),smoothsize),'Color','g','LineWidth',5); hold on; % smoothed line 
plot(probeGraph(:,1), movmedian(probeGraph(:,3),smoothsize),'Color','r','LineWidth',5); % smoothed line
xlabel('Trials'); ylim([0 110]); ylabel('Rate %'); xlim([0 block+500]);% set x-axis  
title('Average Learning Trajectories for Probe Context');

%BEHAVIORAL SENSITIVITY
transitions2 = diff(session); % check when transitions occur in context (from 1 to 2)
sessionStarts = find(transitions2 == 1) +1;
sessionStarts = [1; sessionStarts; length(data)]; 
dhit = 0; dmiss = 0; dcr = 0; dfa = 0;
probedhit = 0; probedmiss = 0; probedcr = 0; probedfa = 0;
dhitRate = []; dfaRate = []; probedhitRate = []; probedfaRate = [];
dReinforced =[]; dProbe = [];
for m = 1:length(file)
    sessionBlock = [data(sessionStarts(m)+1:sessionStarts(m+1), 5), data(sessionStarts(m)+1:sessionStarts(m+1), 3)]; 
    for n = 1:length(sessionBlock)
        if sessionBlock{n,2} == 1
            if sessionBlock{n,1} == 1
                dhit = dhit+1; 
            elseif sessionBlock{n,1} == 2
                dmiss = dmiss+1;
            elseif sessionBlock{n,1} == 3
                dcr = dcr+1;
            elseif sessionBlock{n,1} == 4
                dfa = dfa+1;            
            end
        else
            if sessionBlock{n,1} == 1
                probedhit = probedhit+1; 
            elseif sessionBlock{n,1} == 2
                probedmiss = probedmiss+1;
            elseif sessionBlock{n,1} == 3
                probedcr = probedcr+1;
            elseif sessionBlock{n,1} == 4
                probedfa = probedfa+1;            
            end
        end
    end
    if (dhit/(dhit+dmiss)) == 0
        dhitRate(m,:) = (1-(1/(2*length(sessionBlock))));
        dfaRate(m,:) = (1- (1/(2*length(sessionBlock))));
    elseif (dhit/(dhit+dmiss)) == 1
        dhitRate(m,:) = 1/(2*length(sessionBlock));
        dfaRate(m,:) = 1/(2*length(sessionBlock));
    else
        dhitRate(m,:) = [(dhit/(dhit+dmiss))]; 
        dfaRate(m,:) = [(dfa/(dcr+dfa))]; 
    end
    dReinforced(m,:) = (norminv(dhitRate(m))) - (norminv(dfaRate(m)));

    if (probedhit/(probedhit+probedmiss)) == 0
        probedhitRate(m,:) = (1-(1/(2*20)));
        probedfaRate(m,:) = (1-(1/(2*20)));
    elseif (probedhit/(probedhit+probedmiss)) == 1
        probedhitRate(m,:) = (1/(2*20));
        probedfaRate(m,:) = (1/(2*20));
    else
        probedhitRate(m,:) = [(probedhit/(probedhit+probedmiss))]; 
        probedfaRate(m,:) = [(probedfa/(probedcr+probedfa))]; 
    end
    dProbe(m,:) = (norminv(probedhitRate(m))) - (norminv(probedfaRate(m)));
end