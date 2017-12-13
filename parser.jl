function parser(instance::String, distancier::String)
	numbers = readdlm(instance)

	#Variables associées au camion
	Qs = numbers[1,1]
	e = numbers[1,3]
	s = numbers[1,5]
	ta = numbers[1,5]
	r = numbers[1,2]

	n = size(numbers)[1] -1
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
	    max=numbers[i,1]
	  end
	end

	#println(nP," ",nS," ",nB," ",nR)
	#println(max," ",n)

	#Construction de JS and co
	J = fill(0,nS + nB + nR)
	JS = fill(0,nS)
	JB = fill(0,nB)
	JR = fill(0,nR)
	P = fill(0,nP)
	V = collect(1:max) #plus 1 parceque D
	q = fill(0,nS + nB + nR)
	a = fill(0,nS + nB + nR)
	b = fill(numbers[1,4],nS + nB + nR) #s

	cJ = 1
	cP = 1
	cS = 1
	cB = 1
	cR = 1
	cV = 1

	#Recupération du nombre de chaque tableau
	for i in 2:n
	  if(numbers[i,3]=="S" || numbers[i,3]=="L" || numbers[i,3]=="LS")
	    J[cJ] = numbers[i,1]
	    q[cJ] = numbers[i,2]
	    a[cJ] = numbers[i,6]
	    b[cJ] = b[cJ]+numbers[i,6]
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

	#ET LES ARETES
	dist = readdlm(distancier)
	nE = max*max

	E = fill((0,0),nE)
	cB = fill(0,nE)
	cS = fill(0,nE)
	t = fill(0,nE)

	for i in 1:max
	  for j in 1:max
	    E[(i-1)*max+j] = (i,j)
	  end
	end

	t = Dict(E[i] => dist[E[i][1],E[i][2]] for i = 1:size(E)[1])
	cB = Dict(E[i] => dist[E[i][1],E[i][2]] for i = 1:size(E)[1])
	cS = Dict(E[i] => dist[E[i][1],E[i][2]]*r for i = 1:size(E)[1])
	#println(cS[(84,98)])


	#constantes grande a fixer
	M = e
	K = nS

	#ajout du duplica du depos en tant que n+1
	#push!(V, n+1)

	return (n, J, JS, JB, JR, P, V, E, q, Qs, cB, cS, t, a, b, e, s, ta, r, M, K)
end