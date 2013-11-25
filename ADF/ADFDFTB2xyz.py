#!/usr/bin/env python
#Time-stamp: <Last updated: Zhao,Yafan zhaoyafan@mail.thu.edu.cn 2013-11-25 20:20:08>
"""
A script to get the optimized geometry from ADF DFTB calculation out file.
"""
import sys, re
if (len(sys.argv) < 2):
    print "Usage: ADFDFTB2xyz.py [adf.out]"
    exit(0)
ADFOUT = sys.argv[1]
inp = open(ADFOUT, "r")
outlines = inp.readlines()
#Search for the geometry section
start = 0
end = 0
i = 0
for line in outlines:
    if (re.match(ur"^Geometry$", line)):
        #print "Find start at line %d" %(i)
        start = i
    elif (re.match(ur"^Total Energy \(hartree\)", line)):
        #print "Find end at line %d" %(i)
        end = i+1
    i += 1
i = 0
geolines = outlines[start:end]
#print "%s" % (geolines)
mid = 0
#Search for the geometry section in angstrom
for line in geolines:
    if (re.search(ur"angstrom", line)):
        mid = i+1
        break
    i += 1
angstromgeo = geolines[mid:]
#print "%s" % (angstromgeo)
#print the geometry
j = 0
xyzlines = ""
energy = 0
for line in angstromgeo:
    array = line.split()
    if ( len(array) == 5):
        j += 1
        xyzlines += "%s %s %s %s\n" % (array[1], array[2], array[3], array[4])
    elif (re.match(ur"^Total Energy", line)):
        energy = array[3]
movielines = ""
movielines += "%d\n%s\n%s" % (j, energy, xyzlines)
print "%s" % (movielines),
