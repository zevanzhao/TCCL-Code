#!/usr/bin/env python
"""
Read the Dimer Vector from CP2K.
The vector is read from the cp2k-1.restart file.
"""
import sys,re
#Read the cp2k-1.restart file
if ( len(sys.argv) < 2):
    print "Usage: %s cp2k-1.restart" %(sys.argv[0])
    exit()
CP2KFileName = sys.argv[1]
DimerFileName = "NEWMODECAR"
inp=open(CP2KFileName, "r")
lines=inp.readlines()
inp.close()

#Get the startline and endline of the dimer vector
i=0
VectorStart=0
VectorEnd=0
for line in lines:
    if (re.search(ur"&DIMER_VECTOR",line)):
#        print "Find the start line in lin %d" % (i)
        VectorStart = i+1
    elif (re.search(ur"&END DIMER_VECTOR", line)):
#        print "Find the end line in lin %d" % (i)
        VectorEnd = i
        break
    i += 1
VectorLines=lines[VectorStart:VectorEnd]
#Print the vector lines
DimerVector = []
NumVector= 0
for line in VectorLines:
    line=re.sub(ur"\\","",line)
    DimerVector.extend(line.split())
#print "Number of vectors: %d" % (len(DimerVector))
if (len(DimerVector)%3 != 0 ):
    print "Error: Number of Dimer vectors is %d, cannot be divided by 3." % (len(DimerVector))
else:
    NumVector= len(DimerVector)/3
modelines=""
for i in range(0, NumVector):
    modelines += "%f\t%f\t%f\n" % ( float(DimerVector[3*i]), float(DimerVector[3*i+1]), float(DimerVector[3*i+2]))

outp=open(DimerFileName,"w")
outp.writelines(modelines)
outp.close()
