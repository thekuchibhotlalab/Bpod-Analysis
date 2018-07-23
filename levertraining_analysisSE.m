%% load datafor i:dir('/Users/sarahelnozahy/Downloads/');

%% calculate basic statistics for lever pressing task
clearvars -except SessionData;
numlicksbeforepress = zeros(SessionData.nTrials,1);
lickbeforepress = zeros(SessionData.nTrials,1);
lickafterpress = zeros(SessionData.nTrials,1);
firstlever = zeros(SessionData.nTrials,1);
hit = zeros(SessionData.nTrials,1);

for i=1:SessionData.nTrials % increment through all the trials in one given session
    if isfield(SessionData.RawEvents.Trial{1,i}.Events,'SoftCode1') % If a manual delivery is administered
        % all variables are undefined due to manual delivery
        numlicksbeforepress(i) = NaN; 
        lickbeforepress(i) = NaN;
        lickafterpress(i) = NaN;
        firstlever(i) = NaN;
    else 
        lever = SessionData.RawEvents.Trial{1,i}.Events.Port2Out'; % measures time of lever presses in given trial
        firstlever(i) = lever(1); % first press of lever in given trial
        %lever(:,2)=SessionData.RawEvents.Trial{1,i}.Events.Port2Out';
        if ~isfield(SessionData.RawEvents.Trial{1,i}.Events,'Port1In') % if no lick occurs during trial
            hit(i) = 0;
            numlicksbeforepress(i) = 0; % no licks before press due to no lick during trial
            lickbeforepress(i) = NaN; % no time of lick before press due to no lick during trial
            lickafterpress(i) = NaN; % no time of lick after press due to no lick during trial
        else
            lick = SessionData.RawEvents.Trial{1,i}.Events.Port1In'; % measures time of licks in given trial
        %lick(:,2)=SessionData.RawEvents.Trial{1,i}.Events.Port1Out';
        %avgleverduration = mean(lever(:,2)-lever(:,1));
        %avglickduration = mean(lick(:,2)-lick(:,1));
            licklever = lick-lever(1); % calculates time between licks and the first lever response
            numlicksbeforepress(i) = length(find(licklever<0)); % calculates # of licks before press
            if numlicksbeforepress(i) == 0 % If no licks before press then time of most recent lick before press is undefined
                lickbeforepress(i) = NaN;
            else
                lickbeforepress(i) = licklever(length(find(licklever<0)),1); % most recent lick time before press recorded
            end
            if max(licklever)>0 % if there are licks after press 
                lickafterpress(i) = licklever(length(find(licklever<0))+1,1); % most recent lick after press calculated
                hit(i) = 1; % hit is recorded if lick after press
            else
                hit(i) = 0; % otherwise, this trial is not recorded as a hit
                lickafterpress(i) = []; % lick after press for this trial is an empty array (it is not undefined or 0)
            end            
        end
    end
    clear lever lick; % clear these variables for current trial
end     
figure('name','Lever Analysis'); % create figure for plots
smoothsize = 5; % size of smoothed line
lickbeforepress = abs(lickbeforepress); % positive time for most recent lick before press

subplot(411); plot(numlicksbeforepress,'b'); hold on;
plot(movmedian(numlicksbeforepress,smoothsize),'Color','b','LineWidth',3); % smoothed line
xlim([0 SessionData.nTrials]); ylim([0 30]); % set x-axis and y-axis
title('Number of licks before lever press');

subplot(412); plot(lickbeforepress,'r');hold on;
plot(movmedian(lickbeforepress,smoothsize),'Color','r','LineWidth',3); % smoothed line
xlim([0 SessionData.nTrials]);% set x-axis
title('Most recent lick time before lever press');

subplot(413); plot(lickafterpress,'k');hold on;
plot(movmedian(lickafterpress,smoothsize),'Color','k','LineWidth',3); % smoothed line
xlim([0 SessionData.nTrials]); % set x-axis
title('Lick latency after press');

subplot(414); plot(firstlever, 'g'); hold on;
plot(movmedian(firstlever, smoothsize), 'Color', 'g', 'LineWidth', 3);
xlim([0 SessionData.nTrials]); ylim([0 15]); % set x-axis and y-axis
title('Time of initial lever press');