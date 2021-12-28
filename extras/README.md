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