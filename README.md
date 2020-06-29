# Gen2Mat
Mostly bashful script for gene sharing matrix. Input is a directory with one file per genome, where each file is multi fasta with amino acid sequences of that genomes predicted proteins. 
Sequences are clsutered (CD-HIT) at supplied criteria. Output is a general gene sharing matrix.
clstr2txt.pl is from CD-HIT. 
*.env file specifics the given positional argument used, which are:

   Positional arguments:
1. Threads
2.	Memory in Mb
3.	output directory
4.	Input directory  (one file *.faa file per genome)
5.	Water mark passed to .env (e.g. "some quoted text").
6.	Minimal id for preclustering sequence collapsing (suggested >= 0.7) 
7.	Minimal coverage for preclustering (suggested >= 0.75) (-aS in cd-hit, aligment coverage of the smaller seq)
8.  Output similarity ("Sym") or dissimilarity (Not "Sym").

