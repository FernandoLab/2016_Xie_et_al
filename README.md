Introduction
This is a repository to accompany the mansucript “.” 

BEFORE YOU BEGIN RECREATING THE ANALSYSIS:

Run on MAC but can uncomment lines for linux and comment ones for MAC

Due to licensing issues, USEARCH can not be included in the setup. To obtain a download link, go to the USEARCH download page and select version USEARCH v7.0.1090 for linux. A link (expires after 30 days) will be sent to the provided email. Use the link as an argument for shell script below.

Simply download the bash script from the github repository and run it (provide the link to download your licensed USEARCH version as an argument for setup.sh):

git clone https://github.com/chrisLanderson/2015_PNAS_Xie_et_al.git
cd 2015_PNAS_Xie_et_al
./recreate_analysis.sh usearch_link


Anaconda is downloaded first and prompts you during installataion of the dependencies for the analysis, such as QIIME. The prompts are as follows:

Press enter to view the license agreement
Press enter to read the license and q to exit
Accept the terms
Prompts you where to install anaconda. Simply type anaconda to create a directory within the current directory. Should be: [/Users/user/anaconda] >>> anaconda
No to prepend anaconda to your path. Choosing yes should not impact the installation though.
Will be asked a few times if you wish to proceed with installing the packages…agree to it.



After installation the analysis will begin to generate a file to be used by Maaslin on Galaxy to identify correlations between OTUs and the treatments
