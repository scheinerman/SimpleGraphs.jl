export toggle!, local_complement!, interlace

"""
`toggle!(G,x,y)` deletes edge `xy` if present or adds edge `xy`
if absent. **No error checking is done**.
"""
function toggle!(G::SimpleGraph,x,y)
    if has(G,x,y)
        delete!(G,x,y)
    else
        add!(G,x,y)
    end
    nothing
end

"""
`super_toggle!(G,A,B)` toggles all edges/nonedges `ab`
where `a` is in `A` and `b` is in `B`.
**No error checking is done**.
"""
function super_toggle!(G::SimpleGraph,A::Set, B::Set)
    for a in A
        for b in B
            toggle!(G,a,b)
        end
    end
    nothing
end


"""
`local_complement!(G,v)` complements the edges in the neighborhood of `v`.
That is, if `u` and `w` are neighbors of `v` then we toggle the edge/nonedge
`uw`, modifying the graph.
"""
function local_complement!(G::SimpleGraph, v)
    if !has(G,v)
        error("Vertex $v is not in this graph")
    end
    Nv = G[v]  # get neighbors
    dv = length(Nv)

    for i=1:dv-1
        u = Nv[i]
        for j=i+1:dv
            w = Nv[j]
            toggle!(G,u,w)
        end
    end
    nothing
end


function pivot!(G::SimpleGraph,a,b,debug::Bool=false)
    if !has(G,a,b)
        error("Edge ($a,$b) is not in this graph")
    end
    NA = Set(G[a])
    delete!(NA,b)
    NB = Set(G[b])
    delete!(NB,a)
    if debug
        println("N[$a] = $NA")
        println("N[$b] = $NB")
    end


    A = setdiff(NA,NB)
    B = setdiff(NB,NA)
    C = intersect(NA,NB)

    if debug
        println("A = $A")
        println("B = $B")
        println("C = $C")
    end

    super_toggle!(G,A,B)
    super_toggle!(G,A,C)
    super_toggle!(G,B,C)
end

"""
`interlace(G)` returns the interlace polynomial of the graph `G`.
"""
function interlace(G::SimpleGraph, saver::Bool=true)
    if saver && cache_check(G,:interlace)
        return cache_recall(G,:interlace)
    end
    if NE(G)==0
        return Poly([0,1])^NV(G)
    end

    e = first(G.E)
    a = e[1]
    b = e[2]

    G1 = deepcopy(G)
    delete!(G1,a)
    p1 = interlace(G1,false)

    G2 = deepcopy(G)
    pivot!(G2,a,b)
    delete!(G2,b)
    p2 = interlace(G2,false)

    p = p1+p2
    if saver
        cache_save(G,:interlace,p)
    end

    return p
end
