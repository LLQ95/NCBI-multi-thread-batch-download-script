# NCBI multithread batch download script
this script is a supplement for NCBI Datasets command-line tools (installation link: https://www.ncbi.nlm.nih.gov/datasets/docs/v2/command-line-tools/download-and-install/)

when we run the command "datasets download genome accession --filename *.txt", it is common to encounter the errors mentioned below:

Error: Download error: http2: server sent GOAWAY and closed the connection; LastStreamID=2147483647, ErrCode=NO_ERROR, debug=""
Use datasets download genome accession <command> --help for detailed help about a command.

Then the command will be terminated. The original command is not suitable for the large amount of genomes with accession ID.

This script is designed to combine parallel and NCBI Datasets command-line tools to implement a faster download procedure, and provide the robust function in checking, multithread download, and secure the integrity of files.

