#!/usr/bin/perl -w
#by zevan.zhao@gmail.com on Jul 1, 2010.
#Based on a Fortran Script by Roger.It just works.
use strict;
my $DEBUG=0;
my $Bohr2Angstroms=0.529177;
my $au2eV=27.212;
my ($line,$line1,$line2,$VECTOR,$NP,$DP,$num_atoms,$origin,@coordinates,@data,@sorted_data);
my ($i,$j,$k,$n,$sum,$aveZ,$dist,$const);
#Read line1 and line2
$line1=<>;
$line2=<>;
#Read line3 for number of atoms and origin
chomp($line=<>);
$line=~s/^\s+|\s+$//g;
($num_atoms,$origin->[0],$origin->[1],$origin->[2])=split(/\s+/,$line);
#Read line4-6 for point number and vector 
for(0..2){
    chomp($line=<>);
    $line=~s/^\s+|\s+$//g;
    ($NP->[$_],$VECTOR->[$_][0],$VECTOR->[$_][1],$VECTOR->[$_][2])=split(/\s+/,$line);
}
#Read coordinates of atoms.
while ($line=<>){
    chomp($line);
    $line=~s/^\s+|\s+$//g;
    if($line=~/^(\d+)\s+(.*\s+){3} /){
		push @coordinates,[split(/\s+/,$line)];	
    }else{
	last;
    }
}
#Read all volumetric data.
do{
    chomp($line);
    $line=~s/^\s+|\s+$//g;
    push @data,split(/\s+/,$line);
}while($line=<>);
#Sort the volumetric data to form a 3-dimensional array
$n=0;
for $i(0..$NP->[0]-1){
	for $j(0..$NP->[1]-1){
		for $k (0..$NP->[2]-1){
			$sorted_data[$i][$j][$k]=$data[$n];
			$n++;
		}
	}
}
#average along z-axis
$const=$NP->[0]*$NP->[1];
$sum=0;
for $k(0..$NP->[2]-1){
    for $i(0..$NP->[0]-1){
		for $j(0..$NP->[1]-1){
			$sum+=$sorted_data[$i][$j][$k];
		}
	}
#	$dist=$Bohr2Angstroms*$k*$VECTOR->[2][2];
#	$aveZ=$au2eV*$sum/$const;
#CP2K use hartree and bohr. Just keep using the same units.
	$dist=$k*$VECTOR->[2][2];
	$aveZ=$sum/$const;
	print "$dist\t$aveZ\n";
	$sum=0;
	$j++;
}