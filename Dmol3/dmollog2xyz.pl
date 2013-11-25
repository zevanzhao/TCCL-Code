#!/usr/bin/perl
#This script will convert the Dmol3 out file into an xyz file.
#Time-stamp: <Last updated: zevan zevan.zhao@gmail.com 2012-11-11 23:28:42>
use strict;
my $line;
my $energy_au;
my @array;
my @point3D;
my @molecule;
my %map=();
my $DEBUG=0; #Just add a line for debugging.
#Periodical table
%map=('H',1,'He',2,'Li',3,'Be',4,'B',5,'C',6,'N',7,'O',8,'F',9,'Ne',10,'Na',11,'Mg',12,'Al',13,'Si',14,'P',15,'S',16,'Cl',17,'Ar',18,'K',19,'Ca',20,'Sc',21,'Ti',22,'V',23,'Cr',24,'Mn',25,'Fe',26,'Co',27,'Ni',28,'Cu',29,'Zn',30,'Ga',31,'Ge',32,'As',33,'Se',34,'Br',35,'Kr',36,'Rb',37,'Sr',38,'Y',39,'Zr',40,'Nb',41,'Mo',42,'Tc',43,'Ru',44,'Rh',45,'Pd',46,'Ag',47,'Cd',48,'In',49,'Sn',50,'Sb',51,'Te',52,'I',53,'Xe',54,'Cs',55,'Ba',56,'La',57,'Ce',58,'Pr',59,'Nd',60,'Pm',61,'Sm',62,'Eu',63,'Gd',64,'Tb',65,'Dy',66,'Ho',67,'Er',68,'Tm',69,'Yb',70,'Lu',71,'Hf',72,'Ta',73,'W',74,'Re',75,'Os',76,'Ir',77,'Pt',78,'Au',79,'Hg',80,'Tl',81,'Pb',82,'Bi',83,'Po',84,'At',85,'Rn',86,'Fr',87,'Ra',88,'Ac',89,'Th',90,'Pa',91,'U',92,'Np',93,'Pu',94,'Am',95,'Cm',96,'Bk',97,'Cf',98,'Es',99,'Fm',100,'Md',101,'No',102,'Lr',103,'Rf',104,'Db',105,'Sg',106,'Bh',107,'Hs',108,'Mt',109,'Ds',110,'Rg',111,'Uub',112,'Uut',113,'Uuq',114,'Uup',115,'Uuh',116,'Uus',117,'Uuo',118);

open (IN,"<","@ARGV[0]")|| die "Open file @ARGV[0] failed:$!";
 ALL:    while($line=<IN>){
     last ALL if($line=~m/Entering Properties Section/i);
     last ALL if(eof(IN));
     #Read non-optimized and optimized geometry structure.
     if ($line=~m/Input Coordinates/i){#Just find the beginning of the coordinates part
	 @molecule=();
	 #Read the geometry.
	 if($DEBUG){
	     print "$line\n";
	 }
	 $line=<IN>;# read in a line of "--------------------"
       GEOMETRY: while($line=<IN>){
	   last GEOMETRY if($line=~m/----------/); #The end of the coordinates part.
	   last ALL if(eof(IN));#This line is almost useless. Just put it here for code safety.
	   if($DEBUG){
	       print "$line\n";
	   }
	   if($line=~m/^\s+\d+\s+\w+\s+[-]?\d+\.?\d+/){
	       #an example:   
	       #  1  Cd     0.000000   0.000000   0.899237
	       if($DEBUG){
		   print "$line\n";
	       }
	       chomp $line;
	       $line=~s/^\s+|\s+$//g;#Remove the blank before and after the data line.
	       push @point3D,split(/\s+/,$line); 
	       push @molecule, [@point3D];
	       @point3D=();
	   }
       }
	 
	 #Read the energy
       ENERGY: while($line=<IN>){
	   if($line=~m/opt==\s+\d+\s+([+\-]?\d+\.?\d+)\s+/){
	       #This line looks like:Bond Energy LDA      -1.50127382 a.u.
	       #opt==    3     -3064.5834176  -0.0411352  0.042091   0.421361  
	       if($DEBUG){
		   print "$line\n";
	       }
	       $energy_au=$1;
	       last ENERGY;
	   } 
	   last ALL if(eof(IN));
       }
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
    #print "$map{$_->[1]} $_->[2] $_->[3] $_->[4]\n";
    #if you want to use Atomic Symbols, uncomment the following line, and comment previous line.
    print "$_->[1] $_->[2] $_->[3] $_->[4]\n";
}
