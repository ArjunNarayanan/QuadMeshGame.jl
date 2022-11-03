# QuadMeshGame

[![Build Status](https://github.com/ArjunNarayanan/QuadMeshGame.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/ArjunNarayanan/QuadMeshGame.jl/actions/workflows/CI.yml?query=branch%3Amain)

This package implements connectivity editing operations on Quad Meshes. A Quad Mesh is a 2D mesh where all the elements are quadrilaterals. You can use the [PlotQuadMesh.jl](https://github.com/ArjunNarayanan/PlotQuadMesh.jl) package for visualization.

## Example Usage

A Quad Mesh can be defined by providing the coordinates of the vertices and the connectivity of each quad element. As an example, let's create a `2x2` mesh:

```
using Revise
using QuadMeshGame
using PlotQuadMesh
QM = QuadMeshGame
PQ = PlotQuadMesh

vertices = [0.0 0.0 0.0 0.5 0.5 0.5 1.0 1.0 1.0
    0.0 0.5 1.0 0.0 0.5 1.0 0.0 0.5 1.0]
connectivity = [1 2 4 5
    4 5 7 8
    5 6 8 9
    2 3 5 6]
mesh = QM.QuadMesh(vertices, connectivity)
```

`vertices` is expected to be a `2 x num_vertices` matrix of vertex coordinates. `connectivity` is expected to be a `4 x num_quads` matrix of integers representing the connectivity of each quad (one quad per column). The vertices are assumed to be in counter-clockwise order. Note that this can be used to locally order the edges of each quad.

The `QuadMesh` object is dynamic -- the number of vertices and quads can change based on the editing operations (described later). Hence, we allocate a larger buffer to store the vertex coordinates and connectivity matrices and keep track of __active vertices__ and __active quads__. While visualizing, we should supply only the active vertices and quads to the plotter. 

The edges of each quad can be considered to be ordered. For example 

We can do this as follows:

```
PQ.plot_mesh(QM.active_vertex_coordinates(mesh), QM.active_quad_connectivity(mesh), 
node_numbers=true, elem_numbers=true, internal_order=true)
```

<img src="examples/figures/2x2mesh.png" alt="drawing" width="600"/>

The red numbers in the above figure refers to the local numbering of vertices in each quad. We use this to locally index the edges in each quad. For example `quad 2, edge 2` refers to the edge from vertex 5 to vertex 6 in the above figure.

The `QuadMesh` object contains some useful information. You can look at the connectivity between quads. This tells you the index of your neighboring quad across a particular local edge. 

```
julia> q2q = QM.active_quad_q2q(mesh)
4×4 Matrix{Int64}:
 0  1  0  3
 3  4  0  0
 2  0  4  0
 0  0  1  2
```

`q2q[3,1] = 2` says that the index of the quad neighboring quad 1 across local edge 3 is 2. A value of zero indicates a boundary.

You can obtain the local edge of your neighbor as follows:

```
julia> e2e = QM.active_quad_e2e(mesh)
4×4 Matrix{Int64}:
 0  3  0  3
 4  4  0  0
 1  0  1  0
 0  0  2  2
```

How do we interpret `e2e[1,4] = 3`? Note that quad 4 has as neighbor quad 3 across local edge 1. Note also that quad 3 has quad 4 as neighbor across local edge 3. This is what the `e2e` matrix stores. In particular,

```
q2q[e2e[e, q], q2q[e, q]] == q
```

`q2q` and `e2e` is a representation of the [Half-edge datastructure](https://cs184.eecs.berkeley.edu/sp19/article/15/the-half-edge-data-structure) which is an effective datastructure to store and manipulate the topology of meshes.