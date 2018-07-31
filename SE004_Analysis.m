% load data
filez = dir('/Users/sarahelnozahy/Downloads/SE004/*.mat');
direct = '/Users/sarahelnozahy/Downloads/SE004/';
numFiles = length(filez);
filenames = strings(numFiles,1);
hit = 0; miss = 0; correctReject = 0; falseAlarm = 0;
probeHit = 0; probeMiss = 0; probeCorrectReject = 0; probeFalseAlarm = 0;
rate = zeros(4,1);rate = rate';
probeRateArray = zeros(4,1); probeRateArray = probeRateArray';
overall = zeros(6800,1);
nTrials = 0;
for i= 1:numFiles
    hit = 0; miss = 0; correctReject = 0; falseAlarm = 0;
    probeHit = 0; probeMiss = 0; probeCorrectReject = 0; probeFalseAlarm = 0;
    rate = zeros(4,2);
    filenames(i) = strcat('/Users/sarahelnozahy/Downloads/SE004/', filez(i).name);
    load(filenames(i));
    if SessionData.nTrials < 80
        for r= 1:SessionData.nTrials
            if ~isnan(SessionData.RawEvents.Trial{1,r}.States.OpenValve) %
                hit = hit+1;
                rate = ([((hit/(hit+miss))*100) ((miss/(hit+miss))*100) rate(3) rate(4)]);
            elseif ~isnan(SessionData.RawEvents.Trial{1,r}.States.Miss)
                miss = miss+1;
                rate = ([((hit/(hit+miss))*100) ((miss/(hit+miss))*100) rate(3) rate(4)]);
            elseif ~isnan(jSessionData.RawEvents.Trial{1,r}.States.CorrectReject)
                rate = ([rate(1) rate(2) ((correctReject/(correctReject+falseAlarm))*100) ((falseAlarm/(correctReject+falseAlarm))*100)]);
            elseif ~isnan(SessionData.RawEvents.Trial{1,r}.States.Punish)
                falseAlarm = falseAlarm+1;
                rate = ([rate(1) rate(2) ((correctReject/(correctReject+falseAlarm))*100) ((falseAlarm/(correctReject+falseAlarm))*100)]);
            end       
        end
    else
        for j =1:SessionData.nTrials % increment through all the trials in one given session
            if SessionData.nTrials >= 81 && SessionData.nTrials <=100
                if ~isnan(SessionData.RawEvents.Trial{1,j}.States.OpenValve) %
                    probeHit = probeHit+1;
                    probeRateArray = ([((probeHit/(probeHit+probeMiss))*100) ((probeMiss/(probeHit+probeMiss))*100) rate(3) rate(4)]);
                elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.Miss)
                    probeMiss = probeMiss+1;
                    probeRateArray = ([((probeHit/(probeHit+probeMiss))*100) ((probeMiss/(probeHit+probeMiss))*100) rate(3) rate(4)]);
                elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.CorrectReject)
                    probeCorrectReject = probeCorrectReject+1;
                    probeRateArray = ([rate(1) rate(2) ((probeCorrectReject/(probeCorrectReject+probeFalseAlarm))*100) ((probeFalseAlarm/(probeCorrectReject+probeFalseAlarm))*100)]);
                elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.Punish)
                    probeFalseAlarm = probeFalseAlarm+1;
                    probeRateArray = ([rate(1) rate(2) ((probeCorrectReject/(probeCorrectReject+probeFalseAlarm))*100) ((probeFalseAlarm/(probeCorrectReject+probeFalseAlarm))*100)]);
                end  
            end
            if ~isnan(SessionData.RawEvents.Trial{1,j}.States.OpenValve) %
                hit = hit+1;
                rate = ([((hit/(hit+miss))*100) ((miss/(hit+miss))*100) rate(3) rate(4)]);
            elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.Miss)
                miss = miss+1;
                rate = ([((hit/(hit+miss))*100) ((miss/(hit+miss))*100) rate(3) rate(4)]);
            elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.CorrectReject)
                rate = ([rate(1) rate(2) ((correctReject/(correctReject+falseAlarm))*100) ((falseAlarm/(correctReject+falseAlarm))*100)]);
            elseif ~isnan(SessionData.RawEvents.Trial{1,j}.States.Punish)
                falseAlarm = falseAlarm+1;
                rate = ([rate(1) rate(2) ((correctReject/(correctReject+falseAlarm))*100) ((falseAlarm/(correctReject+falseAlarm))*100)]);
            end      
        end
    end
    
end

% figure('name','SE004 Analysis'); % create figure for plots
% smoothsize = 5; % size of smoothed line
% 
% subplot(211); plot(rate(1),'r');hold on;
% plot(movmedian(hit,smoothsize),'Color','r','LineWidth',3); % smoothed line
% xlim([0 nTrials]); ylim([0 110]);% set x-axis
% title('Reinforcement');
% 
% subplot(212); plot(probeHit,'k');hold on;
% plot(movmedian(probeHit,smoothsize),'Color','k','LineWidth',3); % smoothed line
% xlim([0 nTrials]); ylim([0 110]);% set x-axis
% title('Probe');

