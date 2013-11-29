#!/usr/bin/env python
"""
A script written to read the out put of Transition state search using dimer method. 
"""
import sys,re
DimerOutFileName = sys.argv[1]
Inp= open(DimerOutFileName,"r")
Outp= open("fe.dat","w")
lines = Inp.readlines()
outlines = ""
Inp.close()
energy = 0
stepnum = 0
maxforce = 0.00
tmpenery = 0
i = 0
converge = 0 
outlines += "Step\tEnergy(a.u.)\tMax.Gradient\n"
while (i < len(lines)):
    if ( re.search(r"ENERGY| Total FORCE_EVAL",lines[i])):
        m = re.search(r"([+\-]?\d+\.\d+)", lines[i])
        #debug 
        #print "%s" % (m.group(1))
        energy = float(m.group(1))
    elif (re.search(ur"Informations at step",lines[i])):
        m = re.search(r"at step\s+=\s+(\d+)",lines[i])
        stepnum = int(m.group(1))
        while (True):
            i += 1
            if (re.search(r"Max. gradient", lines[i])):
                m = re.search(r"Max. gradient\s+=\s+([+\-]?\d+\.\d+)",lines[i])
                maxforce = float(m.group(1))
            if (re.search(r"---------------------------------------------------", lines[i])):
                break
        if (maxforce > 0.00):
            outlines += "%d\t%12.8f\t%E\n" %(stepnum, energy,maxforce)
        else:
            outlines += "%d\t%12.8f\n" %(stepnum, energy)
    elif (re.search(ur"GEOMETRY OPTIMIZATION COMPLETED", lines[i])):
        stepnum += 1
        converge = 1 
        while (i < len(lines)) :
            if ( re.search(r"ENERGY| Total FORCE_EVAL",lines[i])):
                m = re.search(r"([+\-]?\d+\.\d+)", lines[i])
                #debug 
                #print "%s" % (m.group(1))
                energy = float(m.group(1))
            i += 1
    i += 1
if ( 1 == converge):
    outlines += "%d\t%12.8f\n" % (stepnum, energy)
Outp.writelines(outlines)
