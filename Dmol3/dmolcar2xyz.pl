#!/usr/bin/perl -w
#Time-stamp: <Last updated: Zhao,Yafan zhaoyafan@mail.thu.edu.cn 2013-11-25 21:26:53>
# dmolcar2xyz.pl --- ZEVAN
# Created: 08 Nov 2010
# Version: 0.01
use warnings;
use strict;
#This script is written to convert the dmollcar file to an XYZ file for geometry optimization.
#It is written for using cp2k.
#Well, Using an cif file-->POSCAR-->XYZ file also works. I just want to did it in another way.
#Just a little practice.
my $line;
my @array;
my @list;
my $num=0;
open (IN,"<","$ARGV[0]")|| die "Open file $ARGV[0] failed:$!";
while ($line=<IN>) {
    chomp($line);
    @array=split(/\s+/,$line);
    if (@array == 9) {
        $num++;
        push(@list,[$array[7],$array[1],$array[2],$array[3]]); 
        }
}
print "$num\n";
print "Generated with dmolcar2xyz.pl\n";
for my $atom(@list) {
    printf("%-6s%-10.6f %-10.6f %-10.6f\n",$atom->[0],$atom->[1],$atom->[2],$atom->[3] );
}
