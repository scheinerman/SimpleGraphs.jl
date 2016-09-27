# Functions to create standard digraph matrices

# Adjaceny Matrix
function adjacency(G::SimpleDigraph)
    n = NV(G)
    A = zeros(Int,(n,n))

    # create a table from V to 1:n
    d = vertex2idx(G)
    E = elist(G)

    for e in E
        i = d[e[1]]
        j = d[e[2]]
        A[i,j]=1
    end

    return A
end


# incidence matrix
function incidence(G::SimpleDigraph)
    n = NV(G)
    m = NE(G)
    M = spzeros(Int,n,m)
    d = vertex2idx(G)
    E = elist(G)
 
    idx = 0
    for e in E
        i = d[e[1]]
        j = d[e[2]]
        idx += 1
        M[i,idx] = 1
        M[j,idx] = -1
    end

    return M
end
