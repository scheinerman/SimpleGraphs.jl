using LightXML

export graffle

function bounds(G::UndirectedGraph)
    ensure_embed(G)
    xmin = Inf
    ymin = Inf
    xmax = -Inf
    ymax = -Inf

    xy = getxy(G)
    for pt in values(xy)
        x, y = pt[1], pt[2]
        if x < xmin
            xmin = x
        end

        if x > xmax
            xmax = x
        end

        if y < ymin
            ymin = y
        end

        if y > ymax
            ymax = y
        end

    end

    return (xmin, xmax, ymin, ymax)
end

function make_scaler(G::UndirectedGraph)
    (xmin, xmax, ymin, ymax) = bounds(G)

    f(x, y) = (round(Int, 72 * (x - xmin + 0.5)), round(Int, 72 * (ymax - y + 0.5)))

    return f
end



function add_key!(dict_node::XMLElement, key::AbstractString)
    x = new_child(dict_node, "key")
    add_text(x, key)
end

function add_value!(dict_node::XMLElement, val_type::AbstractString, val::AbstractString)
    x = new_child(dict_node, val_type)
    add_text(x, val)
end


function add_key_value!(
    dict_node::XMLElement,
    key::AbstractString,
    val_type::AbstractString,
    val::AbstractString,
)
    add_key!(dict_node, key)
    add_value!(dict_node, val_type, val)
end

function add_dict!(node::XMLElement, key::AbstractString)
    add_key!(node, key)
    x = new_child(node, "dict")
    return x
end




"""
`graffle(G::SimpleGraph, filename="julia.graffle",rad=9)` creates
an OmniGraffle document of this drawing.

* `G` is the graph
* `filename` is the name of the OmniGraffle document (be sure to end with `.graffle`)
* `rad` is the radius of the circles representing the vertices
"""
function graffle(G::UndirectedGraph, filename = "julia.graffle", rad::Int = 9)

    # X = get_embedding_direct(G)

    # minimal header
    xdoc = XMLDocument()

    xtop = create_root(xdoc, "plist")
    outer = new_child(xtop, "dict")

    add_key_value!(outer, "GraphDocumentVersion", "integer", "12")
    add_key!(outer, "AutoAdjust")
    new_child(outer, "true")

    add_key!(outer, "GraphicsList")

    glist = new_child(outer, "array")

    #return xdoc

    # vertices and edges are <dict> children of "glist"

    VV = vlist(G)
    n = NV(G)

    lookup = Dict{Any,Int}(zip(VV, 1:n))

    xy = getxy(G)

    f = make_scaler(G)

    for v in VV
        k = lookup[v]
        vtx = new_child(glist, "dict")

        # Location
        pt = xy[v]
        x, y = f(pt[1], pt[2])
        location = "{{$x,$y},{$(rad),$(rad)}}"
        add_key_value!(vtx, "Bounds", "string", location)

        # Class
        add_key_value!(vtx, "Class", "string", "ShapedGraphic")

        # ID
        add_key_value!(vtx, "ID", "integer", string(k))

        # Layer
        add_key_value!(vtx, "Layer", "integer", "0")

        # Shape
        add_key_value!(vtx, "Shape", "string", "Circle")

        # Style
        a = add_dict!(vtx, "Style")
        b = add_dict!(a, "shadow")
        add_key_value!(b, "Draws", "string", "NO")
    end


    EE = elist(G)
    id = n

    for e in EE
        a = lookup[e[1]]
        b = lookup[e[2]]
        id += 1

        edge = new_child(glist, "dict")

        # Class
        add_key_value!(edge, "Class", "string", "LineGraphic")

        # ID
        add_key_value!(edge, "ID", "integer", string(id))

        # Layer
        add_key_value!(edge, "Layer", "integer", string(1))

        # Head
        h = add_dict!(edge, "Head")
        add_key_value!(h, "ID", "integer", string(a))

        # Tail
        t = add_dict!(edge, "Tail")
        add_key_value!(t, "ID", "integer", string(b))


        # Style
        a = add_dict!(edge, "Style")
        b = add_dict!(a, "shadow")
        add_key_value!(b, "Draws", "string", "NO")


    end


    save_file(xdoc, filename)

    return filename
end
