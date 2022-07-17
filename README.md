


#  SimpleGraphs


## Release notes for version 0.8

We have made the following (breaking) changes:
+ `SimpleGraph` has been renamed `UndirectedGraph`.
+ `SimpleDigraph` has been renamed `DirectedGraph`.
+ `SimpleHypergraph` has been renamed `HyperGraph` (note the captial G).

These may be abbreviated as `UG`, `DG`, and `HG`, respectively 

These changes were made to help this `SimpleGraphs` module be interoperable with Julia's [`Graphs`](https://github.com/JuliaGraphs/Graphs.jl) module that defines the type `SimpleGraph` (formerly `Graph` in the `LightGraphs` module). 

Conversion between these two types (`UndirectedGraph` in this module and `SimpleGraph` in the `Graphs` module) is supported; see the file `graph_converter.jl` in the `extras` directory.

---

## Overview


This module defines three data types for working with graphs:

+ The `UndirectedGraph` type represents *undirected* graphs without loops
  or multiple edges.
+ The `DirectedGraph` type represents *directed* graphs in which there
  may be at most one directed edge `(u,v)` from a vertex `u` to a
  vertex `v`. There may also be a directed edge in the opposite
  direction, `(v,u)`.
+ The `HyperGraph` type representing *hypergraphs* in which
  edges may be any subset of the vertex set.



Additional functionality can be found in these modules:
+ [`DrawSimpleGraphs`](https://github.com/scheinerman/DrawSimpleGraphs.jl) for visualization.
+ [`SimpleGraphAlgorithms`](https://github.com/scheinerman/SimpleGraphAlgorithms.jl) 
for functions relying on [integer] linear programming.

### Not ready for prime time
In addition, we have:
+ A nascent [`SimplePlanarGraphs`](https://github.com/scheinerman/SimplePlanarGraphs.jl) module with *extremely* limited functionality.
+ An older [`SimpleGraphRepresentations`](https://github.com/scheinerman/SimpleGraphRepresentations.jl) module that I am not currently maintaining.

## User's Guide

Please see the [Wiki](https://github.com/scheinerman/SimpleGraphs.jl/wiki) for
extensive information pertaining to the `UndirectedGraph` type.

The `DirectedGraph` type is not so well developed nor documented. See the
source files in the `src` directory. Likewise, documentation and support for the `HyperGraph` type is limited.

## A Few Extras

The `extras` directory contains some additional functionality that may be 
useful. See the `README` file therein.


## Postcardware

This software is part of a larger suite of tools for graph theory. More information
can be found right after my explanation that this code is 
[postcardware](https://github.com/scheinerman/scheinerman#postcardware).


## Thanks

Thank you to [JHU](https://www.jhu.edu/) students Tara Abrishami and Laura Bao for contributions to this project.



## Please Help

This is a work in process with a lot of more features that
can/should be added. If you're interested in contributing, please
contact me. I'm especially interested in JHU undergraduates getting
involved.



Ed Scheinerman (ers@jhu.edu)
