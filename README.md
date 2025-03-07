# NCBI multithread batch download script
this script is a supplement for NCBI Datasets command-line tools (installation link: https://www.ncbi.nlm.nih.gov/datasets/docs/v2/command-line-tools/download-and-install/)

# Description
when we run the command "datasets download genome accession --filename *.txt", it is common to encounter the errors mentioned below:

`Error: Download error: http2: server sent GOAWAY and closed the connection; LastStreamID=2147483647, ErrCode=NO_ERROR, debug=""`

`Use datasets download genome accession <command> --help for detailed help about a command.`

Then the command will be terminated. 

The original command is not suitable for the large amount of genomes with accession ID.

This script is designed to combine parallel and NCBI Datasets command-line tools to implement a faster download procedure, and provide the robust function in checking, multithread download, and secure the integrity of files.

# Requirement

Before you run this script, please make sure you have already installed NCBI Datasets command-line tools and parallel

`conda install ncbi-datasets-cli parallel`

all you need is `accession.txt' containing accession ID, retrieved and downloaded from NCBI database, and 'downloaded_genomes.sh' in this repository

# Usage

you can run this script in your Server backend, you can change the thread or API key you want to use in this script.

`nohup bash downloaded_genomes.sh > ncbi_download.log`
