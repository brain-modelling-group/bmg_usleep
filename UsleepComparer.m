%Hypnogram Comparer
%This scrip

if ~exist('scnew', 'var')
    load('C:\Data&Scripts\scnew.mat');
end

fieldnames = fields(scnew);
directory = dir('C:\Data&Scripts\U-Sleep_Hypnograms\v2new');
directory = directory((3:end),:);
directory = {directory.name};
directory = directory';
lendisc = [];
namelist = [];
diffmat = [];
statearray = [];

for j = 1:length(directory)
    if isfile(['C:\Data&Scripts\U-Sleep_Hypnograms\v2new\' directory{j}]) && isfield(scnew, erase(directory{j}, '.tsv'))
        usleep = tsvstd(['C:\Data&Scripts\U-Sleep_Hypnograms\v2new\' directory{j}]);
        realsleep = scnew.(erase(directory{j}, '.tsv')).sleepchart;
        realsleep = realsleep(:,1);
        lendisc = [lendisc; [length(usleep) - length(realsleep)]];
        namelist = [namelist; string(directory{j})];
        
        %Below organizes data into tertiary categories (wake, nrem and rem)
        %with wake = 0, nrem = 1 what rem = 2.
        for k = 1:length(usleep) 
            if usleep{k} == 1 || usleep{k} == 2 || usleep{k} == 3
                usleep{k} = 1;
            elseif usleep{k} == 5
                usleep{k} = 2;
            end
        end
        
        for k = 1:length(realsleep) 
            if realsleep(k) == 1 || realsleep(k) == 2 || realsleep(k) == 3 || realsleep(k) == 4
                realsleep(k) = 1;
            elseif realsleep(k) == 5
                realsleep(k) = 2;
            end
        end
        
        if length(usleep) < length(realsleep)
            for k = 1:(length(realsleep) - length(usleep))
                usleep = [0; usleep];
            end
        elseif length(usleep) > length(realsleep)
            for k = 1:(length(usleep) - length(realsleep))
                realsleep = [realsleep; 0];
            end
        end
        tempdiffmat = [];
        statetable = zeros(3);
        %state table is a 3x3 matrix that contains correct predictions and
        %false predictions in the order of wake, nrem and then rem, with
        %the columns represent the real sleep states and the rows represent
        %predicted states.
        
        for k = 1:length(usleep)
            colnum = realsleep(k) + 1;
            rownum = usleep{k} + 1;
            statetable(rownum, colnum) = statetable(rownum, colnum) + 1;
            if usleep{k} ~= realsleep(k)
                tempdiffmat = [tempdiffmat; 0];
            else
                tempdiffmat = [tempdiffmat; 1];
            end
        end
        
        diffmat = [diffmat; (sum(tempdiffmat)/length(tempdiffmat))];
        statearray(:,:,(size(statearray, 3)+1)) = statetable;
% %         
%         figure()
%         plot(cell2mat(usleep))
%         hold on
%         plot(realsleep(:,1))
%         legend('U-Sleep', 'Real Sleep')
%         title(directory{j});
%         hold off
    else
%         disp(['couldnt find ' directory{j}]);
    end
    
%     realsleep = scnew.(fieldnames{j}).sleepchart;
%     rslength = scnew.(fieldnames{j}).timeend - scnew.(fieldnames{j}).timestart;
    
    
    
end
statearray(:,:,1) = [];
accmean = mean(diffmat)
accmed = median(diffmat)
