%%%Event Function
%%%attempting to generate features that might be useful:
%1. Average time in REM
%2  Median time in REM
%3. Number of Rem States
%4. State immediately after REM
%5. State immediately before REM
%6. proportion of REM sleep to total Sleep
%7.
function [s0temp, s1temp, s2temp, s3temp, s4temp, Remtimestampstemp, sleepchart, timestart, timeend, startrec, totallength, dur, startp, endp, alllen] = events_func_1(pathsub)
%     try
%     stringtemp = erase(pathsub, '-Events.mat');
    eventfeatstemp = {};
    sleepchart = [];
    Remtimetemp = {};
    s0timetemp = {};
    s1timetemp = {};
    s2timetemp = {};
    s3timetemp = {};
    s4timetemp = [];
    afterrem = {};
    beforerem = {};
    Remtimestampstemp = [];
    %below 's temps' are other state analogues to Remtimestampstemp.
    s0temp = [0 0];
    s1temp = [0 0];
    s2temp = [0 0];
    s3temp = [0 0];
    s4temp = [0 0];
%     pathsub = append('L:\Lab_JamesR\Paediatric_Sleep\studyinfo\events_exported\batch1\', pathsub);
    table = load(char(pathsub));
    reporttext = [];
    remflag = false;
    s0flag = false;
    s1flag = false;
    s2flag = false;
    s3flag = false;
    s4flag = false;
    
    
    %%%Text Compiler
    for t = 1:length(table.events_table)
        txt = '';
        for h = 1:size(table.events_table, 2)
%             if char(table.events_table((startrow + k), h))
%                 reporttextsegmented{t,h} = table.events_table{t, h};
                

                txt = [txt ' ' char(char(table.events_table{t, h}))];
                try
                    if contains(char(char(table.events_table{t,h})), 'Analysis-Start', IgnoreCase = true) && t >= 10
                        timecol = h-1;
                        timestart = t + 1;
                        timecolumn = table.events_table{((t-1):end), h};
                        timeofstart = table.events_table{t,h-1};
                        timeofend = table.events_table{length(table.events_table), timecol};
                    elseif contains(char(char(table.events_table{t,h})), 'Event', IgnoreCase = true) && t >= 50
                        eventscol = h;
                        startrec = t+1;
                    elseif (contains(char(char(table.events_table{t,h})), 'Analysis-End', IgnoreCase = true) || contains(char(char(table.events_table{t,h})), 'Analysis-Stop', IgnoreCase = true)) && t >= 10
                        timeofend = table.events_table{t,h-1};
                        timeend = t;
                    end
                catch
%                     text4output = append('didnt work for t = ', num2str(t));
%                     disp(text4output);
                end
                
        end
        
        if (contains(txt, 'AM', IgnoreCase = true) || contains(txt, 'PM', IgnoreCase = true)) && ~contains(txt, 'equipment', IgnoreCase = true) && ~contains(txt, 'name', IgnoreCase = true)
            reporttext = [reporttext; {txt}];
        end
    end
    
    if ~exist('timeend', 'var')
        timeend = length(table.events_table);
    end
    txt = char(txt);
    %%%state analyzing
    s0 = 0;
    s1 = 0;
    s2 = 0;
    s3 = 0;
    s4 = 0;
    rem = 0;
    
    %%%part that records sleep states
    for j = (timestart+1):length(table.events_table)
        tempstring = char(table.events_table{j, (timecol + 1)});
        backcheck = -1;

        if j >= timestart
            if contains(tempstring, 's0', IgnoreCase = true) && (table.events_table{j, size(table.events_table, 2)} >= 30)
%                 for y = 1:cell2mat((table.events_table(j,size(table.events_table, 2))))
                    s0 = s0 + 1;
                    sleepchart = [sleepchart; [0 table.events_table(j, size(table.events_table, 2))]];
                    backcheck = 0;
%                 end
            end
            if contains(tempstring, 's1', IgnoreCase = true) && (table.events_table{j, size(table.events_table, 2)} >= 30)
%                 for y = 1:cell2mat((table.events_table(j,size(table.events_table, 2))))
                    s1 = s1 + 1;
                    sleepchart = [sleepchart; [1 table.events_table(j, size(table.events_table, 2))]];
                    backcheck = 1;
%                 end
            end
            if contains(tempstring, 's2', IgnoreCase = true) && (table.events_table{j, size(table.events_table, 2)} >= 30)
%                  for y = 1:cell2mat((table.events_table(j,size(table.events_table, 2))))
                     s2 = s2 + 1;
                    sleepchart = [sleepchart; [2 table.events_table(j, size(table.events_table, 2))]];
                    backcheck = 2;
%                  end
            end
            if contains(tempstring, 's3', IgnoreCase = true) && (table.events_table{j, size(table.events_table, 2)} >= 30)
%                  for y = 1:cell2mat((table.events_table(j,size(table.events_table, 2))))
                     s3 = s3 + 1;
                    sleepchart = [sleepchart; [3 table.events_table(j, size(table.events_table, 2))]];
                    backcheck = 3;
%                  end
            end
            if contains(tempstring, 's4', IgnoreCase = true) && (table.events_table{j, size(table.events_table, 2)} >= 30)
%                  for y = 1:cell2mat((table.events_table(j,size(table.events_table, 2))))
                    s4 = s4 + 1;
                    sleepchart = [sleepchart; [4 table.events_table(j, size(table.events_table, 2))]];
                    backcheck = 4; 
%                  end
            end              
            if contains(tempstring, 'SLEEP-REM', IgnoreCase = true) && (table.events_table{j, size(table.events_table, 2)} >= 30)
%                  for y = 1:cell2mat((table.events_table(j,size(table.events_table, 2))))
                    rem = rem + 1;
                    sleepchart = [sleepchart; [5 table.events_table(j, size(table.events_table, 2))]];
        %             if remflag == false
        %                 remflag = true;
        %                 Remtimestart = table.events_table(j, timecol);
                    backcheck = 5; 
%                  end
            end

            if backcheck == -1 && length(sleepchart) ~= 0
                if ~contains(tempstring, 'ARTIFACT', IgnoreCase = true) && (table.events_table{j, size(table.events_table, 2)} >= 30)
                    if cell2mat((table.events_table(j,size(table.events_table, 2)))) > 60
%                         for y = 1:60
                            sleepchart = [sleepchart; [sleepchart((length(sleepchart) - 1), 1) table.events_table(j, size(table.events_table, 2))]];
%                         end
                    else
%                         for y = 1:cell2mat((table.events_table(j,size(table.events_table, 2))))
                            sleepchart = [sleepchart; [sleepchart((length(sleepchart) - 1), 1), table.events_table(j, size(table.events_table, 2))]];
%                         end
                    end
                    

                end
            end

        end
%         
        
        if contains(tempstring, 'am')
            timendx = strfind(tempstring, 'am');
            isam = true;
        elseif contains(tempstring, 'AM')
            timendx = strfind(tempstring, 'AM');
            isam = true;
        elseif contains(tempstring, 'pm')
            timendx = strfind(tempstring, 'pm');
            isam = false;
        elseif contains(tempstring, 'PM')
            timendx = strfind(tempstring, 'PM');
            isam = false;
        end

%         timeof = tempstring((timendx - 8):(timendx));
        timeof = char(table.events_table{j, (timecol)});
        %%%%%Below finds the different sleep state periods.
     
        
        %%%REM
        if contains(tempstring, 'REM', IgnoreCase = true)
            if remflag == false
                remflag = true;
                remduration = 0;
                remtimestart = table.events_table(j, timecol);
                remtimestartndx = j - timestart;
                if contains(table.events_table{(j-1), eventscol}, 's0', Ignorecase = true)
                    beforerem = [beforerem; 0];
                elseif contains(table.events_table{(j-1), eventscol}, 's1', IgnoreCase = true)
                    beforerem = [beforerem; 1];
                elseif contains(table.events_table{(j-1), eventscol}, 's2', IgnoreCase = true)
                    beforerem = [beforerem; 2];
                elseif contains(table.events_table{(j-1), eventscol}, 's3', IgnoreCase = true)
                    beforerem = [beforerem; 3];
                elseif contains(table.events_table{(j-1), eventscol}, 's4', IgnoreCase = true)
                    beforerem = [beforerem; 4];
                else
                    beforerem = -1;
                end
            end
        elseif contains(tempstring, 'SLEEP-', IgnoreCase = true) 
            if remflag == true
                if contains(tempstring, 's0', Ignorecase = true)
                    afterrem = [afterrem; 0];
                elseif contains(tempstring, 's1', IgnoreCase = true)
                    afterrem = [afterrem; 1];
                elseif contains(tempstring, 's2', IgnoreCase = true)
                    afterrem = [afterrem; 2];
                elseif contains(tempstring, 's3', IgnoreCase = true)
                    afterrem = [afterrem; 3];
                elseif contains(tempstring, 's4', IgnoreCase = true)
                    afterrem = [afterrem; 4];
                end
                
                remflag = false;
                remtimedone = table.events_table(j, timecol);
                remtimedonendx = j - timestart;
                %%%%DURATION DETERMINATION
                if ~isempty(cell2mat(remtimestart))
                    startstring = char(cell2mat(remtimestart));
                    endstring = char(cell2mat(remtimedone));
                    %%%Finds time of day in seconds for beginning of REM
                    if contains(startstring, 'am', IgnoreCase = true)
                        s_time = seconds(duration(startstring(1:(end-2))));
                    else
                        s_time = seconds(duration(startstring(1:(end-2)))) + seconds(duration('12:00:00'));
                    end
                    
                    if contains(endstring, 'am', IgnoreCase = true)
                        e_time = seconds(duration(endstring(1:(end-2))));
                    else
                        e_time = seconds(duration(endstring(1:(end-2)))) + seconds(duration('12:00:00'));
                    end
                    
                    
                    if e_time < s_time
                        s_time = duration('25:00:00') - s_time;
                    end
                    
                    remduration = e_time - s_time;
                end
                
                Remtimetemp = [Remtimetemp; {{remtimestart} []}];
                Remtimetemp{length(Remtimetemp), 2} = remduration;
                Remtimestampstemp = [Remtimestampstemp; {remtimestartndx/length((timestart+1):length(table.events_table))} {remtimedonendx/length((timestart+1):length(table.events_table))} {} {}];
                    
                
                
%                 Remtimesz = [Remtimesz; [remtimestart remtimedone dxaname(n)]];


            end
        end
    end

    %%
    %below determines beginnings/ends of states
    sleepchart = cell2mat(sleepchart);
    currentstate = sleepchart(1);
%     disp(length(sleepchart))
    for j = 2:length(sleepchart)
        if ~(currentstate == sleepchart(j))
            %recording start time of new state
            if sleepchart(j) == 0
                s0temp = [s0temp; [j 0]];
            elseif sleepchart(j) == 1
                s1temp = [s1temp; [j 0]];
            elseif sleepchart(j) == 2
                s2temp = [s2temp; [j 0]];
            elseif sleepchart(j) == 3
                s3temp = [s3temp; [j 0]];
            elseif sleepchart(j) == 4
                s4temp = [s4temp; [j 0]];
            end
        
        %recording end time of prior state
            if currentstate == 0
                s0temp(length(s0temp), size(s0temp, 2)) = j - 1;
            elseif currentstate == 1
                s1temp(length(s1temp), size(s1temp, 2)) = j - 1;
            elseif currentstate == 2
                s2temp(length(s2temp), size(s2temp, 2)) = j - 1;
            elseif currentstate == 3
                s3temp(length(s3temp), size(s3temp, 2)) = j - 1;
            elseif currentstate == 4
                s4temp(length(s4temp), size(s4temp, 2)) = j - 1;
            end
        end
        currentstate = sleepchart(j);
    end
	s1temp = s1temp(2:end, 1:2)./length(sleepchart);
    s2temp = s2temp(2:end, 1:2)./length(sleepchart);
    s3temp = s3temp(2:end, 1:2)./length(sleepchart);
    s4temp = s4temp(2:end, 1:2)./length(sleepchart);
    
    %%
    %below gives basic distributions of states
    sumstates = s0 + s1 + s2 + s3 + s4 + rem;
    s0 = s0/sumstates;
    s1 = s1/sumstates;
    s2 = s2/sumstates;
    s3 = s3/sumstates;
    s4 = s4/sumstates;
    rem = rem/sumstates;
%     eventarray = [eventarray [s0; s1; s2; s3; s4; rem; sum]];
    
    %below deals with formatting issues with rem array
    try
        Remtimetemp(2,1) = Remtimetemp(1,1);
        Remtimetemp(1,2) = Remtimetemp(2,2);
        Remtimetemp = Remtimetemp((2:end), 1:2);
    catch
    end
%     Remtimes.(stringtemp) = Remtimetemp;
    %%
%     if ~isempty(s0temp)
%         if s0temp(length(s0temp), 2) == 0
%             s0temp(length(s0temp), 2) = s0temp(length(s0temp), 1);
%         end
%     end
%     if ~isempty(s1temp)
%         if s1temp(length(s1temp), 2) == 0
%             s1temp(length(s1temp), 2) = s1temp(length(s1temp), 1);
%         end
%     end
%     if ~isempty(s2temp)
%         if s2temp(length(s2temp), 2) == 0
%             s2temp(length(s2temp), 2) = s2temp(length(s2temp), 1);
%         end
%     end
%     if ~isempty(s3temp)
%         if s3temp(length(s3temp), 2) == 0
%             s3temp(length(s3temp), 2) = s3temp(length(s3temp), 1);
%         end
%     end
%     
%     if ~isempty(s4temp)
%         if s4temp(length(s4temp), 2) == 0
%             s4temp(length(s4temp), 2) = s4temp(length(s4temp), 1);
%         end
%     end
    %%
    %%%Below adds the current values to their respective data structures
%     s0timestamps.(stringtemp) = s0temp;
%     s1timestamps.(stringtemp) = s1temp;
%     s2timestamps.(stringtemp) = s2temp;
%     s3timestamps.(stringtemp) = s3temp;
%     s4timestamps.(stringtemp) = s4temp;
    try
        eventfeatstemp{1} = mean([Remtimetemp{:,2}]);
        eventfeatstemp{2} = median([Remtimetemp{:,2}]);
        eventfeatstemp{3} = size(Remtimetemp, 1);
        eventfeatstemp{4} = afterrem;
        eventfeatstemp{5} = beforerem;
        eventfeatstemp{6} = rem;
    catch
    end
    
%     eventfeats.(stringtemp) = eventfeatstemp;
    
    totaltime = [];
        %% 
        %FINDING TOTAL TIME OF RECORDING
        %Start time
        
        
        if contains(timeofstart, 'am', IgnoreCase = true)
            isam = true;
        elseif contains(timeofstart, 'pm', IgnoreCase = true)
            isam = false;
        end
        
        if length(timeofstart) == 10
            if isam == true
                s_hours = str2num(timeofstart(1));
            else
                s_hours = 12 + str2num(timeofstart(1));
            end
            s_mins = str2num(timeofstart(3:4));
            s_secs = str2num(timeofstart(6:7));
        else
            if isam == true
                s_hours = str2num(timeofstart(1:2));
            else
                s_hours = 12 + str2num(timeofstart(1:2));
            end
            s_mins = str2num(timeofstart(4:5));
            s_secs = str2num(timeofstart(7:8));
        end
        
        %End time
        if contains(timeofend, 'am')
            isam = true;
        elseif contains(timeofend, 'AM')
            isam = true;
        elseif contains(timeofend, 'pm')
            isam = false;
        elseif contains(timeofend, 'PM')
            isam = false;
        end
        if length(timeofend) == 10
            if isam == true
                e_hours = str2num(timeofend(1));
            else
                e_hours = 12 + str2num(timeofend(1));
            end
            e_mins = str2num(timeofend(3:4));
            e_secs = str2num(timeofend(6:7));
        else
            if isam == true
                e_hours = str2num(timeofend(1:2));
            else
                e_hours = 12 + str2num(timeofend(1:2));
            end
            e_mins = str2num(timeofend(4:5));
            e_secs = str2num(timeofend(7:8));
        end
        %%
%         captimes.(stringtemp) = [{timeofstart} {timeofend}];
        if contains(timeofstart, 'pm', IgnoreCase = true)
            timeofstartdur = duration(timeofstart(1:(end-2))) + duration('12:00:00');
        else
            timeofstartdur = duration(timeofstart(1:(end-2)));
        end
        
        if contains(timeofend, 'pm', IgnoreCase = true)
            timeofenddur = duration(timeofend(1:(end-2)))+ duration('12:00:00');
        else
            timeofenddur = duration(timeofend(1:(end-2)));
        end
        
        timeofstartdur = 86400 - seconds(timeofstartdur);
        totaltime = timeofstartdur + seconds(timeofenddur);
        totaltime = 86400 - ((3600*s_hours) + (60*s_mins) + s_secs) + ...
            ((3600*e_hours) + (60*e_mins) + e_secs);
        sleepchart = [sleepchart transpose(linspace(0, totaltime, length(sleepchart)))];
        %%%%%%TESTING FOR INDEX
%         sleepchart = [sleepchart transpose(1:length(sleepchart))];
%         sleepcharts.(stringtemp) = sleepchart;
%         Remtimestamps = [Remtimestamps (Remtimestamptemp./totaltime)]
        Remtimestampstemp = [Remtimestampstemp; [{length(reporttext)} {length(reporttext)}]];
%         Remtimestamps.(stringtemp) = Remtimestampstemp;
        s0temp = {s0temp};
        s1temp = {s1temp};
        s2temp = {s2temp};
        s3temp = {s3temp};
        s4temp = {s4temp};
        Remtimestampstemp = {Remtimestampstemp};
        totaltimenew = sum(cell2mat(table.events_table((startrec:end), size(table.events_table, 2))));
        totallength = cell2mat(table.events_table((timestart:timeend), size(table.events_table, 2)));
        totallength(totallength ~= 30) = [];
        totallength = length(totallength);
        newtotal = table.events_table((startrec:end), size(table.events_table, 2));
        dur = cell2mat(table.events_table((timestart:timeend), size(table.events_table, 2)));
        dur = sum(dur(dur==30));
        startp = cell2mat(table.events_table((startrec:timestart), size(table.events_table,2 )));
        startp = length(startp(startp == 30));
        endp = cell2mat(table.events_table((startrec:timeend), size(table.events_table,2 )));
        endp = length(endp(endp==30));
        alllen = cell2mat(table.events_table((startrec:end), size(table.events_table, 2)));
        alllen = length(alllen(alllen == 30));

%         dur = sum(dur);
%     catch
%         disp('bug')
%     end
end