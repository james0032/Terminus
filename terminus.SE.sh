#!/bin/bash

set -ef -o pipefail

usage() {
  cat >&2 << __EOF__
Usage : $0 [options] <input.fasta> <input.fastq> <outdir>

Terminus determination for single-end NGS reads 
<intput.fasta> is the single contig of phage genome assemly
<intput.fastq> is the single end NGS read data
<outdir> will be the name of directory created to the current folder

Options:
    -h                  Show the help information
  
    -w WINDOW_SIZE      Window size in neighboring coverage ratio
                        Default=100
__EOF__
  exit 2
}


#echo "Enter the name of genome <*>.fasta/<*>.fastq (Note: File name <*> must be identical for fasta and fastq): "
#read NAME
#echo "Enter window size <INT> (Default=100 if not specified here): "
#read WIN

WIN=100

while getopts 'hw:' opt; do
  case "$opt" in 
    h)
      usage
      ;;
    w)
      WIN=$OPTARG
      ;;
  esac
done
shift $((OPTIND -1))

if [[ -z "$1" || -z "$2" ]]; then
   usage
fi

OUTDIR=$3
if [[ -z "$3" ]]; then
   OUTDIR="result"
fi

echo "$1 $2 $3"
echo $WIN

mkdir -p $OUTDIR
NAME="`basename $1|cut -d. -f1`"
echo "name=$NAME"
#echo "`readlink -f $0`"
CURDIR=$PWD
echo "input dir = $CURDIR"
ln -sf $CURDIR/$1 $CURDIR/$OUTDIR/$NAME.fasta
ln -sf $CURDIR/$2 $CURDIR/$OUTDIR/$NAME.fastq

INDIR=$(dirname "$0")
srcPATH="$CURDIR/$INDIR/src"
ratioPATH="$srcPATH/ratio.windows.pl"
readPATH="$srcPATH/read.end.pos.pl"
simplePATH="$srcPATH/simple.potential.pl"

cd $OUTDIR
echo "walk into created folder"
echo "`pwd`"
bowtie2-build -f $NAME.fasta $NAME
bowtie2 -x $NAME -U $NAME.fastq --local -S $NAME.local.sam -p 16
samtools faidx $NAME.fasta 
samtools view -bt $NAME.fasta -o $NAME.bam $NAME.local.sam
samtools sort $NAME.bam $NAME.sorted
samtools index $NAME.sorted.bam
samtools mpileup -f $NAME.fasta -d 100000 $NAME.sorted.bam >$NAME.pileup
awk '{print $2 "\t" $3 "\t" $4}' $NAME.pileup >$NAME.pos.base.cov
perl $ratioPATH $NAME.pos.base.cov $NAME.ratio $WIN $NAME.potential.pos $NAME.flanking
awk '{if ($4 ~ /^[0-9]+$/) print $4 "\t" $6}' $NAME.local.sam >$NAME.local.part.sam
LEN=$(tail -n +2 $NAME.fasta |tr -d '\n' |awk '{print length}')
perl $readPATH $NAME.local.part.sam $LEN $NAME.start.cov $NAME.end.cov

mkdir -p output

sort -t $'\t' -k 2 -nr $NAME.start.cov | sed -n 1,10p > output/$NAME.sort.start.cov
perl $simplePATH $NAME.potential.pos output/$NAME.simple.potential.pos
sort -t $'\t' -k 2 -nr $NAME.end.cov | sed -n 1,10p > output/$NAME.sort.end.cov
