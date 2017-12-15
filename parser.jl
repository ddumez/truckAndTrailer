function parser(instance::String, distancier::String)
	numbers = readdlm(instance)

	#Variables associées au camion
	Qs = numbers[1,1]
	e = numbers[1,3]
	s = numbers[1,5]
	ta = numbers[1,5]
	r = numbers[1,2]

	n = size(numbers)[1]
	nP = 0
	nS = 0
	nB = 0
	nR = 0
	max = 0

	#Recupération du nombre de chaque tableau
	for i in 1:n
	  if(numbers[i,3]=="P")
	    nP = nP+1
	  end
	  if(numbers[i,3]=="S")
	    nS = nS + 1
	  end
	  if(numbers[i,3]=="L")
	    nB = nB+1
	  end
	  if(numbers[i,3]=="LS")
	    nR = nR+1
	  end 
	  if(numbers[i,1]>max && i>1)
	    max = numbers[i,1]
	  end
	end

	#println(nP," ",nS," ",nB," ",nR)
	#println(max," ",n)

	#constantes grandes a fixer
	M = e
	K = nS

	#Construction de JS and co
	J = fill(0,nS + nB + nR)
	JS = fill(0,nS)
	JB = fill(0,nB)
	JR = fill(0,nR)
	P = fill(0,nP)
#= Ce doit etre des dictionaires car il y a des trous	
	V = collect(1:max) #plus 1 parceque D
	q = fill(0,nS + nB + nR)
	a = fill(0,nS + nB + nR)
	b = fill(numbers[1,4],nS + nB + nR) #s
=#
	q = Dict()
	a = Dict()
	b = Dict()

	cJ = 1
	cP = 1
	cS = 1
	cB = 1
	cR = 1
	cV = 1

	retenue = max+1

	#Recupération du nombre de chaque tableau
	for i in 2:n
	  if(numbers[i,3]=="S" || numbers[i,3]=="L" || numbers[i,3]=="LS")
	    J[cJ] = numbers[i,1]
	    #=
	    q[cJ] = numbers[i,2]
	    a[cJ] = numbers[i,6]
	    b[cJ] = b[cJ]+numbers[i,6]
	    =#
	    push!(q, numbers[i,1] => numbers[i,2])
	    push!(a, numbers[i,1] => numbers[i,6])
	    push!(b, numbers[i,1] => numbers[i,6] + numbers[1,4])
	    cJ = cJ + 1
	  end
	  if(numbers[i,3]=="P")
	    P[cP] = numbers[i,1]
	    cP = cP+1
	  end
	  if(numbers[i,3]=="S")
	    JS[cS] = numbers[i,1]
	    cS = cS + 1
	  end
	  if(numbers[i,3]=="L")
	    JB[cB] = numbers[i,1]
	    cB = cB+1
	  end
	  if(numbers[i,3]=="LS")
	    JR[cR] = numbers[i,1]
	    cR = cR+1
	  end
	end

	V = union(J,P,[1])

	#ET LES ARETES
	dist = readdlm(distancier)

	E = Array{Tuple{Int,Int}}(0)

	for i in V
	  for j in V
	    push!(E,(i,j))
	  end
	end
	#arc de i a i inutile
	filter(x-> x[1] != x[2], E)

	t = Dict(E[i] => dist[E[i][1],E[i][2]] for i = 1:size(E)[1])
	cB = Dict(E[i] => dist[E[i][1],E[i][2]] for i = 1:size(E)[1])
	cS = Dict(E[i] => dist[E[i][1],E[i][2]]*r for i = 1:size(E)[1])
	#println(cS[(84,98)])
	

	#Copie des parkings
	P2 = copy(P)

	compte = max+1

	for i in P
		for k in 1:K
			copieinumk = compte
			compte = compte+1
			push!(P2,copieinumk)
			push!(V,copieinumk)
			for j in V
				if (i,j) in E
					push!(E,(copieinumk,j))
					push!(t,(copieinumk,j) => t[(i,j)])
					push!(cB,(copieinumk,j) => cB[(i,j)])
					push!(cS,(copieinumk,j) => cS[(i,j)])
				end
				if (j,i) in E
					push!(E,(j,copieinumk))
					push!(t,(j,copieinumk) => t[(j,i)])
					push!(cB,(j,copieinumk) => cB[(j,i)])
					push!(cS,(j,copieinumk) => cS[(j,i)])
				end
			end
		end 
	end
	P = copy(P2)

	print(P)

	return (n, J, JS, JB, JR, P, V, E, q, Qs, cB, cS, t, a, b, e, s, ta, r, M, K)
end
