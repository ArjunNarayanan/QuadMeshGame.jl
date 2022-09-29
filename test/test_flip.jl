# using Revise
using Test
using QuadMeshGame
include("useful_routines.jl")
QM = QuadMeshGame


next = QM.next.(1:4)
@test allequal(next, [2, 3, 4, 1])
prev = QM.previous.(1:4)
@test allequal(prev, [4, 1, 2, 3])

mesh = QM.square_mesh(2)

maxdegree = 7

@test !QM.is_valid_left_flip(mesh, 1, 1, maxdegree)
@test QM.is_valid_left_flip(mesh, 1, 2, maxdegree)
@test QM.is_valid_left_flip(mesh, 1, 3, maxdegree)
@test !QM.is_valid_left_flip(mesh, 1, 4, maxdegree)

@test QM.is_valid_left_flip(mesh, 2, 1, maxdegree)
@test QM.is_valid_left_flip(mesh, 2, 2, maxdegree)
@test !QM.is_valid_left_flip(mesh, 2, 3, maxdegree)
@test !QM.is_valid_left_flip(mesh, 2, 4, maxdegree)

@test !QM.is_valid_left_flip(mesh, 3, 1, maxdegree)
@test !QM.is_valid_left_flip(mesh, 3, 2, maxdegree)
@test QM.is_valid_left_flip(mesh, 3, 3, maxdegree)
@test QM.is_valid_left_flip(mesh, 3, 4, maxdegree)

@test QM.is_valid_left_flip(mesh, 4, 1, maxdegree)
@test !QM.is_valid_left_flip(mesh, 4, 2, maxdegree)
@test !QM.is_valid_left_flip(mesh, 4, 3, maxdegree)
@test QM.is_valid_left_flip(mesh, 4, 4, maxdegree)

@test !QM.is_valid_right_flip(mesh, 1, 1, maxdegree)
@test QM.is_valid_right_flip(mesh, 1, 2, maxdegree)
@test QM.is_valid_right_flip(mesh, 1, 3, maxdegree)
@test !QM.is_valid_right_flip(mesh, 1, 4, maxdegree)

@test QM.is_valid_right_flip(mesh, 2, 1, maxdegree)
@test QM.is_valid_right_flip(mesh, 2, 2, maxdegree)
@test !QM.is_valid_right_flip(mesh, 2, 3, maxdegree)
@test !QM.is_valid_right_flip(mesh, 2, 4, maxdegree)

@test !QM.is_valid_right_flip(mesh, 3, 1, maxdegree)
@test !QM.is_valid_right_flip(mesh, 3, 2, maxdegree)
@test QM.is_valid_right_flip(mesh, 3, 3, maxdegree)
@test QM.is_valid_right_flip(mesh, 3, 4, maxdegree)

@test QM.is_valid_right_flip(mesh, 4, 1, maxdegree)
@test !QM.is_valid_right_flip(mesh, 4, 2, maxdegree)
@test !QM.is_valid_right_flip(mesh, 4, 3, maxdegree)
@test QM.is_valid_right_flip(mesh, 4, 4, maxdegree)


mesh.degree[8] = 7
@test !QM.is_valid_left_flip(mesh, 4, 4, maxdegree)
@test !QM.is_valid_right_flip(mesh, 3, 4, maxdegree)
@test !QM.is_valid_right_flip(mesh, 1, 2, maxdegree)

mesh = QM.square_mesh(2)
@test QM.left_flip!(mesh, 1, 2)
test_conn = [
    4 2 7 5
    7 5 8 8
    2 6 5 9
    1 3 2 6
]
@test allequal(mesh.connectivity[:, 1:4], test_conn)
test_q2q = [
    0 3 0 3
    3 4 4 0
    0 0 2 0
    0 0 1 2
]
@test allequal(mesh.q2q[:, 1:4], test_q2q)
test_e2e = [
    0 3 0 2
    4 4 1 0
    0 0 1 0
    0 0 2 2
]
@test allequal(mesh.e2e[:, 1:4], test_e2e)
test_degrees = [2, 4, 2, 2, 3, 3, 3, 3, 2]
@test allequal(mesh.degree[1:9], test_degrees)

@test QM.left_flip!(mesh, 3, 4)
test_conn = [
    7 2 8 5
    8 5 5 8
    1 6 2 9
    4 3 1 6
]
@test allequal(mesh.connectivity[:, 1:4], test_conn)
test_q2q = [
    0 3 4 3
    3 4 2 0
    0 0 0 0
    0 0 1 2
]
@test allequal(mesh.q2q[:, 1:4], test_q2q)
test_e2e = [
    0 2 1 1
    4 4 1 0
    0 0 0 0
    0 0 2 2
]
@test allequal(mesh.e2e[:, 1:4], test_e2e)
test_degrees = [3, 3, 2, 2, 3, 3, 2, 4, 2]
@test allequal(mesh.degree[1:9], test_degrees)

@test QM.left_flip!(mesh, 1, 2)
test_conn = [
    8 2 5 5
    5 5 2 8
    4 6 1 9
    7 3 4 6
]
@test allequal(mesh.connectivity[:, 1:4], test_conn)
test_q2q = [
    4 3 2 1
    3 4 0 0
    0 0 0 0
    0 0 1 2
]
@test allequal(mesh.q2q[:, 1:4], test_q2q)
test_e2e = [
    1 1 1 1
    4 4 0 0
    0 0 0 0
    0 0 2 2
]
@test allequal(mesh.e2e[:, 1:4], test_e2e)



mesh = QM.square_mesh(2)
@test QM.right_flip!(mesh, 2, 1)
test_conn = [
    2 3 4 5
    1 4 7 8
    4 5 8 9
    3 6 5 6
]
@test allequal(mesh.connectivity[:, 1:4], test_conn)
test_q2q = [
    0 1 0 3
    0 3 0 0
    2 4 4 0
    0 0 2 2
]
@test allequal(mesh.q2q[:, 1:4], test_q2q)
test_e2e = [
    0 3 0 3
    0 4 0 0
    1 4 1 0
    0 0 2 3
]
@test allequal(mesh.e2e[:, 1:4], test_e2e)

@test QM.is_valid_right_flip(mesh, 4, 4, maxdegree)
@test QM.is_valid_left_flip(mesh, 4, 4, maxdegree)
@test QM.is_valid_right_flip(mesh, 2, 3, maxdegree)
@test QM.is_valid_left_flip(mesh, 2, 3, maxdegree)

@test QM.right_flip!(mesh, 4, 4)
@test !QM.is_valid_right_flip(mesh, 3, 3, maxdegree)
@test !QM.is_valid_left_flip(mesh, 3, 3, maxdegree)
@test !QM.is_valid_right_flip(mesh, 1, 2, maxdegree)
@test !QM.is_valid_left_flip(mesh, 1, 2, maxdegree)

mesh = QM.square_mesh(2)
@test QM.right_flip!(mesh, 3, 3)
test_conn = [
    1 2 5 6
    4 5 4 7
    5 6 7 8
    2 3 6 9
]
@test allequal(test_conn, mesh.connectivity[:, 1:4])
test_q2q = [
    0 1 1 3
    3 3 0 0
    2 0 4 0
    0 0 2 0
]
@test allequal(mesh.q2q[:, 1:4], test_q2q)
test_e2e = [
    0 3 2 3
    1 4 0 0
    1 0 1 0
    0 0 2 0
]
@test allequal(mesh.e2e[:, 1:4], test_e2e)

