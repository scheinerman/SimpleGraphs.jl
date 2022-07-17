# Extras for the `SimpleGraphs` Module

This directory will be for code that is potentially useful in graph theory work, 
but not included in the `SimpleGraphs` module.
<hr>

# Trees

## All trees

The file `tree_iterator.jl` contains code to iterate over all trees of a given size.

For example, the following code finds the degree sequence of all trees with 4 vertices:
```
julia> include("tree_iterator.jl");

julia> for T ∈ Trees(4)
       println(deg(T))
       end
[3, 1, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[3, 1, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[3, 1, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[2, 2, 1, 1]
[3, 1, 1, 1]
```
Note that there are `n^(n-2)` trees with vertex set `{1,2,...,n}` and 
the code `for T ∈ Trees(n)` will iterate over all of them. So this is
useful (perhaps) up to `n=10`.

## Distinct trees

The file `distinct_trees.jl` contains code to create a table of lists of 
trees of various sizes. The list of a given size contains all possible 
pairwise nonisomorphic trees of that size. That is, if `TT` is the table,
then `TT[n]` is a list (`Vector`) of all trees of size `n` that are not
isomorphic to each other.

There are two ways to create such a table:
+ `build_trees_table(nmax)` creates such a table of trees with vertex set size ranging from `1` up to `nmax`. If `nmax` is large, this can take a long time.
+ `load_trees_table(filename)` reads a file that contains all trees up to a certain size that has been precomputed. If `filename` is omitted, use `"tree_codes.jl"`. Note 
that the file `tree_codes.jl` included in this `extras` folder contains 
data for all trees up to 18 vertices.

Furthermore, given a table of trees `TT` up to size `n`, 
the function `extend_trees_table!(TT)` grows the table to include all trees of 
size `n+1`. 

To save a table of trees to a file (to later recall with `load_trees_table`) use 
`save_trees_table(TT, filename)`.

For example, here are the degree sequences of all distinct trees with 6 vertices:

```julia
julia> include("distinct_trees.jl");

julia> TT = build_trees_table(6);  # Information output omitted

julia> for T in TT[6]
       println(deg(T))
       end
[2, 2, 2, 2, 1, 1]
[3, 2, 2, 1, 1, 1]
[3, 3, 1, 1, 1, 1]
[4, 2, 1, 1, 1, 1]
[3, 2, 2, 1, 1, 1]
[5, 1, 1, 1, 1, 1]
```

# Unit distance graph with chromatic number 5

Aubrey de Grey created a unit distance graph with chromatic number 5. This graph can be seen using the function `deGrey` in the file `deGrey.jl`.

```julia
julia> include("deGrey.jl")
deGrey

julia> G = deGrey()
de Grey (n=1585, m=7909)

julia> diam(G)
12
```

# Converting between `SimpleGraphs` and  `Graphs` 

## ALERT: This is information is obsolete. I'll be working on fixing this soon.


Julia's [`Graphs`](https://github.com/JuliaGraphs/Graphs.jl) module defines the type `SimpleGraph`.

This [`SimpleGraphs`](https://github.com/scheinerman/SimpleGraphs.jl.git) module defines the
type `UndirectedGraph`. 

Both of these types represent simple graphs, i.e., graphs with out directions, loops, or multiple edges. 


The file `graph_converter.jl` provides a simple way to convert one type of graph to the other.

+ If `G` is an `UndirectedGraph`, then `SimpleGraph(G)` converts `G` to a `SimpleGraph`.
+ If `g` is a `SimpleGraph`, then `UndirectedGraph(g)` [or `UG(g)`] converts `g` to an `UndirectedGraph`.

```
julia> include("extras/graph_converter.jl")

julia> G = Cycle(6)
Cycle (n=6, m=6)

julia> g = SimpleGraph(G)
{6, 6} undirected simple Int64 graph

julia> H = UndirectedGraph(g)
UndirectedGraph{Int64} (n=6, m=6)

julia> G == H
true
```


## Important note concerning conversion from a `SimpleGraph` to an `UndirectedGraph`


The vertices of a `SimpleGraph` (from the `Graphs` module) is a set of integers of the form `{1,2,...,n}`. The vertex set of an `UndirectedGraph` can contain
arbitrary types. When converting from a `SimpleGraph` to an `UndirectedGraph`, the names
of the vertices are converted to consecutive integers. 

In this example, the `Petersen()` function returns the Petersen graph as an `UndirectedGraph`. The ten vertices are the two-element subsets of `{1,2,3,4,5}`.
When we convert to a `SimpleGraph`, the resulting graph has ten vertices are the integers from `1` to `10`. When we convert that `SimpleGraph` back to an `UndirectedGraph`, the 
vertices are different (integers vs. two-element sets) from the original. 

```
julia> using ShowSet

julia> G = Petersen()
Petersen (n=10, m=15)

julia> g = SimpleGraph(G)
{10, 15} undirected simple Int64 graph

julia> H = UG(g)
UndirectedGraph{Int64} (n=10, m=15)

julia> G == H  
false

julia> using SimpleGraphAlgorithms

julia> is_iso(G,H)   # lots of output deleted

true
```