#!/bin/bash

set -euf -o pipefail

#echo "$0 $1 $2"

usage() {
  cat >&2 << __EOF__
Usage : $0 [options] <input.fasta> <input.fastq> <outdir>

Terminus determination for single-end NGS reads 
<intput.fasta> is the single contig of phage genome assemly

Options:
    -h			Show the help information
  
  [Optional]
    -w WINDOW_SIZE	Window size in neighboring coverage ratio
			Default=100
    -f FOLD_CHANGE	Fold change criterium for calling significant
			neighboring coverage ratio
			Default=1.8
__EOF__
  exit 2
}

timestamp() {
  echo -e "$(date '+$%y-%b-%d %H:%M:%S')\t$"
}

dependencies() {
  for x in "$@"; do
    if ! which "$x" &>/dev/null;then
      echo "Could not find essential tool: $x!"
      exit -1
    fi
  done
} 

WINDOW_SIZE=100
FOLD_CHANGE=1.8

while getopts 'hw:f:' opt;do
  case "$opt" in 
    h)
      usage
      ;;
    w)
      WINDOW_SIZE=$OPTARG
      ;;
    f)
      FOLD_CHANGE=$OPTARG
      ;;

  esac
done
shift $((OPTIND - 1))

#if [[ -z "$1" || -z "$2"]];then
#  usage
#fi 

NAME=$1
OuTDIR=$2

#echo "Enter the name of genome <*>.fasta : "
#read NAME
#echo "Enter window size <INT>: "
#read WIN

bowtie2-build -f $NAME.fasta $NAME
bowtie2 -x $NAME -U $NAME.fastq --local -S $NAME.local.sam -p 16
samtools faidx $NAME.fasta 
samtools view -bt $NAME.fasta -o $NAME.bam $NAME.local.sam
samtools sort $NAME.bam $NAME.sorted
samtools index $NAME.sorted.bam
samtools mpileup -f $NAME.fasta -d 100000 $NAME.sorted.bam >$NAME.pileup
awk '{print $2 "\t" $3 "\t" $4}' $NAME.pileup >$NAME.pos.base.cov
ratio.windows.pl $NAME.pos.base.cov $NAME.ratio $WIN $NAME.potential.pos $NAME.flanking
awk '{print $4 "\t" $6}' $NAME.local.sam >$NAME.local.part.sam

LEN=$(tail -n +2 $NAME.fasta |tr -d '\n' |awk '{print length}')
read.end.pos.pl $NAME.local.part.sam $LEN $NAME.start.cov $NAME.end.cov
sort -t $'\t' -k 2 -nr $NAME.start.cov >$NAME.sort.start.cov
sort -t $'\t' -k 2 -nr $NAME.end.cov >$NAME.sort.end.cov
./../simple.potential.pl $NAME.potential.pos $NAME.simple.potential.pos

exit 0
