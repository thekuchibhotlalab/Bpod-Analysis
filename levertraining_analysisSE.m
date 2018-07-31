%% load data
files = dir('/Users/sarahelnozahy/Downloads/*.mat');
direct = '/Users/sarahelnozahy/Downloads/';
numFiles = length(files);
filenames = strings(numFiles,1);
% for i= 1:numFiles
%     filenames(i) = strcat('/Users/sarahelnozahy/Downloads/', files(i).name);
%     load(filenames(i));
    %% calculate basic statistics for lever pressing task
    clearvars -except SessionData;
    numlicksbeforepress = zeros(SessionData.nTrials,1);
    lickbeforepress = zeros(SessionData.nTrials,1);
    lickafterpress = zeros(SessionData.nTrials,1);
    firstlever = zeros(SessionData.nTrials,1);
    hit =0; miss =0; cr = 0; fa = 0;
 
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
        if ~isnan(SessionData.RawEvents.Trial{1,i}.States.Drinking)
            hit = hit+1;
        elseif ~isnan(SessionData.RawEvents.Trial{1,i}.States.Miss)
            miss = miss+1;
        elseif ~isnan(SessionData.RawEvents.Trial{1,i}.States.StopForLick)
            fa = fa+1;
        end
        clear lever lick; % clear these variables for current trial
    end
    
figure('name','Lever Analysis'); % create figure for plots
smoothsize = 5; % size of smoothed line
firstlever(isnan(firstlever)) = []; % get rid of NaN's in firstlever
xaxis = size(firstlever);
subplot(411); plot(lickbeforepress,'r');hold on;
plot(movmedian(lickbeforepress,smoothsize),'Color','r','LineWidth',3); % smoothed line
xlim([0 SessionData.nTrials]); ylim([0 15]);% set x-axis
title('Most recent lick time before lever press');

subplot(412); plot(lickafterpress,'k');hold on;
plot(movmedian(lickafterpress,smoothsize),'Color','k','LineWidth',3); % smoothed line
xlim([0 SessionData.nTrials]); ylim([0 2]);% set x-axis
title('Lick latency after press');

subplot(413); plot(firstlever, 'g'); hold on;
plot(movmedian(firstlever, smoothsize), 'Color', 'g', 'LineWidth', 3);
xlim([0 xaxis(1)]); ylim([0 15]); % set x-axis and y-axis
title('Time of initial lever press');

subplot(414); 
uicontrol('Style', 'text', 'String', ['Hits = ' num2str(hit)], 'units', 'normalized', 'Position', [.05 .05 .25 .21], 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', [.7 .2 1]); % Licks label
uicontrol('Style', 'text', 'String', ['Miss = ' num2str(miss)], 'units', 'normalized', 'Position', [.3 .05 .3 .21], 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', [.7 .2 1]); % Licks label
uicontrol('Style', 'text', 'String', ['False Alarms = ' num2str(fa)], 'units', 'normalized', 'Position', [.55 .05 .4 .21], 'FontWeight', 'bold', 'FontSize', 16, 'FontName', 'Arial', 'BackgroundColor', [.7 .2 1]); % Licks label

% end