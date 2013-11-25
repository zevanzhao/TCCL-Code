#!/usr/bin/perl
#This script will convert the Gaussian 03 out file into an xyz file.
#usage: g03log2xyz.pl g03.log >g03.xyz
use strict;
use constant DEBUG=>0;
my $line;
my $energy=0;
my @array;
my @point3D;
my @molecule=();
my @prevmol;#Previous molecule.
my @atoms=qw(
X H He Li Be B C N O F Ne Na Mg Al Si P S Cl Ar K Ca Sc Ti V Cr Mn Fe Co Ni Cu Zn Ga Ge As Se Br Kr Rb Sr Y Zr Nb Mo Tc Ru Rh Pd Ag Cd In Sn Sb Te I Xe Cs Ba La Ce Pr Nd Pm Sm Eu Gd Tb Dy Ho Er Tm Yb Lu Hf Ta W Re Os Ir Pt Au Hg Tl Pb Bi Po At Rn Fr Ra Ac Th Pa U Np Pu Am Cm Bk Cf Es Fm Md No Lr Rf Db Sg Bh Hs Mt Ds Rg Uub Uut Uuq Uup Uuh Uus Uuo 
);

open (IN,"<",$ARGV[0])|| die "Open file failed:$!";
do{
    $line=<IN>;
    if($line=~m/SCF Done.*\s+=\s+(.*)\s+A\.U\..*/){
        $energy=$1;
    }elsif ($line=~m/Input orientation/) {
        &GetCoord();
    }elsif ($line=~m/Optimized Parameters/) {
        &GetCoord();
    }
}while(!eof(IN));
&PrintMol();

sub GetCoord{
    #Try to get the last normal Coordinates. Sometime it fails to read the coordinates and return NaN etc. that is not what I needed.
    @prevmol=@molecule;
    @molecule=();
    while($line!~m/Coordinates/){
        if (eof(IN)) {
            exit();
        }
        $line=<IN>;
    }
    $line=<IN>;
    $line=<IN>;
    $line=<IN>;
    while($line!~m/--------------/){
        chomp $line;
        $line=~s/^\s+|\s*$//g;
        push @point3D,split(/\s+/,$line);
        if ($point3D[3]=~m/[+\-]?\d+\.?\d+/) {
            push @molecule, [$point3D[1],$point3D[3],$point3D[4],$point3D[5]];            
        }else {
            @molecule = @prevmol;
            last;
        }
        @point3D=();
        $line=<IN>;
    }
    if (DEBUG) {
        &PrintMol();
    }
}


sub PrintMol{
    print $#molecule+1,"\n";
    print "$energy\n";
    for my $point (@molecule){
        #    print "$_->[0] $_->[1] $_->[2] $_->[3]\n";
        print "$atoms[$point->[0]]  $point->[1] $point->[2] $point->[3]\n";
    }
    
}
close IN;
