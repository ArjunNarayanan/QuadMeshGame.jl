using Revise
using Test
using QuadMeshGame
include("useful_routines.jl")
QM = QuadMeshGame

mesh = QM.square_mesh(2)

@test QM.is_valid_global_split(mesh, 2, 1, 7)
tracker = QM.Tracker()
new_quad_idx = QM.insert_initial_quad_for_global_split!(mesh, 2, 1, tracker)
@test new_quad_idx == 5
@test QM.number_of_vertices(mesh) == 11
@test QM.number_of_quads(mesh) == 5

test_conn = [1 4 11 2
             2 10 6 3
             4 7 8 5
             5 8 9 6
             10 2 11 5]
@test allequal(QM.active_quad_connectivity(mesh), test_conn')
test_q2q = [0 3 5 0
            5 4 0 0
            0 0 4 1
            3 0 0 2
            2 1 0 0]
@test allequal(QM.active_quad_q2q(mesh), test_q2q')
test_e2e = [0 4 2 0
            1 4 0 0
            0 0 1 2
            3 0 0 2
            1 3 0 0]
@test allequal(QM.active_quad_e2e(mesh), test_e2e')
@test allequal(tracker.new_vertex_ids, [10, 11])
@test allequal(tracker.on_boundary, [false, false])