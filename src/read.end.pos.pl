#!/usr/bin/perl
use strict;
use warnings;

my ($sam, $len, $start_out, $end_out)=@ARGV;
if ((not defined $sam) || (not defined $len) ||(not defined $start_out) || (not defined $end_out)){
	die "format: \n./read.end.pos.pl <sam.part.input> <length of reference sequence, INT> <start output name> <end output name>\n";
	}
my @len;
my $line;
my @num;
my @cha;
my @new;
my @line;
my @start;
my @end;
my $tempend;
my ($start, $a, $end);
open IN, "<$sam";
open START, ">$start_out";
open END, ">$end_out";
while($line=<IN>){
	chomp $line;
	@line=split(/\s/,$line);
if ($line[0] != 0){
	@num=split(/[A-Z]/,$line[1]);
	@cha=split(/[0-9]/,$line[1]);
	$start=$end=$line[0];
	foreach(@cha){
		if ((defined $_) and !($_ =~ /^$/)){
			push(@new,$_);
		}
	}
#	print "size num=$#num\tsize num=$#new\tcigar is $line[1]\n";
	if (($new[0] eq 'S') and ($num[0] >=5) and ($start < $num[0])){
		$start=$start+$len-$num[0];
	}
	for($a=0;$a<=$#new;$a++){
		
#		print "num=$num[$a]\tcha=$new[$a]\n";
		if($new[$a] =~ /[MD]/){
			$end+=$num[$a];
		}
	}
	$end-=1;
	$tempend=$end+$num[$#num];
	if (($new[$#new] eq 'S') and ($num[$#num] >=5) and ($tempend >=$len)){

        #        print "end=$end, mismatch size = $num[$#num], tempend=$tempend, length=$len\n";
                $end=$end-$len+$num[$#num];
        }
	$start[$start]+=1;
	$end[$end]+=1;
#	print "start=$start\tend=$end\n";
	undef @new;
}
}

for($a=0;$a<=$len;$a++){
	if (not defined $start[$a]){
		$start[$a]=0;	
	}	
	if(not defined $end[$a]){
		$end[$a]=0;
	}
	print START "$a\t$start[$a]\n";
	print END "$a\t$end[$a]\n";	
}
