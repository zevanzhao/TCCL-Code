#!/usr/bin/perl 
#eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}' && eval 'exec perl -S $0 $argv:q' if 0;
#;-*- Perl -*-
#Time-stamp: <Last updated: Zhao,Yafan zhaoyafan@mail.thu.edu.cn 2013-11-25 17:13:42>
#Version=1.1
#This script was written to print orbital information in the molpro output files in a human-readable way.
#Usage: Orbprint++_1.0  YOUR_MOLPRO_OUTFILE.out
#This work is for Wang Yi-Lei, Hu Han-Shi and other molpro users in TCCL@THU.
#The original version was written in bash-script and C, which is really a disgusting work.
#Another version was written in Fortran by Wang Yi-Lei, which is actually dying now.
#This is the third version and was written in Perl, mainly by Zhao Ya-Fan and Wang Yi-Lei.
#Update:
#1.A little more function was added for PSEUDO CANONICAL ORBITALS on Nov.13, 2009 for Su Jing.
#2.Added support for Cartesian Basis on Nov. 24, 2010 for Wang Yi-Lei. Change version to 1.1

#use warnings; #commented to ignore some harmless warnings.
use strict;
#Feature in 5.10
#use feature "switch";
use Switch;
use constant DEBUG=>1;
my $line;#data will be read from the Molpro output file to this variable.
my $linetype;#type of this line.
my $prevline;#record the data of previous line. To deal with some uncomfortable situation.
my $prevlinetype;#type of pervious line.
my ($i,$j);
my $section; #record sections of the orbitals,suppose to be integer.
my $orbtype; #Closed shell,Open shell,natural spin orbitals or natual charge orbitals.
my $head;#beginning of the data block
my $block;#type of the block. In fact $HEAD and $BLOCK described the same thing.
#my $prevline;#record the property of line. EMPTY for empty line,BASIS for basis and COEFF for coeffs.
my @names;
my @basis;#Names of the atomic basis. This is a temperary variable.
my @coeffs;#Coeffs of the atomic basis. Also a temperary variable 
my @orb;#Combination of the previous 2
my $spin;#spin of the orbital;1 for negtive, -1 for positive and 0 for closedshell.(What did I do? This definition is BAD! 2010-11-24)
my @orbitals;#An array which contains all the small orbs.
my @sortedorbs;#ORBITALS sorted by energy.
my $threshold=0.2; #Threshold of print an coeff 
my %basis_id=();# give a ID number for every atomic orbital

#Load the output file.
if(@ARGV!=1){
    die "Usage: OrbPrint++  [outfile]\n";
}
open (IN,"<",$ARGV[0])|| die "Open file failed:$!";
open (OUT,">","Sorted_$ARGV[0]");

while($line=<IN>){
    $spin=1;
    &FindHead;
    if($block ne ""){
        %basis_id=();
        &FindOrb;
        &ReadBlock;
        &SortOrbs;
        $section++;
        if(@sortedorbs){
            if($block eq "OPEN"){
                &PrintOpenOrbs;
            }
            else{
                &PrintOrbs;
            }
            print OUT "\*" x 20,"END OF SECTION $section","\*"x20,"\n";
        }
    }
}
close OUT;
close IN;

#*****************
#FUNCTION SECTION#
#*****************

#Get the head of the data block
#one parameter,a line of data.
#sub CheckHead($line)
sub CheckHead{
    my $a;
    my $line=$_[0];
  switch($line){
      case m/ELECTRON ORBITALS FOR POSITIVE SPIN/ {  $a="OPEN"; }
      case m/ELECTRON ORBITALS/{ $a="CLOSED" ;}
      case m/NATURAL SPIN ORBITALS/{$a="NSO";  }
      case m/NATURAL CHARGE ORBITALS/{ $a="NCO";}
      case m/NATURAL ORBITALS/{$a="NATURAL";}
      case m/PSEUDO CANONICAL ORBITALS/{$a="PSEUDO_CANONICAL";}
       else {$a="";}
  }
    $a;
}

#using the Check_Head function to locate the position of the head of data block
sub FindHead{
    my $a;
  BLOCK:{
       my $a=&CheckHead($prevline);
       if($a ne ""){
           $block=$a;
           $head=$prevline;
           print "Get the head of block $block in this line:$prevline\n";
           last BLOCK;
       }
      block:while($line=<IN>){
           $a=&CheckHead($line);
           if($a ne ""){
               $block=$a;
               $head=$line;
               print "Get the head of block $block in this line:$line\n";
               last block;
           }
       }    
   }
}
#Check if the line is  the end of the block.
sub CheckBlockEnd{
    my $thisline=$_[0];
    $_=$thisline;
    my $a;
    if(m/ELECTRON ORBITALS FOR NEGATIVE SPIN/){
        print "This is a line for negative spin :$line\n";
        $a="HALF";
    }    
    elsif((CheckHead($_) ne "") ||( m/[a-zA-Z]{4,}/)||( m/\*{11,}/ )){
        #What hell is that?
        #In most situation, the block end with "************" or some other words.
        print "This is the end of the block:$line\n";
        $a="END";
    }
    else{
        $a="NOTEND";
    }
    $a;
}

#find the line containing "Orb "
sub FindOrb{
  ORB:{
      do{
          $_=$line;
          if(m/^\s*Orb\s*Occ/){
              s/^\s+|\s*$//g;
              if (DEBUG) {
                  print "Get the line with Orb: $line\n";
              }
              @names=split(/\ +/);
              #print @names;
              last ORB;
          }
      }while($line=<IN>);
  }
}

#print ordinary orb for NBO or open shell orbs
sub PrintOrbs{
    print OUT "$head\n";
    for($i=0;$i<@sortedorbs;$i++){
	    printf OUT "Sec.%d\tNo.%d\t  ",$section,$i+1;
	    print OUT "$sortedorbs[$i][1][0]\t";
      for($j=1;$j<@names-1;$j++){
          print OUT "$names[$j]  $sortedorbs[$i][1][$j]      ";
      }
      print OUT "\n";
      for($j=@names-1;$j<=$#{$sortedorbs[$i][1]};$j++){
          if(abs($sortedorbs[$i][1][$j])>$threshold){
              printf OUT "    %s\t%10.2f\n",$sortedorbs[$i][0][$j+1-@names],$sortedorbs[$i][1][$j];
          }
      }
  }
}

#print orbitals for open shell orbitals
sub PrintOpenOrbs{
    print OUT "$head\n";
    #Print Positive Spins
    for($i=0;$i<@sortedorbs;$i++){
        if($sortedorbs[$i][2][0] ne "-1"){
            printf OUT "Sec.%d\tNo.%d\t  ",$section,$i+1;
            print OUT "$sortedorbs[$i][1][0]\t";
            for($j=1;$j<@names-1;$j++){
                print OUT "$names[$j]  $sortedorbs[$i][1][$j]      ";
            }
            print OUT "\n";
            for($j=@names-1;$j<=$#{$sortedorbs[$i][1]};$j++){
                if(abs($sortedorbs[$i][1][$j])>$threshold){
                    printf OUT "    %s\t%10.2f\n",$sortedorbs[$i][0][$j+1-@names],$sortedorbs[$i][1][$j];
                } 
            }
        }
    }
    print OUT "\nELECTRON OBITALS FOR NEGTIVE SPIN\n";
    #Print Negtive Spins
    for($i=0;$i<@sortedorbs;$i++){
        if($sortedorbs[$i][2][0] eq "-1"){
            printf OUT "Sec.%d\tNo.%d\t  ",$section,$i+1;
            print OUT "$sortedorbs[$i][1][0]\t";
            for($j=1;$j<@names-1;$j++){
                print OUT "$names[$j]  $sortedorbs[$i][1][$j]      ";
            }
            print OUT "\n";
            for($j=@names-1;$j<=@${$sortedorbs[$i][1]};$j++){
                if(abs($sortedorbs[$i][1][$j])>$threshold){
                    printf OUT "    %s\t%10.2f\n",$sortedorbs[$i][0][$j+1-@names],$sortedorbs[$i][1][$j];
                }
            }
        }
    }
}

#sort the orbs by energy
sub SortOrbs{
    @sortedorbs=();
    @sortedorbs= sort {$a->[1][2] <=> $b->[1][2] }@orbitals;
}
#Determine the property of a single line in the data block
#one parameter, a single line
#sub CheckLineType($line)
sub CheckLineType{
    my $linetype;
    switch ($_[0]){
        case m/[0-9]\ [0-9][a-z]/ {#match the line with basis
            #Example:
            #1 1s      1 1s      1 1s      1 1s      1 1s      1 2px     1 2pz     1 2px     1 2pz     1 2px  
            $linetype="BASIS";
        }
         case m /[0-9]\ [a-z]{1,3}\ /{
             #Added for cartesian. Example:
             #1 s       1 s       1 s       1 z       1 z       1 z       1 z       1 z       1 xx      1 yy
             $linetype="BASIS";
         }
          case m/\d\.\d{3,}/{ #match the line with coeffs
              #Example:
              #1.1   2    -3.3547  -33.1932  0.174953 -0.022800 -0.418763 -0.022785 -0.012411  0.001137 -0.027488  0.023771  0.461578  0.461578
              $linetype="COEFFS";
          }
           case m/^\s*$/{#This is an empty line
               $linetype="EMPTY";
           }
            $linetype="";
    };
    $linetype;
}


#Just read a line from the data block.
#sub ReadLine($line,$pervlinetype)
sub ReadLine{
    &InitReadLine($_[0],$_[1]);
    &ProcLine($_[0],$linetype,$_[1]);
    &EndReadLine($linetype,$_[1]);
}
#3 parameters: the data of this line and property of previous line
#sub ProcLine($line,$linetype,$pervlinetype)
sub ProcLine{
    $_=$_[0];
    my $type=$_[1];
    my $prevtype=$_[2];
    switch ($type){
        case "BASIS" {#match the line with basis
            s/^\s+|\s*$//g;#remove blanks in the beginning and end of the line
            s/([0-9])\ ([0-9]?[a-z]{1,3})/$1\.$2/g; 
            push (@basis,split(/\ +/)); 
        }
         case "COEFFS"{ #match the line with coeffs
             s/\*{5,}/\ 100000\ /;#translate the annoying ******** inside the coeffs into large number.
             s/^\s+|\s*$//g;
             push (@coeffs,split(/\ +/)); 
         }
          case "EMPTY"{
              if("$prevtype" eq "BASIS"){
                  #I wonder if there is something wrong here?
                  foreach  (@basis) {
                      #Use a hash to count numbers.
                      $basis_id{$_}++;
                      $_="$basis_id{$_}"." $_";
                  }
              }
              elsif("$prevtype" eq "COEFFS"){
                  @orb=([@basis],[@coeffs],[$spin]);
                  push (@orbitals,[@orb]);
              }
          }
      }	
}
#Initial the @basis, @coeffs, or @orb variables for reading a single line.
#2 parameters needed, the type of previous line and the type of this line.
#sub InitReadLine($line,$prevlinetype)
sub InitReadLine{
    my $preline=$_[1];
    my $thistype=&CheckLineType($_[0]);
    if($thistype eq "BASIS" && $preline eq "EMPTY"){
	@basis=();	
    }    
    $linetype=$thistype;
}

#Things to do after read in a single line.
#2 parameters needed, the type of previous line and the type of this line.
#sub EndReadLine($linetype,$prevlinetype)
sub EndReadLine{
    my $thisline=$_[0];
    my $prevtype=$_[1];
    if($thisline eq "EMPTY" && $prevtype eq "COEFFS"){
        @coeffs=();
    }
    $prevlinetype=$_[0];
}

#read data block.
#This function is based on previous functions.
sub ReadBlock{
    @orbitals=();
   BLOCK:while($line= <IN>){
        chomp $line;
        switch(&CheckBlockEnd($line)){
            case "HALF"{ #ELCTRON ORBITALS FOR NEGTIVE SPINS.
                $spin = "-1";
                for(1..4){
                    $line=<IN>;		  
                }
            }
             case "NOTEND"{
                 &ReadLine($line,$prevlinetype);
             }
              case "END"{
                  last BLOCK;
              }
          }
    }
    $prevline=$line;
    $prevlinetype=$linetype;
}

