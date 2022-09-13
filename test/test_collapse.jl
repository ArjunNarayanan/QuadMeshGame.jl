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