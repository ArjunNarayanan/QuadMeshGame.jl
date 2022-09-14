# using Revise
using Test
using QuadMeshGame
include("useful_routines.jl")
QM = QuadMeshGame


maxdegree = 7
mesh = QM.square_mesh(2)
@test QM.is_valid_collapse(mesh, 1, 1, 7)
@test !QM.is_valid_collapse(mesh, 1, 2, 7)
@test QM.is_valid_collapse(mesh, 1, 3, 7)
@test !QM.is_valid_collapse(mesh, 1, 4, 7)
@test !QM.is_valid_collapse(mesh, 1, 3, 4)

@test !QM.is_valid_collapse(mesh, 2, 1, 7)
@test QM.is_valid_collapse(mesh, 2, 2, 7)
@test !QM.is_valid_collapse(mesh, 2, 3, 7)
@test QM.is_valid_collapse(mesh, 2, 4, 7)

@test QM.split!(mesh, 1, 3)
@test QM.is_valid_collapse(mesh, 5, 1, 7)
@test !QM.is_valid_collapse(mesh, 5, 2, 7)
@test QM.is_valid_collapse(mesh, 5, 3, 7)
@test !QM.is_valid_collapse(mesh, 5, 4, 7)

mesh = QM.square_mesh(2)
@test QM.collapse!(mesh, 1, 1)
@test QM.number_of_quads(mesh) == 3
@test QM.number_of_vertices(mesh) == 8

test_active_vertex = trues(9)
test_active_vertex[5] = false
@test allequal(mesh.active_vertex[1:9], test_active_vertex)

test_active_quad = trues(4)
test_active_quad[1] = false
@test allequal(mesh.active_quad[1:4], test_active_quad)

testvertices = [
    0.0 0.0 0.0 0.5 0.5 1.0 1.0 1.0
    0.0 0.5 1.0 0.0 1.0 0.0 0.5 1.0
]
@test allequal(QM.active_vertex_coordinates(mesh), testvertices)

testconn = [
    2  1 1
    1  4 8
    6  7 9
    3  8 6
]
active_conn = QM.active_quad_connectivity(mesh)