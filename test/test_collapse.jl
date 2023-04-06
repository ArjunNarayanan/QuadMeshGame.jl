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


########################################################################################
# DISABLED COLLAPSE FOR QUADS ON BOUNDARY

mesh = QM.square_mesh(2)
@test QM.collapse!(mesh, 1, 1)
@test QM.number_of_quads(mesh) == 3
@test QM.number_of_vertices(mesh) == 8

test_active_vertex = trues(9)
test_active_vertex[5] = false
@test allequal(mesh.active_vertex[1:9], test_active_vertex)
@test count(mesh.active_vertex) == 8

test_active_quad = trues(4)
test_active_quad[1] = false
@test allequal(mesh.active_quad[1:4], test_active_quad)
@test count(mesh.active_quad) == 3

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

########################################################################################
mesh = QM.square_mesh(2)
@test QM.split!(mesh, 1, 3)
@test QM.collapse!(mesh, 5, 1, 7)
@test QM.number_of_quads(mesh) == 4
@test QM.number_of_vertices(mesh) == 9

test_active_vertex = trues(10)
test_active_vertex[5] = false
@test allequal(test_active_vertex, mesh.active_vertex[1:10])
@test count(mesh.active_vertex) == 9

test_active_quad = trues(4)
@test allequal(mesh.active_quad[1:4], test_active_quad)
@test count(mesh.active_quad) == 4

testvertices = testvertices = [
    0.0 0.0 0.0 0.5 0.5 1.0 1.0 1.0 0.375
    0.0 0.5 1.0 0.0 1.0 0.0 0.5 1.0 0.5
]
@test allequal(testvertices, QM.active_vertex_coordinates(mesh))

testconn = [1  2  4  10
            4  10 7  8
            10  6 8  9
            2   3 10 6]
@test allequal(testconn, QM.active_quad_connectivity(mesh))

test_q2q = [0 1 0 3
            3 4 0 0
            2 0 4 0
            0 0 1 2]
@test allequal(test_q2q, QM.active_quad_q2q(mesh))

test_e2e = [0 3 0 3
            4 4 0 0
            1 0 1 0
            0 0 2 2]
@test allequal(test_e2e, QM.active_quad_e2e(mesh))

test_degree = [2,3,2,3,3,2,3,2,4]
@test allequal(test_degree, QM.active_vertex_degrees(mesh))


vertices = rand(2,8)
connectivity = [1  2  8  8
                2  3  3  5
                7  8  4  6
                8  7  5  1]
q2q = [0  0  2  3
       2  3  0  0
       2  1  0  0
       4  1  4  1]
e2e = transpose([0 4 3 4
       0 1 3 2
       2 0 0 1
       4 0 0 4])
degree = [3 3 3 2 3 2 2 4]
mesh = QM.QuadMesh(vertices, connectivity, q2q, e2e)

@test !QM.is_valid_collapse(mesh, 1, 4, 7)
QM.collapse!(mesh, 1, 4)
########################################################################################



########################################################################################
mesh = QM.square_mesh(2)
@test QM.collapse!(mesh, 1, 3)

@test QM.number_of_quads(mesh) == 3
@test QM.number_of_vertices(mesh) == 8

test_active_vertex = trues(9)
test_active_vertex[1] = false
@test allequal(mesh.active_vertex[1:9], test_active_vertex)
@test count(mesh.active_vertex) == 8

test_active_quad = trues(4)
test_active_quad[1] = false
@test allequal(mesh.active_quad[1:4], test_active_quad)
@test count(mesh.active_quad) == 3

testvertices = [
     0.0 0.0 0.5 0.0 0.5 1.0 1.0 1.0
     0.5 1.0 0.0 0.0 1.0 0.0 0.5 1.0
]
@test allequal(QM.active_vertex_coordinates(mesh), testvertices)

testconn = [
    2  4 5
    5  7 8
    6  8 9
    3  5 6
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


test_degree = [2,2,2,4,3,2,3,2]
active_vertex_degrees = QM.active_vertex_degrees(mesh)
@test allequal(test_degree, active_vertex_degrees)

test_on_boundary = trues(8)
@test allequal(mesh.vertex_on_boundary[mesh.active_vertex], test_on_boundary)

test_is_geometric = trues(8)
@test allequal(mesh.is_geometric_vertex[mesh.active_vertex], test_is_geometric)