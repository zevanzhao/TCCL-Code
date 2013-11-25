#!/usr/bin/env python
"""
A script to get the optimized geometry from ADF DFTB calculation out file.
"""
import sys, re
ADFOUT=sys.argv[1]
inp=open(ADFOUT, "r")
outlines=inp.readlines()
#Search for the geometry section
start=[]
end=[]
i=0
for line in outlines:
    if (re.match(ur"^Geometry$", line)):
        #print "Find start at line %d" %(i)
        start.append(i)
    elif (re.match(ur"^current energy", line)):
        #print "Find end at line %d" %(i)
        end.append(i+1)
    i+=1
#print "length of start:%d" %( len(start))
#print "length of end:%d" %( len(end))
movielines=""
for k in range(0, len(end)):
    #print "Section between line %d to %d" % (start[k], end[k])
    geolines=outlines[start[k]:end[k]]
    #print "%s" % (geolines)
    mid=0
    #Search for the geometry section in angstrom
    i=0
    for line in geolines:
        if (re.search(ur"angstrom", line)):
            mid = i+1
            break
        i += 1
    angstromgeo=geolines[mid:]
    #print "%s" % (angstromgeo)
    #print the geometry
    j=0
    xyzlines=""
    energy=0
    for line in angstromgeo:
        array=line.split()
        if ( len(array) == 5):
            j += 1
            xyzlines += "%s %s %s %s\n" % (array[1], array[2], array[3], array[4])
        elif (re.match(ur"^current energy", line)):
            energy=array[2]
    movielines += "%d\n%s\n%s" %(j, energy, xyzlines)
#print the movie lines.
print "%s" % (movielines),
