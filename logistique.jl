
using JuMP

#pour résoudre avec GLPK
using GLPKMathProgInterface
using GLPK
#pour resoudre avec CPLEX
# export LD_LIBRARY_PATH="/usr/local/opt/cplex/cplex/bin/x86-64_linux":$LD_LIBRARY_PATH
#using CPLEX

m = Model(solver=GLPKSolverMIP())
#m = Model(solver=CplexSolver())

#data
n
J
JS
JB
JR #J-JS-JB
P
V
E
q[J]
Qs
cB[E]
cS[E]
t[E]
a[J]
b[J]
e
s #service duration
a #temps d'assemblage
r #speed ratio
M
K

#variable
@variable(m, X[E], Bin)
@variable(m, S[V] >= 0)
@variable(m, x[1:K][E], Bin)
@variable(m, s[1:K][V] >= 0)
@variable(m, d[1:K][P], Bin)
@variable(m, f[1:K][P], Bin)

#objectif
@objectif(m, Min, sum(cB[ij] * X[ij] + sum(cS[ij] * x[k][ij] for k=1:K) for ij in E ))

#variables fixées
for k=1:K
    for i in V
        JuMP.fix(x[k][(0,i)],0)
        JuMP.fix(x[k][(i,0)],0)
        JuMP.fix(x[k][(n+1,i)],0)
        JuMP.fix(x[k][(i,n+1)],0)
    end
    JuMP.fix(s[k][(0)],0)
    JuMP.fix(s[k][n+1],0)
end


#contraintes
for j in J
    @constraint(m, sum(X[(i,j)] + sum(x[k][(i,j)] for k=1:K) for i in V) == 1 )
end

for i in JR
    for k = 1:K
        @constraint(m, s[k][i] >= a[i])
        @constraint(m, s[k][i] <= b[i])
    end
end

for i in JR
    @constraint(m, S[i] >= a[i])
    @constraint(m, S[i] <= b[i])
end

@constraint(m, sum(X[(0,j)] for j in V) == 1)

for h in union(J,P)
    @constraint(m, sum(X[(i,h)] for i in V) - sum(X[(h,j)] for j in V) == 0)
end

@constraint(m, sum(X[(i,n+1)] for i in V) == 1)

for (i,j) in J
    @constraint(m, S[i] + s + t[(i,j)] - M(1 - X[(i,j)]) <= S[j])
end
for (i,j) in P
    @constraint(m, S[i] + a + t[(i,j)] - M(1 - X[(i,j)]) <= S[j])
end
for j in V
    @constraint(m, S[0] - M(1 - X[(0,j)]) <= S[j])
end
for i in V
    @constraint(m, S[i] - M(1 - X[(i,n+1)]) <= S[n+1])
end

@constraint(m, S[n+1] <= e)

for i in JB
    @constraint(m, S[i] >= a[i])
    @constraint(m, S[i] <= b[i])
end


for k = 1:K
    for j in P
        @constraint(m, d[k][j] <= sum(X[(i,j)] for i in V))
    end

    for j in P
        @constraint(m, f[k][j] <= sum(X[(i,j)] for i in V))
    end

    for i in P
        @constraint(m, sum(x[k][(i,j)] for j in V) == d[k][i])
    end

    for h in J
        @constraint(m, sum(x[k][(i,h)] for i in V) - sum(x[k][(h,j)] for j in V) == 0)
    end

    for j in P
        @constraint(m, sum(x[k][(i,j)] for i in V) == f[k][i])
    end

    for i in P
        @constraint(m, s[k][i] >= S[i] + a - M(1 - d[k][i]))
    end

    for i in P
        for j in V
            @constraint(m, s[k][i] + a <= S[j] - t[(i,j)] + M(1-f[k][i]) + M(1-X[(i,j)]))
        end
    end

    for (i,j) in J
        @constraint(m, s[k][i] + s + r*t[(i,j)] - M(1 - X[(i,j)]) <= s[k][j])
    end

    for i in JS
        @constraint(m, s[k][i] >= a[i])
        @constraint(m, s[k][i] <= b[i])
    end

    @constraint(m, sum(q[j] * sum(x[k][(i,j)] for i in V) for j in J ) <= Qs)
end

#affichage
solve(m)
println(getobjectivevalue(m))
println(getvalue(X))
println(getvalue(S))
println(getvalue(x))
println(getvalue(s))
println(getvalue(d))
println(getvalue(f))
