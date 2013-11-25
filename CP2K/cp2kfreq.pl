#!/usr/bin/perl -w
use strict;
use constant DEBUG=>0;
if(@ARGV<1){
    print "Usage: cp2kfreq.pl [CP2K OUT FILE]\n";
    exit 0;
}
my $outfile=$ARGV[0];
my $line;
my @array;
my @freq;
open(IN,"<",$outfile)|| die "Failed to open file $outfile.$!\n";
while($line=<IN>){
    if ($line=~/VIB\|Frequency \(cm\^-1\)/){
	#print $line;
	@array=split (/\s+/,$line);
	for (@array){
	    if($_=~/\d+\.\d+/){
		#print $_,"\n";
		push @freq, $_;
	    }
	}
    }
}
close(IN);

#Useless sort 
#sort {$a <=> $b} @freq;
open (OUT,">","freq.dat")||die "failed to open file freq.dat$!\n";
for my $i(@freq) {
    if($i<0){
	print OUT -1*$i," cm^{-1} ... 1\n";
	print -1*$i," cm^{-1} ... 1\n";
    }
    else{
	print OUT "$i cm^{-1} ... 0\n";
	print "$i cm^{-1} ... 0\n";
    }
    
}

