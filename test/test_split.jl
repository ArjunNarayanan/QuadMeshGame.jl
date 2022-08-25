using Revise
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