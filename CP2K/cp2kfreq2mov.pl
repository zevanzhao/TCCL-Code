#!/usr/bin/perl -w
# cp2kfreq2mov.pl --- Generating Movie for CP2K freq calculation. Now it works.
# I will try to write my scripts using python in the future.
#Time-stamp: <Last updated: zevan zevan.zhao@gmail.com 2011-11-21 21:04:33>
# Author: Yafan Zhao <zevan.zhao@gmail.com>
# Created: 10 Nov 2011
# Version: 0.01

use warnings;
use strict;
use constant DEBUG => 0;
if(@ARGV != 2){
    die "Usage:$0  <cp2k-freq.out>  <orginal-geo.xyz>\n";
}
my $out=$ARGV[0];
my $geo=$ARGV[1];
my $orig_geo;
my $line;
my $num;#number of atoms.
my ($i,$j,$k);
my ($mode1,$mode2,$mode3);
my @array;
my @modes;

#Read in original geometry.
open(IN,"<",$geo)||die "Failed to open orginal geometry$!\n";
$i = 0;

#Read number of atoms
$line=<IN>;
chomp ($line);
$line=~s/^\s+|\s+$//g;
$num=$line;
if (DEBUG) {
    print "Number of atoms: $num\n";
}

#Read geometry
while ( $line=<IN>) {
    chomp ($line);
    $line=~s/^\s+|\s+$//g;
    @array=split(/\s+/,$line);
    if (4 == @array) {
        for (0..3) {
            $orig_geo->[$i][$_] = $array[$_];
        }
        $i++;
    }    
}

#DEBUG information
if (DEBUG) {
    &print_geo($orig_geo);
}

#A function to print the geometry
sub print_geo{
    my $num=@{$orig_geo};
    print "$num \n";
    print "Original geometry\n";
    for my $array(@{$orig_geo}){
        print "${$array}[0] ${$array}[1] ${$array}[2] ${$array}[3] \n";
    } 
}

#Read the vibrational modes.
#First find the starting point.
open(IN,"<",$out)||die "Failed to open file $out $!\n";
FIND_MODE:while ( $line=<IN>) {
    if ($line=~m/NORMAL MODES/) {
        if (DEBUG) {
            print "Found Normal modes\n";
        }
        last FIND_MODE;
    }
}

#Now begin to read the modes.Read in one empty line.
$line=<IN>;
while ($line=<IN>) {
    chomp ($line);
    $line=~s/^\s+|\s+$//g;
    if ($line=~m/VIB\|\s+(\d+)\s+(\d+)\s+(\d+)/) {
        $mode1=$1-1;
        $mode2=$2-1;
        $mode3=$3-1;
        printf( "Reading mode %d %d %d. \n",$mode1+1,$mode2+1,$mode3+1);
        for (1..5) {
            $line=<IN>;
        }
       MODES:  while($line=<IN>){
            chomp ($line);
            $line=~s/^\s+|\s+$//g;
            @array=split(/\s+/,$line);
            if (11 == @array) {
                #Dirty but simple.
                $modes[$mode1]->[$array[0]-1][0] = $array[2];
                $modes[$mode1]->[$array[0]-1][1] = $array[3];
                $modes[$mode1]->[$array[0]-1][2] = $array[4];
                                
                $modes[$mode2]->[$array[0]-1][0] = $array[5];
                $modes[$mode2]->[$array[0]-1][1] = $array[6];
                $modes[$mode2]->[$array[0]-1][2] = $array[7];
                                
                $modes[$mode3]->[$array[0]-1][0] = $array[8];
                $modes[$mode3]->[$array[0]-1][1] = $array[9]; 
                $modes[$mode3]->[$array[0]-1][2] = $array[10];
            }elsif (0 == @array) {
                last MODES;
            } 
        }
    }
}
# Test if the vibrational modes are read correctly.
if (DEBUG) {
    &print_modes();
}

#Define a function to print vibrational modes
sub print_modes{
    my $tmp_mode;
    my $array;
    my $i;
    for $tmp_mode(@modes) {
        $i=0;
        for $array( @{$tmp_mode}) {
            if (defined($array)) {
                printf("%d %f %f %f \n",$i+1,${$array}[0],${$array}[1],${$array}[2]);
            }
            $i++;
        }
    }
}

 &mode_plus();

#Read the normal modes and save them in files.
sub mode_plus{
    my $tmp_mode;
    my $array;
    my ($i,$j,$k);
    my $name;
    for $tmp_mode(@modes ) {
        $k++;
        $name="mode-"."$k".".xyz";
        print "Generating movie for mode $k.\n";
        open (OUT ,">",$name);
        
        for $j (qw/-0.6 -0.3 0.0 0.3 0.6/) {
            $i=0;
            print OUT  "$num \n";
            print OUT "j = $j\n";
            for $array( @{$tmp_mode}) {
                if (defined($array)){
                    if (DEBUG) {
                        print "Mode: $i ${$array}[0] ${$array}[1] ${$array}[2]\n";
                    }
                    printf OUT ("%s %f %f %f \n",$orig_geo->[$i][0],$j*${$array}[0]+$orig_geo->[$i][1], $j*${$array}[1]+$orig_geo->[$i][2],$j*${$array}[2]+$orig_geo->[$i][3]);
                }else {
                    printf OUT ("%s %f %f %f \n",$orig_geo->[$i][0],$orig_geo->[$i][1],$orig_geo->[$i][2],$orig_geo->[$i][3]);
                }            
                $i++;
            }
        }
    }
    print "Done!\n";
}


__END__

=head1 NAME

cp2kfreq2mov.pl - Describe the usage of script briefly

=head1 SYNOPSIS

cp2kfreq2mov.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for cp2kfreq2mov.pl, 

=head1 AUTHOR

Yafan Zhao, E<lt>zevan.zhao@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Yafan Zhao

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
