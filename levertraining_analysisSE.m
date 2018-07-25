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
    elseif isfield(SessionData.RawEvents.Trial{1,i}.Events,'Condition1')
        lickbeforepress(i) = SessionData.RawEvents.Trial{1,i}.Events.Condition1;
        firstlever(i) = NaN;
    else
        lever = SessionData.RawEvents.Trial{1,i}.Events.Port2Out';
        firstlever(i) = lever(1);
        if ~isfield(SessionData.RawEvents.Trial{1,i}.Events,'Port1In')
            lickafterpress(i) = NaN;
        else
            lick = SessionData.RawEvents.Trial{1,i}.Events.Port1In';
            licklever = lick-lever(1);
            lickafterpress(i) = licklever(1);
        end
    end
    clear lever lick; % clear these variables for current trial
end     
figure('name','Lever Analysis'); % create figure for plots
smoothsize = 5; % size of smoothed line
firstlever(isnan(firstlever)) = []; % get rid of NaN's in firstlever
% subplot(411); plot(numlicksbeforepress,'b'); hold on;
% plot(movmedian(numlicksbeforepress,smoothsize),'Color','b','LineWidth',3); % smoothed line
% xlim([0 SessionData.nTrials]); ylim([0 30]); % set x-axis and y-axis
% title('Number of licks before lever press');

subplot(311); plot(lickbeforepress,'r');hold on;
plot(movmedian(lickbeforepress,smoothsize),'Color','r','LineWidth',3); % smoothed line
xlim([0 SessionData.nTrials]);% set x-axis
title('Most recent lick time before lever press');

subplot(312); plot(lickafterpress,'k');hold on;
plot(movmedian(lickafterpress,smoothsize),'Color','k','LineWidth',3); % smoothed line
xlim([0 SessionData.nTrials]); ylim([0 2]);% set x-axis
title('Lick latency after press');

subplot(313); plot(firstlever, 'g'); hold on;
plot(movmedian(firstlever, smoothsize), 'Color', 'g', 'LineWidth', 3);
xlim([0 30]); ylim([0 15]); % set x-axis and y-axis
title('Time of initial lever press');