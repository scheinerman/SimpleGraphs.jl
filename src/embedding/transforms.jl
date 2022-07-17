# Transformations on dictionaries of xy-coordinates

using LinearAlgebra, Statistics
export transform, scale, rotate, translate, recenter


"""
`_transform(xy,A,b)`  appliex the affine transformation 
`v |--> Av+b` to all entries in `xy`.
"""
function _transform(xy::Dict, A::Array{S,2}, b::Vector{T}) where {S<:Real,T<:Real}

    # apply the transformation x |--> Ax+b to all coordinates
    for k in keys(xy)
        xy[k] = A * xy[k] + b
    end
    nothing
end

"""
`_translate(xy,b)` adds the vector `b` to all vectors in `xy`.
"""
function _translate(xy::Dict{T,Vector{S}}, b::Vector{R}) where {T,S,R}
    A = Matrix{Float64}(I, 2, 2)
    _transform(xy, A, b)
end

"""
`_scale(xy,m)` multiplies all the vectors in `xy` by the scalar `m`.
"""
function _scale(xy::Dict{T,Vector{S}}, m) where {T,S}
    A = m * Matrix{Float64}(I, 2, 2)
    _transform(xy, A, [0, 0])
end

"""
`_rotate(xy,theta)` rotates all vectors in `xy`
by `theta`.
"""
function _rotate(xy::Dict{T,Vector{S}}, theta) where {T,S}
    A = zeros(2, 2)
    A[1, 1] = cos(theta)
    A[1, 2] = -sin(theta)
    A[2, 1] = sin(theta)
    A[2, 2] = cos(theta)
    b = [0, 0]
    _transform(xy, A, b)
end

"""
`_recenter(xy)` makes translates the points in `xy` so their 
average is `[0,0]`.
"""
function _recenter(xy::Dict{T,Vector{S}}) where {T,S}
    n = length(xy)
    if n == 0
        return
    end
    b = [0.0, 0.0]
    for v in keys(xy)
        b += xy[v]
    end
    b /= n
    _translate(xy, -b)
end


"""
`recenter(G)` translates the graph's drawing so that the center of mass
of the vertices is at the origin.
"""
function recenter(G::UndirectedGraph)
    ensure_embed(G)
    _recenter(G.cache[:xy])
end

"""
`transform(G,A,b)` applies an affine transformation to all coordinates
in the graph's drawing. Here `A` is 2-by-2 matrix and `b` is a 2-vector.
Each point `p` is mapped to `A*p+b`.
"""
function transform(G::UndirectedGraph, A::Array{S,2}, b::Vector{T}) where {S<:Real,T<:Real}
    ensure_embed(G)
    _transform(G.cache[:xy], A, b)
end
