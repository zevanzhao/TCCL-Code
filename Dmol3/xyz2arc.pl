#!/usr/bin/perl -w
#This script will convert the xyz movie file to .arc file format, which is the same to the dmol .car format.
#The script is based on an old script xyz2dmolcar.pl by zevan.zhao@gmail.com.
#If you want to know the .car format of dmol3, please read Material Studio 4.4 help files. It's *very* strict.
#Time-stamp: <zhao240 02/25/2011 00:36:21>
use strict;
use Math::Trig;
#use diagnostics;
use constant DEBUG=>0;
my $line;
my (@molecule,@movie,$num_atoms);
my $mole_order=0;
my %atom_order;
my ($IS_PBC,$PBC_File,@PBC_Info);#Check the periodic Boundary Condition.
my @atoms=qw(X H He Li Be B C N O F Ne Na Mg Al Si P S Cl Ar K Ca Sc Ti V Cr Mn Fe Co Ni Cu Zn Ga Ge As Se Br Kr Rb Sr Y Zr Nb Mo Tc Ru Rh Pd Ag Cd In Sn Sb Te I Xe Cs Ba La Ce Pr Nd Pm Sm Eu Gd Tb Dy Ho Er Tm Yb Lu Hf Ta W Re Os Ir Pt Au Hg Tl Pb Bi Po At Rn Fr Ra Ac Th Pa U Np Pu Am Cm Bk Cf Es Fm Md No Lr Rf Db Sg Bh Hs Mt Ds Rg Uub Uut Uuq Uup Uuh Uus Uuo );
my ($name,$x,$y,$z,$type_residue,$residue_sequence,$potential_type,$element_symbol,$partial_charge);
$type_residue="XXXX";
$residue_sequence="1";
$potential_type="xx";
$partial_charge="0.0000";
#Here is the DMOLCAR format.This format is really strict. 
#Well, actually, it is stupid.
if((@ARGV != 2)||($ARGV[0] eq "-h")||($ARGV[0] eq "--help")){
    &usage();
    exit();
}
open (IN,"<","$ARGV[0]")|| die "Open file $ARGV[0] failed:$!";
open (ARC,">","$ARGV[1]") || die "Open file $ARGV[1] failed:$!";
sub usage(){
    print "This script will convert movie file in .xyz format to .arc format.\n";
    print "POSCAR or CONTCAR will be read to obtain PBC information.\n";
    print "Usage: $0 input.xyz out.arc\n";
}
#using printf() function will also works. I just failed to know this function well when I wrote this scrips before.
#Don't use the following lines! This will introduce bugs! Use printf() would be better. 
format ARC=
@<<<< @>>>>>>>>>>>>> @>>>>>>>>>>>>> @>>>>>>>>>>>>> @||| @<<<<<<@<<<<<< @< @>>>>>
$name,$x,$y,$z,$type_residue,$residue_sequence,$potential_type,$element_symbol,$partial_charge
.

if( -e "POSCAR") {
print "POSCAR found. PBC will be on.\n";
$PBC_File="POSCAR";
$IS_PBC=1;
}elsif(-e "CONTCAR"){
print "CONTCAR found. PBC will be on.\n";
$PBC_File="CONTCAR";
$IS_PBC=1;
}else{
print "No POSCAR or CONTCAR file was found. PBC will be off.\n";
$IS_PBC=0;
}
if($IS_PBC){
my $PBC_ref=&Read_PBC_File($PBC_File);
@PBC_Info=@$PBC_ref;
}

#Read the PBC_File,i.e. POSCAR or CONTCAR, line 2-5.
sub Read_PBC_File(){
    my $File=shift;
    my ($scale,@vectors,$a,$b,$c,$alpha,$beta,$gamma);
    my @info=();
    open (PBC, "<", $File)||die "Open $PBC_File failed:$!";
    my $pos=<PBC>;#Read the first line.
    $pos=<PBC>;#Read the scale vector line.
    if($pos=~m/^\s*(\d+\.?\d*)\s*$/){
	$scale=$1;
    }else{
	die "Error reading file $PBC_File line 2. Not a good POSCAR or CONTCAR?\n";	
    }
    for my $num(1..3){
	chomp($pos=<PBC>);
	$pos=~s/^\s+|\s+$//g;
	if($pos=~m/^([+\-]?\d+\.?\d+\s+){2}([+\-]?\d+\.?\d+)$/){
	    push @vectors,[split (/\s+/,$pos)];
	}else{
	    my $linenum=$num+2;
	    die "Error reading file $PBC_File line $linenum.Not a good POSCAR or CONTCAR?\n";
	}
    }
    close(PBC);
    $a=sqrt(VectorMultiply($vectors[0],$vectors[0]));
    $b=sqrt(VectorMultiply($vectors[1],$vectors[1]));
    $c=sqrt(VectorMultiply($vectors[2],$vectors[2]));
    $alpha=rad2deg(acos(VectorMultiply($vectors[1],$vectors[2])/($b*$c)));
    $beta=rad2deg(acos(VectorMultiply($vectors[2],$vectors[0])/($c*$a)));
    $gamma=rad2deg(acos(VectorMultiply($vectors[0],$vectors[1])/($a*$b)));
    $a*=$scale;
    $b*=$scale;
    $c*=$scale;
    push (@info,$a,$b,$c,$alpha,$beta,$gamma);
# Always return a ref than an array.
    return \@info;
}

#Vector multiply of any two 3-dimensional vectors
sub VectorMultiply(){
    my ($a,$b)=@_;
    my $sum=0;
    for (my $i=0;$i<3;$i++){
	$sum+=$a->[$i]*$b->[$i];
    }
    return($sum);
}

ALL:while($line=<IN>){
     $line=~s/^\s+|\s+$//g;
     if($line=~/^(\d+)$/){
	 if($mole_order > 0){
	     if($num_atoms != @molecule){
		 my $i=scalar @molecule;
		 print "Warning: Number of atoms is $i, which should be $num_atoms.\n";
	     }
	     push @movie,[@molecule];
	     @molecule=();
	 }
	 $mole_order++;
printf ("Reading structure %d.\n",$mole_order);
	 $num_atoms=$1;
#Just read the next line.
	 $line=<IN>;
	}
     elsif($line=~m/\w+(\s+[+\-]?\d+\.?\d+)/){
	 if(DEBUG){
	     print "Reading line: $line\n";
	 }
	 push @molecule, [split(/\s+/,$line)];
     }
}
close(IN);
#Push the last molecule.
push @movie,[@molecule];
print "Now converting...\n";
$~='ARC';
select ARC;
print ARC "!BIOSYM archive 3\n";
if($IS_PBC){
print ARC "PBC=on\n";
}else{
print ARC "PBC=off\n"
};
for my $mole(@movie){
    #The following line need to be changed in the future!
    print ARC "                                                                          0.0000\n";
    print ARC "!DATE     May 19 11:14:26 2010\n";
    if($IS_PBC){
	printf ("PBC%10.4f%10.4f%10.4f%10.4f%10.4f%10.4f\n",@PBC_Info);
#eg:     
#PBC   11.1626    8.4069   21.4410   90.0000   90.0000   90.0000
    }

%atom_order=();
    for my $point3D(@$mole){
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
#	write();
	printf ARC "%-5s %14.9f %14.9f %14.9f XXXX 1      xx      %2s   0.000\n",$name,$x,$y,$z,$element_symbol;
    }
    print ARC "end\nend\n"; 
}
print STDOUT "Done!\n";
