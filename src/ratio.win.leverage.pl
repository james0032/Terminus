#!/usr/bin/perl
use strict;
use warnings;

my ($in, $out, $win, $pos, $flank ) =@ARGV;
my @ratio;

if ((not defined $in) || (not defined $out) || (not defined $pos) || (not defined $flank)){
	die "format: \n./ratio.pl <input.mpile.file> <output.ratio> <sliding window size> <potential.position> <flanking.sequence>\n";
	}
open IN, "<$in";
open OUT, ">$out";
open POS, ">$pos";
open FLA, ">$flank";
my $line;
$line=<IN>;
chomp $line;
my @line;
my @seq;
@line=split(/\s/,$line);
my $former;
$former=$line[2];
my $this=0;my $i=0;
$seq[$i]=$line[1];
my @cov;
my @pile;
$cov[$i]=$former;
$pile[$i]=$line;
my $sum+=$former;

while($line =<IN>){
	$i++;
	chomp $line;
	@line=split(/\s/,$line);
	$this=$line[2];
	$seq[$i]=$line[1];
	$cov[$i]=$this;
	$pile[$i]=$line;
	$former=$this;
	$sum+=$former;
	
}
my $avg=$sum/$i;
print FLA "length=$i\ncoverage=$avg\nsize of pile=$#pile\nsize of cov=$#cov\n";
my ($j, $k, $l, $m);
$former =$this =0;
my ($fcov, $tcov);
for ($j=$win-1;$j<=$#cov-$win;$j++){
	for($k=$j;$k>=$j-$win+1;$k--){
	$former+=$cov[$k];
	}
	$fcov=$former/$win;
	for($l=$j+1;$l<=$j+$win;$l++){
	$this+=$cov[$l];
	}
	$tcov=$this/$win;
	$ratio[$j-$win+1]=$tcov/$fcov;
	if ((($ratio[$j-$win+1] >1.8) ||($ratio[$j-$win+1]<=0.556)) && (($tcov < $avg) && ($fcov <$avg))){
	$ratio[$j-$win+1]=1;
	}
	printf OUT "%.3f\t%d\t%d\t%.3f\t%d\t%d\t%.3f\n", $fcov,$j-$win+2,$j+1,$tcov,$j+2,$j+$win+1,$ratio[$j-$win+1];
	if ((($ratio[$j-$win+1] >1.8) ||($ratio[$j-$win+1]<0.5556)) && (($fcov >$avg) || ($tcov >$avg))){
		printf POS "%.3f\t%d\t%d\t%.3f\t%d\t%d\t%.3f\n", $fcov,$j-$win+2,$j+1,$tcov,$j+2,$j+$win+1,$ratio[$j-$win+1];
		printf FLA "potential terminus %d, flanking sequence %d .. %d\n",$j+1, $j-9,$j+11;
		for($m=$j-10;$m<=$j+10;$m++){
			print FLA "$pile[$m]\n";
		}
		printf FLA "sequence: ";
		for($m=$j-10;$m<=$j+10;$m++){
			printf FLA "$seq[$m]";
		}	
		printf FLA "\n";
	
	} 	
	$former = $this =0;
} 
close IN;
close OUT;
close POS;
