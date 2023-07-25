# using Revise
using Test
using QuadMeshGame
include("useful_routines.jl")
QM = QuadMeshGame

p = [0. 0. 0. -1. 1 0
     0. 1. 2. 2.  2  3]
t = [1 2 3 4
     1 5 3 2
     4 3 5 6]
mesh = QM.QuadMesh(p, Array(t'))

@test !QM.is_valid_left_flip(mesh, 1, 3, 7)