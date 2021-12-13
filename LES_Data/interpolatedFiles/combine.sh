#!/bin/bash
rm U p Tau

touch U
cat U.part1 >> U
cat UList >> U
cat U.part2 >> U
#cp U /home/ob/Documents/GitHub/FI-cases/LES_Data/OFfiles/0
cp U /home/dafoamuser/mount/PH/CinellaData/OFInterpolateFiles/0

touch Tau
cat Tau.part1 >> Tau
cat TauList >> Tau
cat Tau.part2 >> Tau
cp Tau /home/dafoamuser/mount/PH/CinellaData/OFInterpolateFiles/0

touch p
cat p.part1 >> p
cat pList >> p
cat p.part2 >> p
cat p.part3 >> p
cp p /home/ob/Documents/GitHub/FI-cases/LES_Data/OFfiles/0
#cp p /home/dafoamuser/mount/PH/CinellaData/OFInterpolateFiles/0
