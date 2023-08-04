# bmg_usleep
Code for utilizing the U-sleep API

NOTE: In this document, when the phrase "python script" is used, it will be in reference to the script "U-Sleep-API-Script" and the phrase "MATLAB script" is in reference to "MPscript_Usleepv2.m". Both of these can be found in this repository.



################################################################################

SETTING UP THE PYTHON SCRIPT

In order to run the u-sleep api and have it automatically recieve EDF file inputs from a given dataset that is formatted to the .mat format, one must first operate VSCode through a proxy in order to bypass the QIMR firewall for this given operation.
This is started by openning CMD (windows command line) and writing and executing the following code:

set http_proxy=http://user:password@webproxy.adqimr.ad.lan:8080

set https_proxy=http://user:password@webproxy.adqimr.ad.lan:8080

Then run vscode through the command lines, an example of how to do this can be seen below:

"C:\Users\alexW\AppData\Local\Programs\Microsoft VS Code\Code.exe"

Though the path will be a bit different. The path can be found by finding the VSCode executible and right clicking it, going into properties and under the shortcut tab (which should be open by default) you will find the line "Target" with the full address of the vscode. Copy this path (the one found next to the target field) and paste it into the command line you used to activate the proxy earlier. This will open VSCode such that you can call for data/processes over the internet.

Now, we need packages to run the API, first, the API itself. If not already done, install pip from the extensions tab in VSCode. Then, if not done already, write the following commands in into the VSCode command line.

pip -install usleep-api

This will install the usleep api package.

Repeat this step for the other packages used by the script, so that is to say, execute the following commands in that same command line:

pip -install os
pip -install time
pip -install logging
pip -install pdb

Now this is done, we can open up the python script confident it won't throw errors (probably).

Next step is to organize and input and output directory for the script to input and output. The input directory is where it will find and use the .edf files produced by the matlab script that will run in tandem with out python script. The output directory is exactly what it sounds like, a directory where the usleep prediction output files (.tsv formatted) will be placed. Note: the input directory needs to be empty, and it is recommended the output directly is empty as well. 

It is advised that one creates a parent folder that contains daughter folders that contains the out files.

e.g. 

C:\User\U-Sleep-Predictions\    <---- would be the parent directory which contains the daughter directories.

C:\User\U-Sleep-Predictions\U-Sleep_ver_2    <---- would be the daughter directory that takes in the .tsv files.

This was one can have a folder that contains all of their outputs organized however the user wishes.

Once these directories have been set up, next is to replace the values of the variables inside the python script with them, the variables' names are inputdir and outputdir for the input directory and output directory respectively. Once done, the python script is ready, however, there is no point starting it as we have yet to set up the MATLAB script.



################################################################################################

SETTING UP THE MATLAB SCRIPT

The MATLAB script is mostly simpler than the python script. However, it is much, much more sensitive to the input/output directories as it is capable and willing to delete files in those directories, so DO NOT STORE ANYTHING IN THESE DIRECTORIES. 

First step is to ensure the script and all its subfunctions are on path and able to be executed. This includes the following scripts/functions.

Event_func_1.m

MPscript_Usleepv2.m

edf_func_v2.m

eeg_lr.m


Optional, but recommended are:

tsvstd.m

usleepComparer.m


These last two allow for the easy loading and reading of .tsv files (usleep output files) and comparissons between the usleep predictions and ground-truth results. 


The main script is MPscrpt_Usleepv2.m, this is the script that creates the .edf's, places them in the input directory, awaits for the tsv file output and then deletes the .edf file it created as to conserve space (they are around 100MB each, so all of them would be close to ~0.5TB). 

It has three major variables that you MUST alter and must ensure is set up correctly. These variables are:


-tsvloc

-dataloc

-edfloc

Thee variables are all char's that are paths to specific directories (the ones we set up earlier).
The first variable (tsvloc) is the directory path of the location of where the final output by the U-sleep API are located (the .tsv's). This is in essence the final output destination that we defined in our python script (outdir).
The second variable (dataloc) is the directory that contains the .mat files (by default the L-drive location), this can be left unaltered if one does not have a local save of the .mat data files for use, however, if one does, it is suggested to use the local directory instead as it will be much, much faster.
The final variable (edfloc) is the location where the temporary .edf files are stored for the python script to grab for their computations. That is, it is an empty folder that this MATLAB script will generate and place .edf files into, then, after that file has been read and processed by the U-sleep python script, the MATLAB script then deletes the aforementioned .edf to conserve space. 

An example of how to set these varibles up:

Let's start with three folders, we will create them on the local drive for quick processing. We create a master directory to contain them all: C:\U-sleep\.
Then, we fill this directory with three folders, one is the temporary data store (edfloc) which we will call tempbin, this means it will have the path C:\U-sleep\tempbin.
Next, we create the final output directory for the .tsv files (tsvloc) which we will call Hypnograms, giving it the path C:\U-sleep\Hypnograms\.
Finally, we have our data store which contains our .mat files (dataloc). Let's assume the .mat files are already loaded into some local directory C:\data\. [if the data were not already stored and we just wished to run the analysis over the DXA data set, we would use the default directory L:\Lab_JamesR\Paediatric_Sleep\diagnostic\.



################################################################################

MATLAB SUBFUNCTIONS/VARIABLES

This sesction is dedicated to the subfunctions utilized by the MATLAB script as well as the scnew.mat variable, this section is non-essential 


scnew.mat

The variable scnew.mat is a data structure containing a multitude of data structures each corresponding to a subject in the DXA data set. Each of the subjects contains their study's hypnogram (called sleepchart) as well as other details about the hypnogram. The timestart field is the time, in the -events.mat file of that subject that the analysis had started (the index in which it started, rather). timeend is the same but for the end of the analysis. startrec is the end of the header of the file, so when sleep states/device information had started recording (calibration until timestart). totallength is the length between timestart and timeend excluding the events that are not 30 seconds long. dur is the total tallied time of the study in seconds, essentially the number of seconds between the start of the study and the end of the study. startp, endp are the start and end points as prior, but scaled down by filtering out the non 30 second events, alllen is the totallength when scaled like this. 
The impetus for ommitting the non 30 second events is due to the way the -events.mat files tally time. They (typically) only count the actual sleep states to the total time, with the non-sleep state events having a non 30 second time to describe how long they went for. This is likely done for use in measuring duration of apnoeas, coordinating data around device calibrations, etc. 



edf_func_v2.m

This (admittedly hideous) function takes in the name of the subject (e.g. DXA_45) as a char or string as the first argument, and the psgdata as the second argument. This then takes the data, finds the 'C4' and 'LOC' channel in the psg data and then cuts the data into the part that is present during the sleep-state analysis (as found in the -events.mat file). After this, it resamples it to 128 hz (which is wanted by U-sleep v2) and then takes all this data, constructs a header for an EDF+C file and outputs a EDF file








