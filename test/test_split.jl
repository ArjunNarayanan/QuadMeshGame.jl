# using Revise
using Test
using QuadMeshGame
include("useful_routines.jl")
QM = QuadMeshGame


maxdegree = 7
mesh = QM.square_mesh(2)
@test !QM.is_valid_split(mesh, 1, 1, maxdegree)
@test QM.is_valid_split(mesh, 1, 2, maxdegree)
@test QM.is_valid_split(mesh, 1, 3, maxdegree)

mesh.degree[5] = 2
@test !QM.is_valid_split(mesh, 1, 3, maxdegree)
@test QM.is_valid_split(mesh, 3, 3, maxdegree)
@test !QM.is_valid_split(mesh, 3, 3, 2)

mesh = QM.square_mesh(2)
@test QM.is_valid_split(mesh, 4, 1, 7)
mesh.degree[6] = 7
@test !QM.is_valid_split(mesh, 4, 1, 7)

mesh = QM.square_mesh(2)
@test QM.split!(mesh, 1, 3)
@test QM.number_of_quads(mesh) == 5
@test QM.number_of_vertices(mesh) == 10
@test all(mesh.active_quad[1:5])

testvertices = [
    0.0 0.0 0.0 0.5 0.5 0.5 1.0 1.0 1.0 0.25
    0.0 0.5 1.0 0.0 0.5 1.0 0.0 0.5 1.0 0.5
]
@test allequal(mesh.vertices[:, 1:10], testvertices)
testconn = [
    1  2  4 5 10
    4  10 7 8 4
    10 6  8 9 5
    2  3  5 6 6
]
@test allequal(mesh.connectivity[:,1:5], testconn)

test_e2e = [
    0 3 0 3 2
    1 4 0 0 4
    1 0 1 0 4
    0 0 2 3 2
]
@test allequal(mesh.e2e[:,1:5], test_e2e)

test_q2q = [
    0 1 0 3 1
    5 5 0 0 3
    2 0 4 0 4
    0 0 5 5 2
]
@test allequal(test_q2q, mesh.q2q[:,1:5])

test_degree = [2,3,2,4,3,4,2,3,2,3]
@test allequal(test_degree, QM.active_vertex_degrees(mesh))


mesh = QM.square_mesh(2)
@test QM.split!(mesh, 4, 1)

@test QM.number_of_quads(mesh) == 5
@test QM.number_of_vertices(mesh) == 10
@test all(mesh.active_quad[1:5])

testvertices = [
    0.0 0.0 0.0 0.5 0.5 0.5 1.0 1.0 1.0 0.75
    0.0 0.5 1.0 0.0 0.5 1.0 0.0 0.5 1.0 0.5
]
@test allequal(mesh.vertices[:, 1:10], testvertices)

test_degree = [2,3,2,4,3,4,2,3,2,3]
@test allequal(QM.active_vertex_degrees(mesh), test_degree)

testconn = [
    1  2  4  10 10
    4  5  7  8  6
    5  6  8  9  5
    2  3  10 6  4
]
@test allequal(mesh.connectivity[:,1:5], testconn)

test_e2e = [
    0 3 0 3 4
    3 2 0 0 2
    1 0 1 0 2
    0 0 4 1 4
]
@test allequal(mesh.e2e[:,1:5], test_e2e)

test_q2q = [
    0 1 0 3 4
    5 5 0 0 2
    2 0 4 0 1
    0 0 5 5 3
]
@test allequal(test_q2q, mesh.q2q[:,1:5])


mesh = QM.square_mesh(2)
@test QM.split!(mesh, 2, 2)

@test QM.number_of_quads(mesh) == 5
@test QM.number_of_vertices(mesh) == 10
@test all(mesh.active_quad[1:5])

test_degree = [2,4,2,3,3,3,2,4,2,3]
@test allequal(QM.active_vertex_degrees(mesh), test_degree)

testvertices = [
    0.0 0.0 0.0 0.5 0.5 0.5 1.0 1.0 1.0 0.5
    0.0 0.5 1.0 0.0 0.5 1.0 0.0 0.5 1.0 0.75
]
@test allequal(mesh.vertices[:, 1:10], testvertices)
testconn = [
    1  2   4  10 10
    4  10  7  8  2
    5  6   8  9  5
    2  3   5  6  8
]
@test allequal(mesh.connectivity[:,1:5], testconn)

test_e2e = [
    0 1 0 4 1
    4 4 0 0 3
    2 0 3 0 3
    0 0 2 2 1
]
@test allequal(mesh.e2e[:,1:5], test_e2e)

test_q2q = [
    0 5 0 5 2
    3 4 0 0 1
    5 0 5 0 3
    0 0 1 2 4
]
@test allequal(test_q2q, mesh.q2q[:,1:5])
