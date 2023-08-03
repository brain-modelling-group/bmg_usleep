%%U-Sleep .tsv Processing
%This function takes in the U-sleep tsv and outputs a column vector that
%contains the sleep states in 30 second segments.
%Take input of the path to the tsv file.
%The purpose of this function is essentially to read out the tsv in a
%convenient format.
function [outputtsv] = tsvstd(path, type)
    [data, header, raw] = tsvread(path);
    outputtsv = [];
    for j = 2:(size(raw, 1) - 0)
        if strcmpi(raw{j, 3}, 'wake')
            for n = 1:floor(str2num(raw{j, 2})/30)
                outputtsv = [outputtsv; {0}];
            end
        elseif strcmpi(raw{j, 3}, 'REM')
            for n = 1:floor(str2num(raw{j, 2})/30)
                outputtsv = [outputtsv; {5}];
            end
    %             states(j) = {5};
        elseif strcmpi(raw{j, 3}, 'N1')
            for n = 1:floor(str2num(raw{j, 2})/30)
                outputtsv = [outputtsv; {1}];
            end
    %             states(j) = {1};
        elseif strcmpi(raw{j, 3}, 'N2')
            for n = 1:floor(str2num(raw{j, 2})/30)
                outputtsv = [outputtsv; {2}];
            end
    %             states(j) = {2};
        elseif strcmpi(raw{j, 3}, 'N3')
            for n = 1:floor(str2num(raw{j, 2})/30)
                outputtsv = [outputtsv; {3}];
            end
    %             states(j) = {3};
        end
    end

end
