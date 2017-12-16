function ConsRec(R, w, c, n, cur, pos)
    if pos == n+1
        push!(R, copy(cur))
    else
        if ((pos == 1) ? 0 : sum(cur[i]*w[i] for i = 1:pos-1)) + w[pos] <= c
            cur[pos] = 1
            ConsRec(R,w,c,n,cur,pos+1)
        end
        cur[pos] = 0
        ConsRec(R,w,c,n,cur,pos+1)
    end
    return R
end

function Complet(c,w,n)
    return function (seq)
        flag = true # = est complet
        somme = sum(seq[j]*w[j] for j = 1:n)
        for i = 1:n
            flag = flag && ((seq[i] == 1) || (somme + w[i] > c))
        end
        return flag
    end
end

function genereMaxCover(JS,JR,q,QS)
    J = vcat(JS,JR) #ensembles des clients qui nous interesse ici
    R = [] #ensemble des covering maximaux
    cur = fill(0, size(J)[1]) #patern
    w = [q[i] for i in J]

    R = ConsRec(R,w,Qs,size(J)[1],cur,1)
    R = filter(Complet(Qs,w,size(J)[1]), R)

    return R
end
