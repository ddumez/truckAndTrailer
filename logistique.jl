
using JuMP

#pour résoudre avec GLPK
using GLPKMathProgInterface
using GLPK
#pour resoudre avec CPLEX
# export LD_LIBRARY_PATH="/usr/local/opt/cplex/cplex/bin/x86-64_linux":$LD_LIBRARY_PATH
using CPLEX

m = Model(solver=GLPKSolverMIP())
#m = Model(solver=CplexSolver())

#data

#variable
@variable(m, X[E])
@variable(m, S[V])
@variable(m, x[1:K][E])
@variable(m, s[1:K][V])
@variable(m, d[1:K][P])
@variable(m, f[1:K][P])

#objectif

#contraintes

#affichage
