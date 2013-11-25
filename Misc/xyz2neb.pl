#!/usr/bin/perl -w
# This is a "quick and dirty" perl script to generate NEB images for CP2K.
# Hope it works.
use strict;
use warnings;
my $INI=$ARGV[0];
my $FIN=$ARGV[1];
my $num=$ARGV[2];
my @coord1;
my @coord2;
my @array;
my $line;
my ($i,$j,$k);
#Read initial geometry
open (INI,"<",$INI) || die "Failed to open $INI : $!";
while($line=<INI>){
    chomp $line;
    $line=~s/^\s+|\s+$//g;
    @array=split(/\s+/,$line);
    if(@array==4){
	push (@coord1,[@array]);
    }    
}
close(INI);

#Read final geometry
open (FIN,"<",$FIN)|| die "Failed to open $FIN : $!";
while($line=<FIN>){
    chomp $line;
    $line=~s/^\s+|\s+$//g;
    @array=split(/\s+/,$line);
    if(@array==4){
	push (@coord2,[@array]);
    }    
}


#Generate geometries
for $i(0..$num){
    my $name=$i.".xyz";
    open (OUT,">","$name")||die "Failed to open $name : $!";
    print OUT scalar @coord1."\n";
    print OUT "Geometry-".${i}."\n";
    for $j (0..@coord1-1){
	@array=();
	for $k(1..3){
	    $array[$k]=$coord1[$j]->[$k]+($coord2[$j]->[$k]-$coord1[$j]->[$k])*$i/$num;
	}
	print OUT "$coord1[$j]->[0] $array[1] $array[2] $array[3]\n";
    }
    close(OUT);
}
