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
    2  4 1
    1  7 8
    6  8 9
    3  1 6
]
active_conn = QM.active_quad_connectivity(mesh)
@test allequal(active_conn, testconn)

test_q2q = [0 0 3
            4 0 0
            0 4 0
            0 0 2]
active_q2q = QM.active_quad_q2q(mesh)
@test allequal(test_q2q, active_q2q)

test_e2e = [0 0 3
            4 0 0
            0 1 0
            0 0 2]
active_e2e = QM.active_quad_e2e(mesh)
@test allequal(active_e2e, test_e2e)

test_degree = [4,2,2,2,3,2,3,2]
active_vertex_degrees = QM.active_vertex_degrees(mesh)
@test allequal(test_degree, active_vertex_degrees)

test_on_boundary = trues(8)
@test allequal(mesh.vertex_on_boundary[mesh.active_vertex], test_on_boundary)
