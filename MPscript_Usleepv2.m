%matlab end MATLAB-Python tandem TSV producer.
%This script loads data from L-drive (DXA DATA SET) and produces an EDF
%file into an output destination path. This can then be used by the python
%U-Sleep script to process via the online U-Sleep API and then output a
%.TSV file into its own output destination. This script, after seeing the
%new .TSV file will delete the .EDF file it created as to conserve space. 
%BE CAREFUL WHERE YOU PUT THE OUTPUT DIRECTORY FOR THIS SCRIPT, IT CAN
%DELETE FILES.


%For use in U-sleep v2
direc = dir('L:\Lab_JamesR\Paediatric_Sleep\diagnostic\DXA*');
clear scnew
clear global scnew
load('L:\Lab_JamesR\Paediatric_Sleep\studyinfo\scnew.mat');
global scnew
names = fields(scnew);
% names = fields(scnew);
%prog initializes the process
% prog = false;
%quick predict count = 2905;
%813
count = 1;
%BELOW DEFINES INPUT/OUTPUT DIRECTORIES
%It is recommended that 'tsvloc' and 'edfloc' are both empty folders before
%you start this. Also, 'edfloc' MUST be empty before hand else the script
%will through and error saying it doesn't know what postbool is.
tsvloc = 'C:\Data&Scripts\U-Sleep_Hypnograms\v2new'; %location where final output tsv files are to be output
dataloc = 'L:\Lab_JamesR\Paediatric_Sleep\diagnostic\'; %location where the .mat psgdata files are located
edfloc = 'C:\Data&Scripts\Tempbin\'; %location where edf files are TEMPORARYILY located for processing, will be deleted after.
while length(dir(tsvloc)) < length(fields(scnew))
    if length(dir('C:\Data&Scripts\Tempbin')) < 3
        count = count + 1;
        disp(['Loading and converting ' names{count} ' to EDF format']);
        load([dataloc names{1} '\' names{1} '-psgdata.mat']);
        edf_func_v2([edfloc names{count} '.edf'], psgdata);
        pause(1)
        postbool = false;
    else
         pause(1)
        if postbool == false
            disp(['awaiting U-sleep analysis of file ' names{count} '.edf'])
            postbool = true;
        end
            
        uslepdir = dir(tsvloc);
        uslepnames = {uslepdir.name};

        if max(contains(uslepnames, [names{count} '.tsv']))
            delete([edfloc names{count} '.edf']);
            disp(['Sucessfully processed ' names{count}]);
            pause(1)
        end
    end
    
    
end
