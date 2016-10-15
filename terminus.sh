#!/bin/sh

:<<'END'
echo "Enter the name of genome <*>.fasta : "
read NAME
echo "Enter window size <INT>: "
read WIN
END
NAME=$1
WIN=$2
bowtie2-build -f $NAME.fasta $NAME
bowtie2 -x $NAME -1 $NAME.R1.fastq -2 $NAME.R2.fastq --local -S $NAME.local.sam -p 16
samtools faidx $NAME.fasta 
samtools view -bt $NAME.fasta -o $NAME.bam $NAME.local.sam
samtools sort $NAME.bam $NAME.sorted
samtools index $NAME.sorted.bam
samtools mpileup -f $NAME.fasta -d 100000 $NAME.sorted.bam >$NAME.pileup
awk '{print $2 "\t" $3 "\t" $4}' $NAME.pileup >$NAME.pos.base.cov
ratio.win.leverage.pl $NAME.pos.base.cov $NAME.ratio $WIN $NAME.potential.pos $NAME.flanking
awk '{print $4 "\t" $6}' $NAME.local.sam >$NAME.local.part.sam

LEN=$(tail -n +2 $NAME.fasta |tr -d '\n' |awk '{print length}')
read.end.pos.linear.pl $NAME.local.part.sam $LEN $NAME.start.cov $NAME.end.cov
sort -t $'\t' -k 2 -nr $NAME.start.cov >$NAME.sort.start.cov
sort -t $'\t' -k 2 -nr $NAME.end.cov >$NAME.sort.end.cov
./../simple.potential.pl $NAME.potential.pos $NAME.simple.potential.pos
