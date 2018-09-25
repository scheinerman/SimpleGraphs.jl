export DirectedPath, DirectedCycle, DirectedComplete
export RandomDigraph, RandomTournament, TorusDigraph

"""
`DirectedPath(n)` creates a directed cycles with vertices `1:n`.
"""
function DirectedPath(n::Int)
    if n < 1
        error("n must be positive")
    end
    G = IntDigraph(n)
    for u=1:(n-1)
        add!(G,u,u+1)
    end
    return G
end

"""
`DirectedCycle(n)` creates a directed cycles with vertices `1:n`.
"""
function DirectedCycle(n::Int)
    G = DirectedPath(n)
    add!(G,n,1)
    return G
end

# Create a complete digraph (all possible edges)
"""
`DirectedComplete(n)` creates a directed complete graph with
all possible edges (including a loop at each vertex). Use
`DirectedComplete(n,false)` to supress the creation of loops.
"""
function DirectedComplete(n::Int, with_loops::Bool=true)
    G = IntDigraph(n)
    if !with_loops
        forbid_loops!(G)
    end
    for u=1:n
        for v=1:n
            add!(G,u,v)
        end
    end
    return G
end

# Create a random digraph (Erdos-Renyi style)
"""
`RandomDigraph(n,p)` creates an Erdos-Renyi style random directed
graph with vertices `1:n` and edge probability `p` (equal to 0.5 by
default). The possible edges `(u,v)` and `(v,u)` are independent. No
loops are created. To also create loops (each with probability `p`)
use `RandomDigraph(n,p,true)`.
"""
function RandomDigraph(n::Int, p::Real=0.5, with_loops=false)
    G = IntDigraph(n)
    if !with_loops
        forbid_loops!(G)
    end
    for u=1:n
        for v=1:n
            if rand() < p
                add!(G,u,v)
            end
        end
    end
    return G
end

# Create a random tournament (no loops!)

"""
`RandomTournament(n)` creates a random tournament with vertex set
`1:n`.  This is equivalent to randomly assigning a direction to every
edge of a simple complete graph.
"""
function RandomTournament(n::Int)
    G = IntDigraph()
    for u=1:n-1
        for v=u+1:n
            if rand() < 0.5
                add!(G,u,v)
            else
                add!(G,v,u)
            end
        end
    end
    return G
end



"""
`all_tuples(alphabet, n)` creates an iterator that produces all
length-`n` tuples of distinct elements in `alphabet`.
"""
function all_tuples(alphabet, n::Int)
    elts = collect(distinct(alphabet))
    src  = [ elts for _=1:n ]
    its  = Base.Iterators.product(src...)
    return its
end


export ShiftDigraph

"""
`ShiftDigraph(alphabet,n)` creates a `SimpleDigraph` whose vertices
are all length-`n` tuples of the elements in `alphabet` (which can be
an array such as `[0,1]` or a string such as `"abc"`). An edge from
`u` to `v` corresponds to an element dropped from the first position
in `u` and another element added to the end yielding `v`. For example,
in `ShiftDigraph([0,1],5)` there are two edges leaving vertex
`(0,1,0,1,1)`; one goes to `(1,0,1,1,0)` and the other to
`(1,0,1,1,1)`.
"""
function ShiftDigraph(alphabet=[0,1], n::Int=3)
    elts = collect(distinct(alphabet))
    vertex_iter = all_tuples(alphabet, n)
    vlist = collect(vertex_iter)
    T = typeof(vlist[1])
    G = SimpleDigraph{T}()
    for v in vlist
        add!(G,v)
    end

    # create edges here

    for v in vlist
        head = collect(IterTools.drop(v,1))
        for c in elts
            w = tuple([head;c]...)
            add!(G,v,w)
        end
    end

    return G

end

"""
function for creating a Torus Graph
"""
function TorusDigraph(n::Int=4, m::Int=3)

  G = SimpleDigraph();

  #create vertices
  vlist = Tuple{Int,Int}[]
  for i = 1:m
    for j = 1:n
      push!(vlist,(i,j))
    end
  end

  #create edges
  for v in vlist
    if v[1] + 1 <= m
      w = (v[1]+1,v[2])
      add!(G,v,w)
    end
    if v[2] + 1 <= n
      w = (v[1],v[2]+1)
      add!(G,v,w)
    elseif v[1] == m
      w = (1,v[2])
      add!(G,v,w)
    elseif v[2] == n
      w = (v[1],1)
      add!(G,v,w)
    end
  end

  return G
end
