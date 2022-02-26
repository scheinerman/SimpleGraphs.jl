


#  SimpleGraphs


## Release Notes

+ Version 0.7.0 reworks graph embedding. One new feature is that vertices do not have to all be colored the same (as was the case in previous versions).
+ Version 0.6.0 introduces *rotation systems* which are combinatorial representations of embeddings on oriented surfaces.
+ As of version 0.5.2 the function `vertex_type` is deprecated. Use 
`eltype` instead. 
+ As of version 0.5.0 the polynomials returned by functions such as
`char_poly` are of type [`SimplePolynomial`](https://github.com/scheinerman/SimplePolynomials.jl).
---

## Overview


This module defines three data types for working with graphs:

+ The `SimpleGraph` type represents *undirected* graphs without loops
  or multiple edges.
+ The `SimpleDigraph` type represents *directed* graphs in which there
  may be at most one directed edge `(u,v)` from a vertex `u` to a
  vertex `v`. There may also be a directed edge in the opposite
  direction, `(v,u)`.
+ The `SimpleHypergraph` type representing *hypergraphs* in which
  edges may be any subset of the vertex set.


Additional functionality can be found in these modules:
+ [`DrawSimpleGraphs`](https://github.com/scheinerman/DrawSimpleGraphs.jl) for visualization.
+ [`SimpleGraphAlgorithms`](https://github.com/scheinerman/SimpleGraphAlgorithms.jl) 
for functions relying on [integer] linear programming.

#### Not ready for prime time
In addition, we have:
+ A nascent [`SimplePlanarGraphs`](https://github.com/scheinerman/SimplePlanarGraphs.jl) module with *extremely* limited functionality.
+ An older [`SimpleGraphRepresentations`](https://github.com/scheinerman/SimpleGraphRepresentations.jl) module that I am not currently maintaining.

## User's Guide

Please see the [Wiki](https://github.com/scheinerman/SimpleGraphs.jl/wiki) for
extensive information pertaining to the `SimpleGraph` type.

The `SimpleDigraph` type is not so well developed nor documented. See the
source files in the `src` directory. Likewise, the `SimpleHypergraph`
type is in early stages of development.

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
