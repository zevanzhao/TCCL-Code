#!/usr/bin/perl -w
# Time-stamp: <Last updated: Zhao,Yafan zhaoyafan@mail.thu.edu.cn 2013-11-25 13:45:55>
# cp2knebforces.pl --- extract force from NEB result.
# Created: 12 Jan 2011
# Version: 0.03
#This script is written to extract force and energy information from the output of CP2K neb calculation.
use warnings;
use strict;
use constant MAX_FORCE=>0.001;
use constant DEBUG=>0;#Swich for debug.
if (@ARGV<1) {
    print "Not enough args.";
    print "Usage:nebforce.pl FILENAME.OUT\n";
    exit;
}
my $input=$ARGV[0];
my $line;
my @array;
my @force;
my @energy;
my $num_atom;
my $num_replica;
my $force_list;
my ($tmp_step_num,$tmp_max_force);
#Keep a record of line number.Just for debugging purpose.
my $line_num=0;
open (IN,'<',$input) || die "Failed to open file $input :$!";
$num_atom=&TotalAtoms();
$num_replica=&TotalReplicas();
print "Total number of atoms:$num_atom\n";
print "Number of replicas: $num_replica\n";

#Main Function. Really simple, isn't it?
#Attention: Only read $line in functions. Make sure every single line will be read!
while (1) {
    last if eof(IN);
    &Find_Begin();
    $force_list=&Read_Energy_and_Force();
    ($tmp_step_num,$tmp_max_force)=&Read_Summary();
    &Print_Force($force_list,$tmp_step_num,$tmp_max_force);
}

#Find total number of atoms.
sub TotalAtoms{
    my $num;
    #Just read in one line.
    $line=<IN>;
    $line_num++;
   ATOM:    while (1) {
        if ( $line=~/TOTAL NUMBERS AND MAXIMUM NUMBERS/) {
            while (1) {
                if ($line=~/Atoms:\s+(\d+)\s*$/ ) {
                    $num=$1;
                    last ATOM;
                }
                #I should define the following two lines as a macro? But I don't know how.
                $line=<IN>;
                $line_num++;
            }
        }else {
            $line=<IN>;
            $line_num++;
        }
    }
    if (DEBUG) {
        print "Find Total Atom Number in line $line_num :$line\n";
    }
    return $num;
}

#Find the number of replicas
#This function should be called after TotalAtoms.
sub TotalReplicas{
    my $num;
REPLICA:    while (1) {
        if ( $line=~/Number of Images :\s+(\d+)\s+/) {
            $num=$1;
            last REPLICA;
        }else {
            $line=<IN>;
            $line_num++;
        }
    }
    if (DEBUG) {
        print "Find Total Replicas number in line $line_num: $line\n";
    }
    return $num;
}

#Find the beginning of energy and force section.
sub Find_Begin{
    while (1) {
        if (eof(IN)){
	    print "END OF OUT FILE. EXITING...\n";
	    exit;
	}
        if ($line=~/Computing Energies and Forces/) {
            last;            
        }else {
            $line=<IN>;
            $line_num++;
        }
    }
    if (DEBUG) {
        print "Find Begin of Energy and Forces in line $line_num:$line\n";
    }
}

#Read Energy and Force from 
sub Read_Energy_and_Force{
    #Read replica serial number.
    my ($serial,$energy);
    my @array;
    my ($i,$j,$k);
    my $force;
    my @force_atom;
    my @force_molecule;
    my @force_replicas;
        for (1..$num_replica ) {
            $line=<IN>;
            $line_num++;
            if (eof(IN)){
                print "END OF OUT FILE. EXITING...\n";
                exit;
            };
            if ($line=~/REPLICA Nr.\s+(\d+)- Energy and Forces/) {
                $serial=$1;
                if (DEBUG) {
                    print "Find Energy and Forces from line $line_num : $line\n";
                }
            }else {
                print "Warning: No serial number found!\n";
            }
            
            #Read energy
            $line=<IN>;
            $line_num++;

            if ( $line=~/Total Energy:\s+([+\-]\d+\.\d+)\s+$/) {
                $energy=$1;
                if (DEBUG) {
                    print "Read Energy from line $line_num: $line\n";
                }
            }else{
                print "Warning: No energy value found!\n";
            }
            #Extra line;
            $line=<IN>;
            $line_num++;
            
            @force_molecule=();
            push @force_molecule,$energy;
            for $i(1..$num_atom) {
                $line=<IN>;
                $line_num++;
                $line=~s/^\s+|\s+$//g;
                chomp $line;
                @array=split(/\s+/,$line);
                $force=sqrt($array[2]*$array[2]+$array[3]*$array[3]+$array[4]*$array[4]);
                @force_atom=();
                push (@force_atom,$array[1],$array[2],$array[3],$array[4],$force);
                push @force_molecule,[@force_atom];
            }
            push @force_replicas,[@force_molecule];
        }
    return [@force_replicas];
}

#Read summary at the end of one NEB cycle.
sub Read_Summary{
    #Find summary information.
    my ($step_num,$max_force);
    #Just a initial value of max_force for STEP 0.
    #Well,I'm lazy.
    $max_force=0.0;
    #Read until empty line or a line with ********
    while (1) {
        if ($line=~/^\s+$/ || $line=~/\*{10}/) {
            last;
        }else {
            $line=<IN>;
            $line_num++;
        }
    }
    #Read a line which is NOT empty.
    $line=<IN>;
    $line_num++;
    
    while (1) {
        #Last with empty line.
        if ($line=~/^\s+$/) {
            last;
        }elsif ($line=~/STEP NUMBER\s+=\s+(\d+)\s+$/) {
            $step_num=$1;
            if (DEBUG) {
                print "Find STEP NUMBER in line $line_num: $line\n";
            }
        }elsif ($line=~/MAX FORCE\s+=\s+(\d+\.\d+)\s+/) {
            $max_force=$1;
            if (DEBUG) {
                print "Find MAX FORCE in line $line_num: $line\n";
            }
        }
        $line=<IN>;
        $line_num++;
    }
    return($step_num,$max_force);
}

#Print the summary information.
#Read information from $step_num,$max_force and @force_replicas.
sub Print_Force{
    my ($force_replicas,$step_num,$max_force)=@_;
    my @max_force_replicas;
    my ($i,$j,$k);
    my $tmp_max=0;
    my $tmp_serial=0;
    my $tmp_name=();
    for my $force_molecule(@{$force_replicas}){
        $i++;
        for my $force_atom (@$force_molecule ) {
            $j++;
            if ($j==1) {
                print "Replica $i: Energy $force_atom\n";
            }else {
                if ($tmp_max<${$force_atom}[4] ) {
                    $tmp_max=${$force_atom}[4];
                    $tmp_serial=$j;
                    $tmp_name=${$force_atom}[0];
                }
                if (${$force_atom}[4]>MAX_FORCE) {
                    printf ("%d\t%s\t% 6.4f:\t% 6.4f\t% 6.4f\t% 6.4f\n",$j,${$force_atom}[0],${$force_atom}[4],${$force_atom}[1],${$force_atom}[2],${$force_atom}[3]);
                }
            }
        }
        printf ("MAX FORCE %.4f: in atom %d %s\n",$tmp_max,$tmp_serial,$tmp_name);
        $j=0;
        $tmp_max=0;
    }
    printf ("****************Step Num: %d. MAX FORCE % 6.4f************\n\n",$step_num,$max_force);
}
