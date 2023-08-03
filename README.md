# bmg_usleep
Code for utilizing the U-sleep API

NOTE: In this document, when the phrase "python script" is used, it will be in reference to the script "U-Sleep-API-Script" and the phrase "MATLAB script" is in reference to "MPscript_Usleepv2.m". Both of these can be found in this repository.



################################################################################

SETTING UP PYTHON

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

SETTING UP MATLAB

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




