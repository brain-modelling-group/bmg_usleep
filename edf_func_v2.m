%%edf writer for DXA Data set
%function takes in psg and data as well as the patient name
%(e.g DXA_45) and outputs a edf data file of said data.
%This also takes the portion of the eeg data estimated to be aligned with
%the sleep staging data "Analysis-Start" and "Analysis-End" lines, as to
%coordinate data. After this, it then resamples the data to 128 hertz as
%that is the sample rate U-sleep desires for its functions.

function edfoutput = edf_func_v2(pathsub, psg)
    
    %% getting start/stop of data from scnew table
    evalin('base', "if ~exist('scnew', 'var'); load('L:\Lab_JamesR\Paediatric_Sleep\studyinfo\scnew.mat');end")
    evalin('base', "global scnew")
    name = strfind(pathsub, 'DXA');
    name = pathsub(name:length(pathsub));
    name = erase(name, '.tsv');
    name = erase(name, '.mat');
    name = erase(name, '.edf');
    global scnew
    %if the dxa subject doesn't have a event file, it will approximate the
    %start of the study using the eeg_lr() function. This is unoptimal.
    if isfield(scnew, name)
        startp = (scnew.(name).startp)/(scnew.(name).alllen);
        endp = (scnew.(name).endp)/(scnew.(name).endp);
        dur = scnew.(name).dur;
        noeventbool = false;
    else
        noeventbool = true;
    end
    
    
    %% main
    %finding structure indexes for useful signals
    signdxs = [nan, nan, nan, nan];
    %signdxs is an array of the signal indexes in the structure in the
    %order of [C4, F4, O2].
    psgdata = psg;  
    for j = 1:length(psgdata)
        if strcmp(psgdata(j).channelName, 'C4')
            signdxs(1) = j;
        elseif strcmp(psgdata(j).channelName, 'F4')
            signdxs(2) = j;
        elseif strcmp(psgdata(j).channelName, 'LOC')
            signdxs(3) = j;
        elseif strcmp(psgdata(j).channelName, 'ROC')
            signdxs(4) = j;
        end
    end
    %scale is what all data is multiplied to to reduce the size of the
    %physicalmax and physical min values, which for some reason are capped
    %at 12 bytes a piece. This is why they are stored as int16 variables.
    scale = 1e5;%e3;
    %constructing Header
    seglen = 3000;
%     data = [{0} {0}];
    sig1 = psgdata(signdxs(1)).data;
    sig2 = psgdata(signdxs(2)).data;
    sig2 = psgdata(signdxs(3)).data;
    fs = [psgdata(signdxs(1)).fs; psgdata(signdxs(2)).fs; psgdata(signdxs(3)).fs];
%     for k = 1:((((length(psgdata(signdxs(1)).data)))/3000)-1)  %%1:(floor((length(((psgdata(signdxs(1)).data))/3000)))-1)
%         data{1} = [data{1}; [sig1((3000*k):(3000*(k+1)))]];
%         data{2} = [data{2}; [sig2((3000*k):(3000*(k+1)))]];
%     end
    data = [{((psgdata(signdxs(1)).data))} {psgdata(signdxs(3)).data}];
    %% using data at analysis-start/analysis-stop and resampling to 128 hz
%     data = [{(resample(((double(psgdata(signdxs(1)).data))), 128, psgdata(signdxs(1)).fs)).*scale}  {(resample(double((((psgdata(signdxs(3)).data)))), 128, psgdata(signdxs(1)).fs)).*scale}];
    dat1 = data{1};
    dat2 = data{2};
    %This is the part that uses the eeg_lr() function to approximate the
    %start and end of the useful signal information.
    if noeventbool == false
        dat1 = dat1(ceil((startp*length(data{1}))):floor((endp*length(data{1}))));
        dat2 = dat2(ceil((startp*length(data{2}))):floor((endp*length(data{2}))));

        data = [{dat1} {dat2}];
        data = [{resample(double(dat1), 128, 200)} {resample(double(dat2), 128, 200)}];
    else
        disp('no scnew field found for subject')
        dat1 = eeg_lr(dat1);
        dat2 = eeg_lr(dat2);

        data = [{dat1} {dat2}];
    end
    
    
    fs = [128, 128];
%     data = [{eeg_lr(data{1}, 3)} {eeg_lr(data{2}, 3)}]; %artefact removal
    %constructing header
    hdr = edfheader("EDF+");
    hdr.Reserved = "EDF+C";
    hdr.NumDataRecords = 1;
    hdr.NumSignals = 2;
    hdr.SignalLabels = [string(psgdata(signdxs(1)).channelName), "EOG"];
%     hdr.SignalLabels = [string(psgdata(signdxs(1)).channelName),...
%         string(psgdata(signdxs(2)).channelName), ... 
%         "EOG"];
    hdr.PhysicalDimensions = ["uV" "uV"];
%     hdr.DigitalMin = [int32(min(data{1})), ...
%         int32(min(data{2})), ...
%         int32(min(data{3}))];
%     hdr.DigitalMin = [int16(-32767*scale), ...
%         int16(-32767*scale)];
%     hdr.DigitalMax = [int16(32767*scale), ...
%         int16(32767*scale)];
%     hdr.PhysicalMin = [int16(-32767*scale), int16(-32767*scale)];
%     hdr.PhysicalMax = [int16(32767*scale), int16(32767*scale)];
    max1 = double(max(data{1}));
    min1 = double(min(data{1}));
    max2 = double(max(data{2}));
    min2 = double(min(data{2}));
    
    hdr.DigitalMin = [double(-1e32), ...
        double(-1e32)];
    hdr.DigitalMax = [double(1e32), ...
        double(1e32)];
    hdr.PhysicalMin = [double(-1e32), double(-1e32)];
    hdr.PhysicalMax = [double(1e32), double(1e32)];
    data = [double(data{1}) double(data{2})];
%     timer = double(ceil(length(data)/(128*30)));
    hdr.Prefilter = ["none", "none"];
    hdr.TransducerTypes = ["AgAgCl electrodes", "AgAgCl electrodes"];
    if noeventbool == false
        hdr.DataRecordDuration = seconds(dur);%seconds(length(data)/fs(1));
    else
        hdr.DataRecordDuration = seconds(floor(length(data)/(128*30)));
    end

%     data = data';

%     hdr.SignalReserved = "";
    %writing to edf
%     [hdr1, record] = edfRead('L:\Lab_JamesR\alexW\Usleep_example_data\SC4001E0\SC4001E0-PSG.edf');
    
    
    edfw = edfwrite(pathsub, hdr, (data.*scale));
end

