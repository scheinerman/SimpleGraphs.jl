export geogebra

"""
`geogebra(G,file_name)` takes a `SimpleGraph` and writes out a
script to produce a drawing of this graph in GeoGebra.

Here is the secret sauce to make this work.

* Run `geogebra(G,file_name)` to save the script to `file_name`. By
  default, the file name is `geogebra.txt`.
* Copy the contents of `file_name` to the clipboard.
* Create a new GeoGebra document.
* In the **Input** zone at the bottom, enter `Button[]` to create a new
  button.
* Right click the button and select the **Object Properties...** menu option.
* Go to the **Scripting** tab and paste in the copied commands.
* Save and close the properties window.
* Press the newly created button.

Some properties of the vertices can be specified in this function with
named parameters as follows:

* `vertex_labels`: If set to `true`, the vertices in the drawing have
  labels. Default is `false` (no labels drawn). Note that the color of
  the labels matches the color of the vertices, so if you set the
  color to `white` the labels will be invisible.
* `vertex_color`: Use this to specify the fill color of the
  vertices. The default is `"black"`.
* `vertex_colors`: This is a dictionary mapping vertices to color
  names. Vertices are given the color specified. If, however, a vertex
  is missing from this dictionary, then `vertex_color` is used
  instead.
* `vertex_size`: Use this to specify the radius of the vertices. The
  default is `3`.
"""
function geogebra(
    G::SimpleGraph,
    file_name::String = "geogebra.txt";
    vertex_labels::Bool = false,
    vertex_color::String = "black",
    vertex_colors::Dict = Dict(),
    vertex_size::Int = 3,
)
    X = get_embedding_direct(G)
    VV = vlist(X.G)
    n = NV(X.G)
    F = open(file_name, "w")

    for i = 1:n
        v = VV[i]
        vname = string(v)
        (x, y) = X.xy[v]
        x = round(x, 3)
        y = round(y, 3)
        println(F, "v_{$i} = CopyFreeObject[Point[{$x,$y}]]")
        println(F, "SetPointSize[v_{$i}, $(string(vertex_size))]")

        color = ""
        try
            color = vertex_colors[v]
        catch
            color = vertex_color
        end
        println(F, "SetColor[v_{$i}, \"$color\"]")


        println(F, "SetCaption[v_{$i}, \"$vname\"]")
        println(F, "ShowLabel[v_{$i}, $(string(vertex_labels))]")
    end

    for i = 1:n-1
        u = VV[i]
        for j = i+1:n
            v = VV[j]
            if has(X.G, u, v)
                println(F, "e_{$i,$j} = Segment[v_{$i},v_{$j}]")
                println(F, "ShowLabel[e_{$i,$j}, false]")
            end
        end
    end
    println(F, "ShowAxes[false]")
    println(F, "ShowGrid[false]")
    println(F, "Execute[{\"Delete[button1]\"}]")
    close(F)
end
