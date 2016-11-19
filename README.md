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
Single-end I13.fastq and phage genome assembly I13.fasta saved in fasta file are provided for demonstration purpose. 
To run the example, go to the example directory in terminus package:
```
$ cd example
```
After check the two example files exist in the folder, use command to run the analysis:
```
$ ../terminus.SE.sh -w 100 I13.fasta I13.fastq I13_terminus
```
 ### Result interpretation:
 I13.simple.potential.pos shows three nucleotide positions of significant NCRs. 
```
L_Avg_Cov       L_Start L_End   R_Avg_Cov       R_Start R_End   NCR
425.320 82031   82130   223.860 82131   82230   0.526   
**400.110 111500  111599  814.750 111600  111699  2.036**
**840.610 114260  114359  352.680 114360  114459  0.420**
```

 One region that has NCR higher than criteria (NCR>=1.8) followed by a region with significantly lower NCR (NCR <=0.556) forms the high coverage region that is potentially the repeat region of a phage genome. 
 The adjacent nucleotide position is the potential start of one genome terminus (position 111600 with NCR=2.036) while adjacent nucleotide position on the next row is the potential end of another genome terminus (position 114359 with NCR=0.420). 

 I13.sort.start.cov shows nucleotide positions with top 10 Read Edge Frequencies from 5' end of raw reads (5'REF). 
```
**111610  110**
107673  71
111537  63
111411  61
49849   49
111608  44
154643  43
113983  40
111595  37
106924  37
```
 Position 111610 has the highest 5'REF, which locates within the window 111600-111699 with highest NCR=2.036. The terminus selection is set to be determined by position of read edge frequency if it locates within the window. 

 I13.sort.end.cov shows nucleotide positions with top 10 Read Edge Frequencies from 3' end of raw reads (3'REF). 
```
**114359  274**
114358  93
41587   73
126350  37
50720   36
126679  32
13414   30
114356  30
114355  30
63176   27
```
 Position 114359 has the highest 3'REF, where is right on the edge of window 114360-114359 with lowest NCR=0.420. 

 This data suggests that the termini of I13 are not the end of assembled sequence on I13.fasta; instead, it has potential termini on position 111610 and 114359, which forms a linear phage genome with direct terminal repeat with size 114359-111610+1=2750 bp. 

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
  - **Second column**: 5' Read Edge Frequency (5'REF) at given coordinate. 
  
  ### Output *.sort.end.cov fields:
  - **First column**: Nucleotide coordinate on the input fasta file.
  - **Second column**: 3' Read Edge Frequency (3'REF) at given coordinate. 
