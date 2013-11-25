#!/usr/bin/env python
"""
This script is similiar to modemake.pl.
The script will generate DIMER_VECTOR in CP2K.
"""
from XYZFile import *
import sys, copy

def GetDiffXYZ(XYZ1, XYZ2):
    """
    Get the difference of two XYZ file.
    A DIMER VECTOR or MODECAR is made from this difference.
    """
    DiffXYZ = XYZ()
    if ( XYZ1.NumofAtoms == XYZ2.NumofAtoms ):
        DiffXYZ.NumofAtoms = XYZ1.NumofAtoms
    else:
        print "Error: Different structures: %d atoms in XYZ1 and %d in XYZ2." % (XYZ1.NumofAtoms, XYZ2.NumofAtoms)
        DiffXYZ = XYZ()
        return DiffXYZ
    for i in range(0, DiffXYZ.NumofAtoms):
        tmpAtom = Atom()
        if (XYZ1.Atoms[i].Symbol == XYZ2.Atoms[i].Symbol):
            tmpAtom.Symbol = XYZ1.Atoms[i].Symbol
            tmpAtom.Coord = XYZ2.Atoms[i].Coord - XYZ1.Atoms[i].Coord
            DiffXYZ.Atoms.append(tmpAtom)
        else:
            print "Error: Different Atom N.O. %d: %s in XYZ1 and %s in XYZ2 " % (i+1, XYZ1.Atoms[i].Symbol, XYZ2.Atoms[i].Symbol)
            DiffXYZ = XYZ()
            return DiffXYZ
    return DiffXYZ
        
#Main function
if (len(sys.argv) != 3 ):
    print "Usage: %s [initial.xyz]  [final.xyz]" % (sys.argv[0])
    exit(0)
initial = XYZ()
initial.ReadXYZ(sys.argv[1])
#debug lines
#print "Initial structure:"
#initial.PrintXYZ()
final = XYZ()
final.ReadXYZ(sys.argv[2])
#debug lines
#print "Final structure:"
#final.PrintXYZ()
DiffXYZ = GetDiffXYZ(initial, final)
#debug lines
#DiffXYZ.PrintXYZ()

#Generate the Dimer Vector from the two XYZ files.
Mode = copy.deepcopy(DiffXYZ)
sumvec = 0
for i in range(0, Mode.NumofAtoms):
    for j in range(0, 3):
        sumvec += Mode.Atoms[i].Coord[j]*Mode.Atoms[i].Coord[j]
sumvec = math.sqrt(sumvec)
for i in range(0, Mode.NumofAtoms):
    for j in range(0, 3):
        Mode.Atoms[i].Coord[j] /= sumvec
# debug line
# Mode.PrintXYZ()
Mode.WriteMode("DIMER_VECTOR")
#
