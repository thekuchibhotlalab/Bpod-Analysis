%% load data
subj = 'KF001'; % INPUT SUBJECT NAME HERE 
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
        % LEVER LATENCY
        if ~isnan(SessionData.RawEvents.Trial{1,j}.States.Miss)
            leverTemp(j,:) = NaN;
        elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.CorrectReject)
            leverTemp(j,:) = NaN;
        else
            press = SessionData.RawEvents.Trial{1,j}.Events.Port2Out';
            press = press -  SessionData.RawEvents.Trial{1,j}.States.WaitForPress(1);
            press = press(press>0);
            leverTemp(j,:) = press(1);
        end
        % LICK LATENCY
%         if ~isfield(SessionData.RawEvents.Trial{1,j}.Events,'Port1In')
%             lickTemp(j,:) = NaN;
%         elseif ((SessionData.RawEvents.Trial{1,j}.Events.Port1In)-(SessionData.RawEvents.Trial{1,j}.States.WaitForPress(1)))> 0
%             licking = SessionData.RawEvents.Trial{1,j}.Events.Port1In';
%             licking = licking - SessionData.RawEvents.Trial{1,j}.States.WaitForPress(1);
%             licking = licking(licking>0);
% %             licking = licking(licking<3);
%             lickTemp(j,:) = licking(1);
% %         else
% %             lickTemp(j,:) = NaN;
%         end
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
leverTemp = nonzeros(leverTemp); lever = [lever;leverTemp]; % get rid of zero gaps, add lever data to all
lickTemp = nonzeros(lickTemp); lick = [lick; lickTemp]; % get rid of zero gaps, add lick data to all
end % through one session
for h = 1:length(outcome) % number of trials for cell
    trialNum(h,:) = h;
end

% COMPILE ALL DATA
labels = {'Session' 'Trial' 'Context' 'Tone' 'LeverResponse' 'LeverLatency'}; % data labels
all = [session, trialNum, context, tone, outcome, lever]; % compile all of data
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

% BEHAVIORAL SENSITIVITY
% dReinforced = []; dProbe = [];
% for i =1:57
%     hitRate(i) = hitRate(i)/100;
%     faRate(i) = faRate(i)/100;
%     if hitRate(i) == 0
%         hitRate(i) = 0.005;
%     elseif hitRate(i) == 1
%         hitRate(i) = 0.995;
%     elseif faRate(i) == 0
%         faRate(i) = 0.005;
%     elseif faRate(i) == 1
%         faRate(i) = 0.995;
%     end
%     dReinforced(i,:) = (norminv(hitRate(i))) - (norminv(faRate(i)));
% end
% for i = 1:18
%     probeHitRate(i) = probeHitRate(i)/100;
%     probeFARate(i) = probeFARate(i)/100;
%     if probeHitRate(i) == 0
%         probeHitRate(i) = 0.005;
%     elseif probeHitRate(i) == 1
%         probeHitRate(i) = 0.995;
%     elseif probeFARate(i) == 0
%         probeFARate(i) = 0.005;
%     elseif probeFARate(i) == 1
%         probeFARate(i) = 0.995;
%     end
%     dProbe(i,:) = (norminv(probeHitRate(i))) - (norminv(probeFARate(i)));
% end