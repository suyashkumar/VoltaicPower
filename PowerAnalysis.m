%% PowerAnalysis.m

%% Init
clear,clc,clf
dataPrefix = 'data';
nameSet = {'Sleep_NetworkSTBY_Particle.csv','Sleep_NetworkSTBY_ThingSpeak.csv', 'Sleep_ThingSpeak.csv'};
valSet = {[0 71;100 112;142 214], [3 17; 46 56; 85 94; 123 134], [2 40; 70 107; 136 173;204 249]};% awake regions in seconds 
regionMap = containers.Map(nameSet, valSet);
mkdir analysis_output

%% Read Data and compute

fnames = dir(strcat(dataPrefix,'/*.csv'))

for file=fnames'
   file = file.name % Get Filename 
   currData = csvread(strcat(dataPrefix,'/',file));
   % Compute Power data:
   power=[];
   for row = currData'
       power(end+1)= row(1)*row(2);
   end
   
   avgPower = mean(power); % Mean power total
   onIntervals = regionMap(file)
   
   onPower = [];
   onPowerStd = [];
   onPowerSum = 0;
   onPowerN = 0;
   for interval = onIntervals'
       currInterval = power(interval(1)+1:interval(2)+1)
       onPower(end+1) = mean(currInterval);
       onPowerStd(end+1) = std(currInterval);
       onPowerSum = onPowerSum + sum(currInterval);
       onPowerN = onPowerN + length(currInterval);
   end
   
   onPowerMean = onPowerSum/onPowerN;
   
   startIndex = 1;
   offPower=[];
   offPowerStd=[];
   offIntervals = [];
   offPowerSum=0;
   offPowerN=0;
   for i = 1:length(onIntervals)
      currOnInterval = onIntervals(i,:);
      if(currOnInterval(1) <= 2)
          startIndex = currOnInterval(2);
          continue
      end
      offInterval = power(startIndex+1:currOnInterval(1)-1); % Compute off interval
      offIntervals(end+1,:)=[startIndex+1, currOnInterval(1)-1];
      offPower(end+1) = mean(offInterval);
      offPowerStd(end+1) = std(offInterval);
      offPowerSum = offPowerSum + sum(offInterval);
      offPowerN = offPowerN + length(offInterval);
      startIndex = currOnInterval(2);
   end
   
   offPowerMean = offPowerSum/offPowerN;
   
   % Write data to file: 
   nameSansExtentionArr = strsplit(file,'.')
   fileID = fopen(strcat('analysis_output/', nameSansExtentionArr{1},'.txt'),'w');
   fprintf(fileID, 'For %s',nameSansExtentionArr{1})
   
   fprintf(fileID, '\n\nPower Analysis \nOn Power Intervals:\n')
   fprintf(fileID, '%9s %7s %13s %16s %10s','Start (s)', 'End (s)','Avg Power (W)', 'Stdev Power (w)');
   fprintf(fileID,'\n');
   i=1;
   for interval = onIntervals'
      fprintf(fileID, '%9d %7d %13.2f %16.2f\n', interval(1), interval(2), onPower(i), onPowerStd(i))
      i=i+1;
   end
   fprintf(fileID,'\nMean Power of on intervals: %.2f W\n',onPowerMean);
   
   fprintf(fileID, '\nSleep Power Intervals:\n');
   fprintf(fileID, '%9s %7s %13s %16s %10s','Start (s)', 'End (s)','Avg Power (W)', 'Stdev Power (w)');
   fprintf(fileID,'\n');
   i=1;
   for interval = offIntervals'
      fprintf(fileID, '%9d %7d %13.2f %16.2f\n', interval(1), interval(2), offPower(i), offPowerStd(i));
      i=i+1;
   end
   fprintf(fileID,'\nMean Power of sleep intervals: %.2f W\n',offPowerMean);
  
   fclose(fileID);
   
   
end