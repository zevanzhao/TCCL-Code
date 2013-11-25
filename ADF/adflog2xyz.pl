#!/usr/bin/perl
#This script will convert the ADF optimization log file into an xyz file.
#Now the output is a real xyz file.
#Time-stamp: <Last updated: zevan zevan.zhao@gmail.com 2010-12-04 23:03:20>
#Usage: adflog2xyz.pl ADF.log 
use strict;
my $line;
my $DEBUG=0;
my $energy_eV;
my $energy_au;
my @array;
my @point3D;
my @molecule;
my %map=();
#Periodical table
%map=('H',1,'He',2,'Li',3,'Be',4,'B',5,'C',6,'N',7,'O',8,'F',9,'Ne',10,'Na',11,'Mg',12,'Al',13,'Si',14,'P',15,'S',16,'Cl',17,'Ar',18,'K',19,'Ca',20,'Sc',21,'Ti',22,'V',23,'Cr',24,'Mn',25,'Fe',26,'Co',27,'Ni',28,'Cu',29,'Zn',30,'Ga',31,'Ge',32,'As',33,'Se',34,'Br',35,'Kr',36,'Rb',37,'Sr',38,'Y',39,'Zr',40,'Nb',41,'Mo',42,'Tc',43,'Ru',44,'Rh',45,'Pd',46,'Ag',47,'Cd',48,'In',49,'Sn',50,'Sb',51,'Te',52,'I',53,'Xe',54,'Cs',55,'Ba',56,'La',57,'Ce',58,'Pr',59,'Nd',60,'Pm',61,'Sm',62,'Eu',63,'Gd',64,'Tb',65,'Dy',66,'Ho',67,'Er',68,'Tm',69,'Yb',70,'Lu',71,'Hf',72,'Ta',73,'W',74,'Re',75,'Os',76,'Ir',77,'Pt',78,'Au',79,'Hg',80,'Tl',81,'Pb',82,'Bi',83,'Po',84,'At',85,'Rn',86,'Fr',87,'Ra',88,'Ac',89,'Th',90,'Pa',91,'U',92,'Np',93,'Pu',94,'Am',95,'Cm',96,'Bk',97,'Cf',98,'Es',99,'Fm',100,'Md',101,'No',102,'Lr',103,'Rf',104,'Db',105,'Sg',106,'Bh',107,'Hs',108,'Mt',109,'Ds',110,'Rg',111,'Uub',112,'Uut',113,'Uuq',114,'Uup',115,'Uuh',116,'Uus',117,'Uuo',118);

#Some useless tricks.
#if ( -e "./@ARGV[0]"){
#    open (IN,"<","./@ARGV[0]");
#}elsif( -e "@ARGV[0]"){
#    open (IN,"<","@ARGV[0]");
#}else{
#    die "Open file @ARGV[0] failed:$!";
#}
open (IN,"<","@ARGV[0]")|| die "Open file @ARGV[0] failed:$!";
 ALL:    while($line=<IN>){
     last ALL if(eof(IN));
     #Read non-optimized and optimized geometry structure.
     if ($line=~m/^\s*<\w+\d+-\d+>\s+<\d+:\d+:\d+>\s+Geometry Converged/i||$line=~m/Coordinates in Geometry Cycle/i){
	 if($DEBUG){
	     print $line;
	 }
	 @molecule=();
	 #Read the geometry.
       GEO: while($line=<IN>){
	   last GEO if($line=~m/CORORT/i); 
	   last ALL if(eof(IN));
	   if($line=~m/^\s+\d+\.\w+\s+[+\-]?\d+\.?\d+.*$/){
		 #My god! What is this?Give me an example:
		 #eg:  1.Au        6.415234    5.672952    7.115024
		 chomp $line;
		 $line=~s/^\s+\d+\.|\s+$//g;
		 push @point3D,split(/\s+/,$line); 
		 push @molecule, [@point3D];
		 @point3D=();
	     }
	}
	 
	 do{
	     $line=<IN>;
	     last ALL if(eof(IN));
	 }while(($line!~m/\d+\.?\d*\s+a\.u\.\s+$/i)&&($line!~m/current energy/i)&&($line!~m/E-test:\s+old,new=\s+([+\-]?\d+\.?\d*),\s+([+\-]?\d+\.?\d*)\s+hartree/i));
	 #Previous line is modified for ADF2007.01.
	 #The output of ADF2008 and ADF2007 is a little different.
	 
	 #Read the energy
	 if($DEBUG){
	     print $line;
	 }
	 do{
	     if($line=~m/\d+\.?\d*\s+a\.u\.\s+$/){
		 #This line looks like:Bond Energy LDA      -1.50127382 a.u.
		 #Or look like:+ GGA-XC      -3.94898196 a.u.
		 $line=~/\s+([+\-]?\d+\.?\d*)\s+a\.u\.\s+$/;
		 $energy_au=$1;
	     } 
	     elsif($line=~m/\d+\.?\d*\s+eV\s+$/){
		 #This line looks like:Bond Energy LDA     -40.85173909 eV
		 $line=~/\s+([+\-]?\d+\.?\d*)\s+eV\s+$/;
		 $energy_eV=$1;
	     }
	     elsif($line=~m/current energy \s+[+\-]?\d+\.?\d*\s*hartree/i){
		 #This line looks like:current energy  -1.50135970 Hartree
		 $line=~/current energy\s+([+\-]?\d+\.?\d*)\s*hartree/i;
		 $energy_au=$1;
	     }
	     elsif($line=~m/E-testE-test.*old.* new.*([+\-]?\d+\.?\d*)\s*hartree/i){
		 $energy_au=$1;
	     }
	     $line=<IN>;
	     last ALL if(eof(IN));
	 }while(($line!~m/NORMAL\s+TERMINATION/i)&&($line!~m/gradient\s+max/i)&&($line!~m/max gradient/i));
	 #Previous line was modified for adf2007.01.
     }
     
}
close IN;
#if you want real xyz file, uncomment the following line.
print $#molecule+1,"\n";
#use a.u. or eV? It's up to you.
print "$energy_au\n";
#print "$energy_eV\n";
foreach(@molecule)
{
   # print "$map{$_->[0]} $_->[1] $_->[2] $_->[3]\n";
    #if you want to use Atomic Symbols, uncomment the following line, and comment previous line.
    print "$_->[0] $_->[1] $_->[2] $_->[3]\n";
}
