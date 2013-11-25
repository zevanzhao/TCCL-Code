#!/usr/bin/perl
#This script will convert the nwchem optimization log file into an xyz file.
#usage:
#nwlog2xyz.pl YOUR_NWCHEM_OUT_FILE.out >XYZ_FILE_NAME.xyz
use strict;
my $line;
my $energy;
my @array;
my @point3D;
my @molecule;
my $DEBUG=0;
open (IN,"<",$ARGV[0])|| die "Open file failed:$!";

#Find the beginning of Geometry Optimization
do{
    $line=<IN>;
    if(eof(IN)){
#	print "End of file.No optimized structure found. Exit.\n";
	exit;
    }
}while($line!~m/NWChem Geometry Optimization/);

GEOMETRY:while($line=<IN>){
    last GEOMETRY if(eof(IN));

    #The beginning of geometry
    do{
	$line=<IN>;
	last GEOMETRY if(eof(IN));
    }while($line!~m/Geometry "geometry"/);
    
    #Another beginning of geometry.
    do{
	$line=<IN>;
	last GEOMETRY if(eof(IN));
    }while($line!~m/Charge\s+X\s+Y\s+Z/);
    
    #Read the geometry
    @molecule=();
    while($line!~m/^\s+$/){
	if($line=~m/\d+\s+\w+(\s+[+\-]?\d+\.?\d+){4}/){
	    chomp $line;
	    s/^\s+|\s*$//g;
	    push @point3D,split(/\s+/,$line); 
	    push @molecule, [@point3D[3],@point3D[4],@point3D[5],@point3D[6]];
	    @point3D=();
	}
	$line=<IN>;
    }
    #Read the energy
    do{
	$line=<IN>;
	last GEOMETRY if(eof(IN));
    }while($line!~m/Step\s+Energy/);
    #read one more line before the line with energy.
    $line=<IN>;
    
    #This line is the line with energy value.
    $line=<IN>;
    if($DEBUG){
	print $line;
    }
    if($line=~m/\d+\s+\w+/){
	chomp $line;
	s/^\s+|\s*$//g;
	#print $line;
	@array=();
	push @array,split(/\s+/,$line);
	$energy=@array[2];
    }
}
close IN;
#Comment the 2 lines to make things easier.
print $#molecule+1,"\n";
#print "Energy:$energy\n";
print "$energy\n";
foreach(@molecule)
{
    printf ("%d %f %f %f\n",$_->[0],$_->[1],$_->[2],$_->[3]);
}
