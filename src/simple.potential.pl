#!/usr/bin/perl

use strict;
use warnings;

my ($in, $out) = @ARGV;

if ((not defined $in) || (not defined $out)){
	die "format: \n./simple.potential.pl <input.ratio> <output.simplfied.ratio>\n";
	}
my $line;
my @line;
open IN, "<$in";
open OUT, ">$out";
$line=<IN>;
chomp $line;
@line=split(/\s/,$line);
my $fpos;
$fpos=$line[1];
my $fratio;
$fratio=$line[6];
my ($cpos, $cratio, $difpos);
my @pline;
print OUT "L_Avg_Cov\tL_Start\tL_End\tR_Avg_Cov\tR_Start\tR_End\tNCR\n";
while(<IN>){
	$line=$_;
	chomp $line;
	@line=split(/\s/,$line);
	$cratio=$line[6];
	$cpos=$line[1];
	$difpos=$cpos-$fpos;
	if(($cratio >1) && ($difpos == 1)){
		if($cratio > $fratio){
			@pline=@line;
			print "going up $cratio $fratio $cpos $fpos\n";	
		}
		$fratio=$cratio;
		$fpos=$cpos;
	}
	elsif(($cratio <1) && ($difpos ==1)){
		if($cratio < $fratio){
			@pline=@line;
			print "going down $cratio $fratio $cpos $fpos\n";
		}
		$fratio=$cratio;
		$fpos=$cpos;
	}
	else{
		foreach my $ele (@pline){
		print OUT "$ele\t";
		}
		print OUT "\n";
		$fpos=$cpos;
		$fratio=$cratio;
	}
	
}
foreach my $ele (@pline){
                print OUT "$ele\t";
                }
                print OUT "\n";
