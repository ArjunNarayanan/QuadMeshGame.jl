using Revise
using QuadMeshGame
include("useful_routines.jl")
QM = QuadMeshGame


next = QM.next.(1:4)
@test allequal(next, [2,3,4,1])
prev = QM.previous.(1:4)
@test allequal(prev, [4,1,2,3])

