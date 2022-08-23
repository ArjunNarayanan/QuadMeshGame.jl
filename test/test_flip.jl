using Revise
using Test
using QuadMeshGame
include("useful_routines.jl")
QM = QuadMeshGame


next = QM.next.(1:4)
@test allequal(next, [2,3,4,1])
prev = QM.previous.(1:4)
@test allequal(prev, [4,1,2,3])

mesh = QM.square_mesh(2)

@test !QM.is_valid_left_flip(mesh, 1, 1)
@test QM.is_valid_left_flip(mesh, 1, 2)
@test QM.is_valid_left_flip(mesh, 1, 3)
@test !QM.is_valid_left_flip(mesh, 1, 4)

@test QM.is_valid_left_flip(mesh, 2, 1)
@test QM.is_valid_left_flip(mesh, 2, 2)
@test !QM.is_valid_left_flip(mesh, 2, 3)
@test !QM.is_valid_left_flip(mesh, 2, 4)

@test !QM.is_valid_left_flip(mesh, 3, 1)
@test !QM.is_valid_left_flip(mesh, 3, 2)
@test QM.is_valid_left_flip(mesh, 3, 3)
@test QM.is_valid_left_flip(mesh, 3, 4)

@test QM.is_valid_left_flip(mesh, 4, 1)
@test !QM.is_valid_left_flip(mesh, 4, 2)
@test !QM.is_valid_left_flip(mesh, 4, 3)
@test QM.is_valid_left_flip(mesh, 4, 4)

@test !QM.is_valid_right_flip(mesh, 1, 1)
@test QM.is_valid_right_flip(mesh, 1, 2)
@test QM.is_valid_right_flip(mesh, 1, 3)
@test !QM.is_valid_right_flip(mesh, 1, 4)

@test QM.is_valid_right_flip(mesh, 2, 1)
@test QM.is_valid_right_flip(mesh, 2, 2)
@test !QM.is_valid_right_flip(mesh, 2, 3)
@test !QM.is_valid_right_flip(mesh, 2, 4)

@test !QM.is_valid_right_flip(mesh, 3, 1)
@test !QM.is_valid_right_flip(mesh, 3, 2)
@test QM.is_valid_right_flip(mesh, 3, 3)
@test QM.is_valid_right_flip(mesh, 3, 4)

@test QM.is_valid_right_flip(mesh, 4, 1)
@test !QM.is_valid_right_flip(mesh, 4, 2)
@test !QM.is_valid_right_flip(mesh, 4, 3)
@test QM.is_valid_right_flip(mesh, 4, 4)


mesh.degree[8] = 7
@test !QM.is_valid_left_flip(mesh, 4, 4, maxdegree=7)
@test !QM.is_valid_right_flip(mesh, 3, 4, maxdegree=7)
@test !QM.is_valid_right_flip(mesh, 1, 2, maxdegree=7)