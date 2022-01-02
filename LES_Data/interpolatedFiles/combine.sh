#!/bin/bash
rm varRefFieldInversion p Tau surfacePressureRef surfaceFrictionRef profileRefFieldInversion

touch U
cat U.part1 >> U
cat UList >> U
cat U.part2 >> U
mv U varRefFieldInversion
cp varRefFieldInversion /home/ob/Documents/GitHub/FI-cases/LES_Data/OFfiles/0
#cp U /home/dafoamuser/mount/PH/CinellaData/OFInterpolateFiles/0

touch Tau
cat Tau.part1 >> Tau
cat TauList >> Tau
cat Tau.part2 >> Tau
#cp Tau /home/dafoamuser/mount/PH/CinellaData/OFInterpolateFiles/0
cp Tau /home/ob/Documents/GitHub/FI-cases/LES_Data/OFfiles/0

touch p
cat p.part1 >> p
cat pList >> p
cat p.part2 >> p
cat pLowerWall >> p
cat p.part3 >> p
cp p /home/ob/Documents/GitHub/FI-cases/LES_Data/OFfiles/0

touch surfacePressureRef
cat surfacePressureRef.part1 >> surfacePressureRef
cat pLowerWall >> surfacePressureRef
cat surfacePressureRef.part2 >> surfacePressureRef
cp surfacePressureRef /home/ob/Documents/GitHub/FI-cases/LES_Data/OFfiles/0

touch surfaceFrictionRef
cat surfaceFrictionRef.part1 >> surfaceFrictionRef
cat CfLowerWall >> surfaceFrictionRef
cat surfacePressureRef.part2 >> surfaceFrictionRef
cp surfaceFrictionRef /home/ob/Documents/GitHub/FI-cases/LES_Data/OFfiles/0 

touch profileRefFieldInversion
cat profileRefFieldInversion.part1 >> profileRefFieldInversion
cat profileRefXiao >> profileRefFieldInversion
cat profileRefFieldInversion.part2 >> profileRefFieldInversion
cp profileRefFieldInversion /home/ob/Documents/GitHub/FI-cases/LES_Data/OFfiles/0
