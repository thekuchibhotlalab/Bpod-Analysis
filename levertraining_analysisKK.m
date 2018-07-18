%% calculate basic statistics for lever pressing task
clearvars -except SessionData;
numlicksbeforepress = zeros(SessionData.nTrials,1);
lickbeforepress = zeros(SessionData.nTrials,1);
lickafterpress = zeros(SessionData.nTrials,1);
firstlever = zeros(SessionData.nTrials,1);
hit = zeros(SessionData.nTrials,1);

for i=1:SessionData.nTrials
    if isfield(SessionData.RawEvents.Trial{1,i}.Events,'SoftCode1') %check if manual give
        numlicksbeforepress(i) = NaN;
        lickbeforepress(i) = NaN;
        lickafterpress(i) = NaN;
        firstlever(i) = NaN;
    else
        lever(:,1)=SessionData.RawEvents.Trial{1,i}.Events.Port2Out';
        firstlever(i) = lever(1); % first press
        %lever(:,2)=SessionData.RawEvents.Trial{1,i}.Events.Port2Out';
        if ~isfield(SessionData.RawEvents.Trial{1,i}.Events,'Port1In') 
            hit(i) = 0;
            numlicksbeforepress(i) = 0;
            lickbeforepress(i) = NaN;
            lickafterpress(i) = NaN;
        else lick(:,1)=SessionData.RawEvents.Trial{1,i}.Events.Port1In';
            
        
        %lick(:,2)=SessionData.RawEvents.Trial{1,i}.Events.Port1Out';
        %avgleverduration = mean(lever(:,2)-lever(:,1));
        %avglickduration = mean(lick(:,2)-lick(:,1));
        %calculates the time between licks and the first lever response

            licklever=lick(:,1)-lever(1);
            numlicksbeforepress(i) = length(find(licklever<0)); %calculates # of licks before press
            try lickbeforepress(i) = licklever(length(find(licklever<0)),1);
                catch lickbeforepress(i) = NaN;
            end;

            %most recent lick time before press (diff to press)
            if max(licklever)>0
                lickafterpress(i) = licklever(length(find(licklever<0))+1,1);
                hit(i) = 1;
            else hit(i) = 0;
                lickafterpress(i) = [];
            end;

            %most recent lick time after press (diff to press)
            
        end;
    end;
    clear lever lick;
end     
figure;
smoothsize = 5;

numlicksbeforepress = numlicksbeforepress';
lickbeforepress = abs(lickbeforepress)';
lickafterpress = lickafterpress';
firstlever = firstlever';
subplot(411);
plot(numlicksbeforepress,'b');hold on;
plot(movmedian(numlicksbeforepress,smoothsize),'Color','b','LineWidth',3);
xlim([0 SessionData.nTrials]);
title('Number of licks before lever press');

subplot(412);
plot(lickbeforepress,'r');hold on;
plot(movmedian(lickbeforepress,smoothsize),'Color','r','LineWidth',3);
xlim([0 SessionData.nTrials]);
title('Most recent lick time before lever press');

subplot(413);
plot(lickafterpress,'k');hold on;
plot(movmedian(lickafterpress,smoothsize),'Color','k','LineWidth',3);
xlim([0 SessionData.nTrials]);
title('Lick latency after press');

subplot(414);
plot(firstlever, 'g'); hold on;
plot(movmedian(firstlever, smoothsize), 'Color', 'g', 'LineWidth', 3);
xlim([0 SessionData.nTrials]);
ylim([0 10]);
title('Time of initial lever press');