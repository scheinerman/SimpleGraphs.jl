
function dist_matrix(G::SimpleDigraph)
  VV = vlist(G)
  n = length(VV)
  A = zeros(Int,n,n)
  for u=1:n
    d = dist(G,u)
    for v=1:n
      A[u,v]=d[v]
    end
  end
  return A
end

function diam(G::SimpleDigraph)
  A = dist_matrix(G)
  if minimum(A) < 0
    return -1
  end
  return maximum(A)
end
