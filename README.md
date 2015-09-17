##Introduction
This is a repository to help recreate the microbiota analysis from the mansucript “Obesity, Ovarian Inflammation and Altered Gut Microbial Composition are Associated with Increased Oocyte Specific Transcripts.”  

##To recreate the microbiota analysis:

The script below to recreate the analysis will download and install all software dependencies using Anaconda and subsequently complete the analysis. The final output is a file to upload to MaAsLin on Galaxy to identify correlations between OTUs and associated metadata.

**Due to licensing issues, USEARCH could not be included as a dependency that is automatically downloaded and installed. To obtain a download link, go to the USEARCH download page and select version USEARCH v7.0.1090 for linux. A link (expires after 30 days) will be sent to the provided email. Use the link as an argument for shell script below.**

To begin, simply clone this repository and run the recreate_analysis.sh script (provide the link to download your licensed USEARCH version as an argument for setup.sh):

*git clone https://github.com/chrisLanderson/2015_PNAS_Xie_et_al.git
*cd 2015_PNAS_Xie_et_al
*./recreate_analysis.sh usearch_link

Anaconda is downloaded first and prompts you during installataion of the dependencies for the analysis, such as QIIME. The prompts are as follows:

*Press enter to view the license agreement
*Press enter to read the license and q to exit
*Accept the terms
*Prompts you where to install anaconda. Simply type anaconda to create a directory within the current directory. Should be: [/Users/user/anaconda] >>> anaconda
*No to prepend anaconda to your path. Choosing yes should not impact the installation though.
*Will be asked a few times if you wish to proceed with installing the packages…agree to it.


After installation the analysis will begin and eventually generate an output (wood.otu_table.upload_maaslin.txt) to be used as an input for MaAsLin on Galaxy to identify correlations between OTUs and metadata.
