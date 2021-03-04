#!/usr/bin/env python
"""
DAFoam run script for the baseline periodic hills case
"""

# =============================================================================
# Imports
# =============================================================================
import os
import argparse
from mpi4py import MPI
from dafoam import PYDAFOAM, optFuncs
from pygeo import *
from pyspline import *
from idwarp import USMesh
from pyoptsparse import Optimization, OPT
import numpy as np


# =============================================================================
# Input Parameters
# =============================================================================
parser = argparse.ArgumentParser()
parser.add_argument("--opt", help="optimizer to use", type=str, default="ipopt")
parser.add_argument("--task", help="type of run to do", type=str, default="opt")
args = parser.parse_args()
gcomm = MPI.COMM_WORLD

# Define the global parameters here
U0 = 0.028
p0 = 0.0
nuTilda0 = 1e-2
rho = 1
nu = 5e-6
mu = rho * nu
magURef = 0.028
dynPressure = 0.5 * rho * magURef**2

# Set the parameters for optimization
daOptions = {
    "designSurfaces": ["bottomWall"],
    "solverName": "DASimpleFoam",
    "adjJacobianOption": "JacobianFree",
    "primalMinResTol": 1.0e-6,
    "objFunc": {
        "FI": {
            "part1": {
                "type": "stateErrorNorm",
                "source": "boxToCell",
                "min": [-10.0, -10.0, -10.0],
                "max": [10.0, 10.0, 10.0],
                "stateType": "surfaceFriction",
                "stateName": "surfaceFriction",
                "stateRefName": "surfaceFrictionRef",
                "varTypeFieldInversion": "surface",
                "scale": mu/dynPressure,
                "patchNames": ["bottomWall"],
                "addToAdjoint": True,
            },
            "part2": {
                "type": "stateErrorNorm",
                "source": "boxToCell",
                "min": [-10.0, -10.0, -10.0],
                "max": [10.0, 10.0, 10.0],
                "stateType": "scalar",
                "stateName": "betaFieldInversion",
                "stateRefName": "betaRefFieldInversion",
                "varTypeFieldInversion": "volume",
                "scale": 1e-10,
                "patchNames": ["bottomWall"],
                "addToAdjoint": True,
            },
        },
    },
    "adjEqnOption": {"gmresRelTol": 1.0e-6, "pcFillLevel": 1, "jacMatReOrdering": "rcm"},
    "normalizeStates": {
        "U": U0,
        "p": U0 * U0 / 2.0,
        "nuTilda": nuTilda0 * 10.0,
        "phi": 1.0,
    },
    "adjPartDerivFDStep": {"State": 1e-7, "FFD": 1e-3},
    "adjPCLag": 100,
    "designVar": {},
    "fvSource":{
                "gradP": {
                    "type": "uniformPressureGradient",
                    "value": 6.8685e-06,
                    "direction": [1.0, 0.0, 0.0],
                },
    },
}

# mesh warping parameters, users need to manually specify the symmetry plane and their normals
meshOptions = {
    "gridFile": os.getcwd(),
    "fileType": "openfoam",
    # point and normal for the symmetry plane
    "symmetryPlanes": [[[0.0, 0.0, 0.0], [0.0, 0.0, 1.0]], [[0.0, 0.0, 0.1], [0.0, 0.0, 1.0]]],
}

# options for optimizers
if args.opt == "ipopt":
    optOptions = {
        "tol": 1.0e-9,  # set to > 1e-10
        "max_iter": 1000,
        "output_file": "opt_IPOPT.out",
        "constr_viol_tol": 1.0e-9,
        "mu_strategy": "adaptive",
        "limited_memory_max_history": 26,
        "nlp_scaling_method": "gradient-based",
        "alpha_for_y": "full",
        "recalc_y": "yes",
        "print_level": 5,
    }
else:
    print("opt arg not valid!")
    exit(0)


# =============================================================================
# Design variable setup
# =============================================================================
def betaFieldInversion(val, geo):
    for idxI, v in enumerate(val):
        DASolver.setFieldValue4GlobalCellI(b"betaFieldInversion", v, idxI)

DVGeo = DVGeometry("./FFD/periodicHillFFD.xyz")
DVGeo.addRefAxis("bodyAxis", xFraction=0.25, alignIndex="k")

nCells = 14751
beta0 = np.ones(nCells, dtype="d")
#beta0[1] = 0.99
DVGeo.addGeoDVGlobal("beta", value=beta0, func=betaFieldInversion, lower=1e-5, upper=10.0, scale=1.0)
daOptions["designVar"]["beta"] = {"designVarType": "Field", "fieldName": "betaFieldInversion", "fieldType": "scalar"}

# =============================================================================
# DAFoam initialization
# =============================================================================
DASolver = PYDAFOAM(options=daOptions, comm=gcomm)
DASolver.setDVGeo(DVGeo)
mesh = USMesh(options=meshOptions, comm=gcomm)
DASolver.addFamilyGroup(DASolver.getOption("designSurfaceFamily"), DASolver.getOption("designSurfaces"))
DASolver.printFamilyList()
DASolver.setMesh(mesh)
evalFuncs = []
DASolver.setEvalFuncs(evalFuncs)

# =============================================================================
# Constraint setup
# =============================================================================
DVCon = DVConstraints()
DVCon.setDVGeo(DVGeo)
DVCon.setSurface(DASolver.getTriangulatedMeshSurface(groupName=DASolver.getOption("designSurfaceFamily")))
# =============================================================================
# Initialize optFuncs for optimization
# =============================================================================
optFuncs.DASolver = DASolver
optFuncs.DVGeo = DVGeo
optFuncs.DVCon = DVCon
optFuncs.evalFuncs = evalFuncs
optFuncs.gcomm = gcomm

# =============================================================================
# Task
# =============================================================================
if args.task == "opt":

    optProb = Optimization("opt", objFun=optFuncs.calcObjFuncValues, comm=gcomm)
    DVGeo.addVariablesPyOpt(optProb)
    DVCon.addConstraintsPyOpt(optProb)

    optProb.addObj("FI", scale=1)
    # optProb.addCon("CL", lower=CL_target, upper=CL_target, scale=1)

    if gcomm.rank == 0:
        print(optProb)

    DASolver.runColoring()

    opt = OPT(args.opt, options=optOptions)
    histFile = "./%s_hist.hst" % args.opt
    sol = opt(optProb, sens=optFuncs.calcObjFuncSens, storeHistory=histFile)
    if gcomm.rank == 0:
        print(sol)

elif args.task == "runPrimal":

    optFuncs.runPrimal()

elif args.task == "runAdjoint":

    optFuncs.runAdjoint()

elif args.task == "verifySens":

    optFuncs.verifySens()

elif args.task == "testAPI":

    DASolver.setOption("primalMinResTol", 1e-2)
    DASolver.updateDAOption()
    optFuncs.runPrimal()

else:
    print("task arg not found!")
    exit(0)