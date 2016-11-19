# Terminus

This is a perl-based, bacteriophage (phage) terminus predicting tool by using raw sequencing read data.
The genomic position of terminus sequence is estimated based on method 'neighboring coverage ratio' and 
'read edge frequency'. Please refer to 'Predicting genome terminus sequences of Bacillus cereus-group 
Bacteriophage using Next Generation Sequencing data' for more detail in algorithm (manucsript in preparation).

## DEPENDENCIES:
- **perl** -         The source code are written in perl script. The version used for development was perl v5.20.3. 
                  If perl has not been installed in your operating system, you may try the Anaconda environment 
                  management platform (https://docs.continuum.io/anaconda/install). 
                  If you just want to install perl, please visit www.perl.org for installation and documentation. 
- **bowtie2** -      bowtie2 is a fast and sensitive read mapping tool to create alignment file. 
                  This is an essential tool in terminus pipeline. 
                  Please visit http://bowtie-bio.sourceforge.net/bowtie2/index.shtml for installation. 
- **tools** -    SAM tools is a package for manipulating alignment file in SAM format, covert alignment 
                  between SAM and BAM files, indexing and sorting. 
                  Please visit http://samtools.sourceforge.net/ for installation. 
  Note: to easily check whether your OS has the tools installed, use the command:
  $ which perl (or bowtie2, or samtools)


## GETTING READY:
Fastq file(s) and a fasta file that contains assembled phage genome sequence are necessary for this analysis.
High throughput sequencing only output raw read files in fastq format. The assembled sequence needs to be generated
using assembler. 
Newbler is recommended for Ion Torrent PGM and Roche 454 sequencer (http://www.454.com/products/analysis-software/). 
Velvet is suitable for Illumina (https://www.ebi.ac.uk/~zerbino/velvet/).


## DOWNLOAD & SETUP:
After the input files are generated and dependencies are installed, please download the terminus package from
github repository on https://github.com/james0032/Terminus
The package can be downloaded from github page or cloned by using command:
```
$ git clone --recursive https://github.com/james0032/Terminus`
```
THERE IS NO installation step for terminus package. To make sure the shell script is executale, use command:
```
$ chmod +x terminus.SE.sh
```

## RUNNING terminus:
Phage terminus package runs single-end and pair-end read with terminus.SE.sh and terminus.PE.sh, respectively. 
The program will use the prefix of *.fasta file as prefix of all output files. The output directory can be specified
in the last parameter of command; otherwise, a 'result' directory will be created to save all the output files. 


## Example:
Single-end I12.fastq and phage genome assembly I12.fasta saved in fasta file are provided for demonstration purpose. 
To run the example, go to the example directory in terminus package:
```
$ cd example
```
After check the two example files exist in the folder, use command to run the analysis:
```
$ ../terminus.SE.sh -w 100 I12.fasta I12.fastq I12_terminus
```

## Output files:
The analysis will automatically generate a 'output' folder in the directory you specified. It contains three files:
- *.simple.potential.pos
- sort.start.cov
- sort.end.cov

  ### Output *.simple.potential.pos fields:
  - **L_Avg_Cov**: Average depth of left window (window size was specified in running command; otherwise, DEFAULT = 100)
  - **L_Start**: First nucleotide coordinate of left window on the input fasta file. 
  - **L_End**: Last nucleotide coordinate of left window on the input fasta file. 
  - **R_Avg_Cov**: Average depth of right window.
  - **R_Start**: First nucleotide coordinate of right window on the input fasta file.
  - **R_End**: Last nucleotide coordinate of right window on the input fasta file. 
  - **NCR**: Neighboring coverage ratio (R_Avg_Cov/ L_Avg_Cov)

  ### Output *.sort.start.cov fields:
  - **First column**: Nucleotide coordinate on the input fasta file.
  - **Second column**: 5' read edge frequency at given coordinate. 
  
  ### Output *.sort.end.cov fields:
  - **First column**: Nucleotide coordinate on the input fasta file.
  - **Second column**: 3' read edge frequency at given coordinate. 
