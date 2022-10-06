using QuadMeshGame
using RandomQuadMesh

connectivity = [
    1 2 28 27
    2 3 29 28
    3 4 30 29
    4 5 6 30
    6 7 31 30
    7 8 9 31
    9 10 32 31
    10 11 33 32
    11 12 13 33
    13 14 34 33
    14 15 40 34
    40 16 35 34
    16 17 36 35
    17 18 19 36
    19 20 37 36
    20 21 22 37
    22 23 38 37
    23 24 39 38
    24 25 26 39
    26 27 28 39
    28 29 38 39
    29 32 35 38
    30 31 32 29
    32 33 34 35
    35 36 37 38
]
verts = rand(2,40)
connectivity = Array(connectivity')

mesh = RandomQuadMesh.Mesh(verts, connectivity)
mesh = QuadMeshGame.QuadMesh(mesh.p, mesh.t, mesh.t2t, mesh.t2n)

@assert mesh.num_vertices == 40
@assert mesh.num_quads == 25
@assert count(mesh.vertex_on_boundary) == 28
@assert count(.!mesh.vertex_on_boundary[mesh.active_vertex]) == 12

template = QM.make_template(mesh)
center = template[:,85:88]