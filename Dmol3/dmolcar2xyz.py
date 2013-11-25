#!/usr/bin/env python
#This script is written to replace the dmolcar2xyz.pl script, adding a sesorting function.
#The atoms will be sort by the type of atoms and the XYZ coordinates.
import sys, re, os.path
PeriodicTable={'H':1,'He':2,'Li':3,'Be':4,'B':5,'C':6,'N':7,'O':8,'F':9,'Ne':10,'Na':11,'Mg':12,'Al':13,'Si':14,'P':15,'S':16,'Cl':17,'Ar':18,'K':19,'Ca':20,'Sc':21,'Ti':22,'V':23,'Cr':24,'Mn':25,'Fe':26,'Co':27,'Ni':28,'Cu':29,'Zn':30,'Ga':31,'Ge':32,'As':33,'Se':34,'Br':35,'Kr':36,'Rb':37,'Sr':38,'Y':39,'Zr':40,'Nb':41,'Mo':42,'Tc':43,'Ru':44,'Rh':45,'Pd':46,'Ag':47,'Cd':48,'In':49,'Sn':50,'Sb':51,'Te':52,'I':53,'Xe':54,'Cs':55,'Ba':56,'La':57,'Ce':58,'Pr':59,'Nd':60,'Pm':61,'Sm':62,'Eu':63,'Gd':64,'Tb':65,'Dy':66,'Ho':67,'Er':68,'Tm':69,'Yb':70,'Lu':71,'Hf':72,'Ta':73,'W':74,'Re':75,'Os':76,'Ir':77,'Pt':78,'Au':79,'Hg':80,'Tl':81,'Pb':82,'Bi':83,'Po':84,'At':85,'Rn':86,'Fr':87,'Ra':88,'Ac':89,'Th':90,'Pa':91,'U':92,'Np':93,'Pu':94,'Am':95,'Cm':96,'Bk':97,'Cf':98,'Es':99,'Fm':100,'Md':101,'No':102,'Lr':103,'Rf':104,'Db':105,'Sg':106,'Bh':107,'Hs':108,'Mt':109,'Ds':110,'Rg':111,'Uub':112,'Uut':113,'Uuq':114,'Uup':115,'Uuh':116,'Uus':117,'Uuo':118}

class Atom:

    """
    simply define an atom with three coordinates
    """
    def __init__(self):
        self.Symbol = ""
        self.AtomicNumber=0
        self.X = 0.0
        self.Y = 0.0
        self.Z = 0.0
        
    def ReadAtom(self, line):
        """
        Read an atom
        """
        array = line.split()
        self.X = float(array[1])
        self.Y = float(array[2])
        self.Z = float(array[3])
        self.Symbol= str(array[7])
        self.AtomicNumber= PeriodicTable[self.Symbol]
        
    def PrintAtom(self):
        """
        Print an atom to a line
        """
        line = "%s %f %f %f\n" % (self.Symbol, self.X, self.Y, self.Z)
        return line
    
def PrintHelp():
    """
    simply print the usage of the script
    """
    print "Usage: dmolcar2xyz.py [-s] input.car"
    print "Options: if -s option is used, the XYZ file will be sorted in the Z direction,"

#starting of the Main function
sortflag = 0
dmolcarname = ""
XYZName = ""

#dealing with parameters
if ( len(sys.argv) >=3 ):
    if (  sys.argv[1] == "-s"):
        print "-s optiion is used. The XYZ file will be sorted in Z direction"
        sortflag = 1
        dmolcarname = sys.argv[2]
    else:
        PrintHelp()
        exit(0)
elif( len(sys.argv) == 2):
    dmolcarname = sys.argv[1]
else:
    PrintHelp()
    exit(0)    
#Read the atoms
inp = open(dmolcarname, "r")
Atoms = []
lines= inp.readlines()
for line in lines:
    if ( len(line.split()) == 9 ):
        atom=Atom()
        atom.ReadAtom(line)
        Atoms.append(atom)
#sort the atoms if the sortflag is on.
if (sortflag == 1 ):        
    Atoms = sorted (Atoms, key = lambda atom: (atom.AtomicNumber, atom.Z, atom.Y, atom.X))
#make the output XYZ file
outlines = ""
outlines += "%d\n" % ( len(Atoms))
outlines += "Generated with dmolcar2xyz.py\n"
for atom in Atoms:
    outlines += atom.PrintAtom()
p= re.compile('\.car$')
XYZName = p.sub(".xyz",dmolcarname)
i=0
while (os.path.exists(XYZName)):
    print "File %s already exists. Trying a new filename."  % (XYZName)
    i = i + 1
    XYZName =  p.sub(".xyz",dmolcarname) + "." + str(i)
print "Writing the XYZ file to %s" % (XYZName)
outp = open(XYZName, "w")
outp.write(outlines)
outp.close()
