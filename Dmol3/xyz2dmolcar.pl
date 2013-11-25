#!/usr/bin/perl -w
#This script will convert the xyz file to Dmol3 input *.car file format.
#If you want to know the .car format of dmol3, please read MS 4.4 help files.
#Time-stamp: <Last updated: zevan zevan.zhao@gmail.com 2010-04-07 16:45:10>
use strict;
my $line;
my @molecule;
my $DEBUG=0; #Just add a line for debugging.
my %atom_order=();
my @atoms=qw(
X H He Li Be B C N O F Ne Na Mg Al Si P S Cl Ar K Ca Sc Ti V Cr Mn Fe Co Ni Cu Zn Ga Ge As Se Br Kr Rb Sr Y Zr Nb Mo Tc Ru Rh Pd Ag Cd In Sn Sb Te I Xe Cs Ba La Ce Pr Nd Pm Sm Eu Gd Tb Dy Ho Er Tm Yb Lu Hf Ta W Re Os Ir Pt Au Hg Tl Pb Bi Po At Rn Fr Ra Ac Th Pa U Np Pu Am Cm Bk Cf Es Fm Md No Lr Rf Db Sg Bh Hs Mt Ds Rg Uub Uut Uuq Uup Uuh Uus Uuo );
my ($name,$x,$y,$z,$type_residue,$residue_sequence,$potential_type,$element_symbol,$partial_charge);
$type_residue="XXXX";
$residue_sequence="1";
$potential_type="xx";
$partial_charge="0.0000";
#Here is the DMOLCAR format.This format is really strict. 
#Well, actually, it is stupid.
format DMOLCAR=
@<<<< @>>>>>>>>>>>>> @>>>>>>>>>>>>> @>>>>>>>>>>>>> @||| @<<<<<<@<<<<<< @< @>>>>>
$name,$x,$y,$z,$type_residue,$residue_sequence,$potential_type,$element_symbol,$partial_charge
.
    open (IN,"<","$ARGV[0]")|| die "Open file $ARGV[0] failed:$!";
ALL:while($line=<IN>){
	$line=~s/^\s+|\s+$//g;
    if($line=~m/\w+(\s+[+\-]?\d+\.?\d+){3}/){
	push @molecule, [split(/\s+/,$line)];
    }
}
$~='DMOLCAR';
foreach my $point3D(@molecule){
    $atom_order{@$point3D[0]}++;
    if(@$point3D[0]=~m/\d+/){ 
      $element_symbol=@atoms[@$point3D[0]];
    }
    else{
      $element_symbol=@$point3D[0];
    }
    $name=$element_symbol.$atom_order{@$point3D[0]};
    $x=@$point3D[1];
    $y=@$point3D[2];
    $z=@$point3D[3];
    #print the coordinates according to the DMOL .car file format.
#    printf ("%2s%d     %12.9f   %12.9f   %12.9f XXXX 1      xx      %2s   0.000\n",@$point3D[0],$atom_order{@$point3D[0]},(@$point3D)[1..3],@$point3D[0]);
    write;
}
