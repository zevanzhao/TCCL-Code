#!/usr/bin/env python
"""
A script used to shrink the xyz file in CP2K
"""
import sys
Step = int(sys.argv[1])
FileName =sys.argv[2]
ShrinkFileName= "Every_"+str(Step)+"_"+FileName
inp = open(FileName,'r')
lines = inp.readlines()
inp.close()
outp = open(ShrinkFileName,"w")
BlockSize= int(lines[0])+2
GeoNum= len(lines)/BlockSize
SelectedGeoNum = int(GeoNum/Step)
NewLines= ""
for i in range(0, SelectedGeoNum):
    for line in lines[i*Step*BlockSize:(i*Step+1)*BlockSize]:
        NewLines += line
outp.write(NewLines)
outp.close()
