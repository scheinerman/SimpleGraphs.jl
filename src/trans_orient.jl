
# This code by Tara Abrishami

export transitive_orientation

"""
`transitive_orientation(G)` finds a transitive orientation of the
simple graph `G`. The result is a `SimpleDigraph`. An error is raised
if `G` does not have a transitive orientation.
"""
function transitive_orientation(G::SimpleGraph)
  err_msg = "This graph does not have a transitive orientation"
  vertices = deepcopy(vlist(G))
  edges = deepcopy(elist(G))
  V = vertex_type(G)
  diredges = Tuple{V,V}[]
  D = SimpleDigraph{V}()
  while length(diredges) != 0 || length(edges) != 0
    if length(diredges) == 0
      e = shift!(edges)
      add!(D, e[1], e[2])
    else
      e = shift!(diredges)
    end
    v1 = e[1]
    v2 = e[2]
    vs = V[]
    append!(vs,G[v1])
    append!(vs,G[v2])
    for v in vs
      if has(G, v1, v) && !has(D, v1, v) && !has(G, v, v2)
        if has(D, v, v1)
          error(err_msg)
        end
        add!(D, v1, v)
        edg = (v1, v)
        swapedg = (v, v1)
        unshift!(diredges, edg)
        edges = filter(x -> x != edg && x != swapedg,edges)
      elseif has(G, v2, v) && !has(D, v, v2) && !has(G, v, v1)
        if has(D, v2, v)
          error(err_msg)
        end
        add!(D, v, v2)
        edg = (v, v2)
        swapedg = (v2, v)
        unshift!(diredges, edg)
        edges = filter(x -> x != edg && x != swapedg,edges)
      end
    end
  end
  if length(elist(D)) == length(elist(G))
    return D
  else
    error(err_msg)
  end
end

export num_trans_orientations

"""
`num_trans_orientations(G)` returns the number of transitive
orientations of the graph `G`.
"""
function num_trans_orientations(G2::SimpleGraph)
  if cache_check(G2,:num_trans_orientations)
    return cache_recall_fast(G2,:num_trans_orientations)
  end
  G = deepcopy(G2)
  V = vertex_type(G)
  col = Dict{Tuple{V,V}, Int}()
  try
    col = makeColorClass(G)
  catch
    return 0
  end
  multiplexes = BigInt[]
  while length(elist(G)) != 0
    makeSimplex!(G, multiplexes, col)
  end
  ans = 1
  for m in multiplexes
    ans = ans*factorial(m)
  end
  cache_save_fast(G2,:num_trans_orientations,ans)
  return ans
end

function makeSimplex!(G::SimpleGraph, multiplexes::Array, col::Dict)
  edge = elist(G)[1]
  vert1 = edge[1]
  vert2 = edge[2]
  colorSet = Set()
  T = vertex_type(G)
  simp = Set{T}()
  push!(simp, vert1)
  push!(simp, vert2)
  push!(colorSet, col[edge])
  for v in neighbors(G, vert1)
    colorSetTest = deepcopy(colorSet)
    isEdge = true
    for vo in simp
      if has(G, vo, v) && (((haskey(col, (v, vo)) && !(col[(v, vo)] in colorSetTest)) || (haskey(col, (vo,v)) &&!(col[(vo, v)] in colorSetTest))))
        if haskey(col, (v, vo))
          push!(colorSetTest, col[(v, vo)])
        else
          push!(colorSetTest, col[(vo, v)])
        end
      else
        isEdge = false
        break
      end
    end
    if isEdge == true
      push!(simp, v)
      colorSet = deepcopy(colorSetTest)
    end
  end
  unshift!(multiplexes, length(simp))
  for e in elist(G)
    if col[e] in colorSet
      delete!(G, e[1], e[2])
    end
  end
end

function makeColorClass(G1::SimpleGraph)
  err_msg = "error"
  G = deepcopy(G1)
  vertices = deepcopy(vlist(G))
  edge = deepcopy(elist(G))
  V = vertex_type(G)
  diredge = Tuple{V,V}[]
  D = SimpleDigraph{V}()
  E = SimpleGraph{V}()
  classes = SimpleGraph{V}[]
  while length(diredge) != 0 || length(edge) != 0
    if length(diredge) == 0
      if length(elist(E)) != 0
        unshift!(classes,E)
        E1 = SimpleGraph{V}()
        E = E1
      end
      e = shift!(edge)
      add!(D, e[1], e[2])
      add!(E, e[1], e[2])
    else
      e = shift!(diredge)
    end
    v1 = e[1]
    v2 = e[2]
    vs = V[]
    append!(vs,G[v1])
    append!(vs,G[v2])
    for v in vs
      if has(G, v1, v) && !has(D, v1, v) && !has(G, v, v2)
        if has(D, v, v1)
          error(err_msg)
        end
        add!(D, v1, v)
        add!(E, v1, v)
        edg = (v1, v)
        swapedg = (v, v1)
        unshift!(diredge, edg)
        edge = filter(x -> x != edg && x != swapedg,edge)
      elseif has(G, v2, v) && !has(D, v, v2) && !has(G, v, v1)
        if has(D, v2, v)
          error(err_msg)
        end
        add!(D, v, v2)
        add!(E, v, v2)
        edg = (v, v2)
        swapedg = (v2, v)
        unshift!(diredge, edg)
        edge = filter(x -> x != edg && x != swapedg,edge)
      end
    end
  end
  if length(elist(E)) != 0
    unshift!(classes,E)
  end
  col = Dict{Tuple{V,V}, Int}()
  i = 1
  for q in classes
    for x in elist(q)
      col[x] = i
    end
    i = i + 1
  end
  return col
end
