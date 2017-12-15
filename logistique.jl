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
include("parser.jl")

(n, J, JS, JB, JR, P, V, E, q, Qs, cB, cS, t, a, b, e, s, ta, r, M, K) = parser("instanceNantes/instanceNantes.txt", "instanceNantes/distancematrix98.txt")

#variable
@variable(m, X[E], Bin)
@variable(m, S[V] >= 0)
@variable(m, x[1:K, E], Bin)
@variable(m, s[1:K, V] >= 0)
@variable(m, d[1:K, P], Bin)
@variable(m, f[1:K, P], Bin)

#objectif
@objective(m, Min, sum(cB[ij] * X[ij] + sum(cS[ij] * x[k,ij] for k=1:K) for ij in E ))

#variables fixées
for k=1:K
    for i in V
        JuMP.fix(x[k,(1,i)], false)
        JuMP.fix(x[k,(i,1)], false)
        for j in JB
            JuMP.fix(x[k,(i,j)], false)
            JuMP.fix(x[k,(j,i)], false)
        end
    end
    JuMP.fix(s[k,1], 0)
    for j in JB
        JuMP.fix(s[k,j], 0)
    end
end


#contraintes

#contrainte tousservis
for j in J
    @constraint(m, sum(X[(i,j)] + sum(x[k,(i,j)] for k=1:K) for i in V) == 1 )
end

#fenetrerestant1
println("JR : ",JR," ", sizeof(JR)[1]," ", typeof(JR))
println("a : ",a," ", sizeof(a)[1]," ", typeof(a))
println("b : ",b," ", sizeof(b)[1]," ", typeof(b))
println("K = ",K)
for i in JR
    for k = 1:K
        @constraint(m, s[k,i] >= a[i])
        @constraint(m, s[k,i] <= b[i])
    end
end

#fenetrerestant2
for i in JR
    @constraint(m, S[i] >= a[i])
    @constraint(m, S[i] <= b[i])
end

#partirdudepot
@constraint(m, sum(X[(1,j)] for j in V) == 1)

#flotgros
for h in union(J,P)
    @constraint(m, sum(X[(i,h)] for i in V) - sum(X[(h,j)] for j in V) == 0)
end

#reveniraudepot
@constraint(m, sum(X[(i,1)] for i in V) == 1)

#sequentialitegros1
for i in J
    for j in V
        @constraint(m, S[i] + s + t[(i,j)] - M(1 - X[(i,j)]) <= S[j])
    end
end

#sequentialitegros2
for i in P
    for j in V
        @constraint(m, S[i] + ta + t[(i,j)] - M(1 - X[(i,j)]) <= S[j])
    end
end

#sequentialitegros3
for j in V
    @constraint(m, 0 + t[(1,j)] - M(1 - X[(1,j)]) <= S[j])
end

#sequentialitegros4
for i in V
    @constraint(m, S[i] + t[(i,1)] - M(1 - X[(i,1)]) <= S[1])
end

#findejournee
@constraint(m, S[1] <= e)

#fenetregros
for i in JB
    @constraint(m, S[i] >= a[i])
    @constraint(m, S[i] <= b[i])
end

#toutes les contraintes du petit
for k = 1:K
    #separationvalide
    for j in P
        @constraint(m, d[k,j] <= sum(X[(i,j)] for i in V))
    end

    #mergevalide
    for j in P
        @constraint(m, f[k,j] <= sum(X[(i,j)] for i in V))
    end

    #partirdugros
    for i in P
        @constraint(m, sum(x[k,(i,j)] for j in V) == d[k,i])
    end

    #flotpetit
    for h in J
        @constraint(m, sum(x[k,(i,h)] for i in V) - sum(x[k,(h,j)] for j in V) == 0)
    end

    #reveniraugros
    for j in P
        @constraint(m, sum(x[k,(i,j)] for i in V) == f[k,i])
    end

    #datedebutpetit
    for i in P
        @constraint(m, s[k,i] >= S[i] - M(1 - d[k,i]))
    end

    #datedefinpetit
    for i in P
        for j in V
            @constraint(m, s[k,i] + ta <= S[j] - t[(i,j)] + M(1-f[k,i]) + M(1-X[(i,j)]))
        end
    end

    #sequentialitepetit1
    for i in J
        for j in V
            @constraint(m, s[i] + s + r*t[(i,j)] - M(1 - x[(i,j)]) <= s[j])
        end
    end

    #sequentialitepetit2
    for i in P
        for j in V
            @constraint(m, s[i] + ta + r*t[(i,j)] - M(1 - x[(i,j)]) <= s[j])
        end
    end

    #fenetrepetit
    for i in JS
        @constraint(m, s[k,i] >= a[i])
        @constraint(m, s[k,i] <= b[i])
    end

    #capa
    @constraint(m, sum(q[j] * sum(x[k,(i,j)] for i in V) for j in J ) <= Qs)
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
