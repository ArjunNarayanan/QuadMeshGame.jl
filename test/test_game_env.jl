# using Revise
using Test
using QuadMeshGame
include("useful_routines.jl")

QM = QuadMeshGame


@test QM.enclosed_angle([1,0],[0,1]) == 90
@test QM.enclosed_angle([0,1],[-1,-1]) == 135
@test QM.enclosed_angle([1,1],[1,-1]) == 270
@test QM.enclosed_angle([1,0],[1,-eps()]) == 360

@test all(QM.desired_degree.(0:120) .== 2)
@test all(QM.desired_degree.(121:216) .== 3)
@test all(QM.desired_degree.(217:308) .== 4)
@test all(QM.desired_degree.(309:360) .== 5)

mesh = QM.square_mesh(2)
d0 = copy(mesh.degree)
@test QM.left_flip!(mesh, 1, 2)
env = QM.GameEnv(mesh, d0, 10)

@test env.num_actions == 0
@test env.max_actions == 10
@test allequal(d0, env.d0)

test_vs = [0,1,0,-1,-1,0,1,0,0]
@test allequal(QM.active_vertex_scores(env), test_vs)
@test env.current_score == 4
@test env.opt_score == 0
@test env.initial_score == 4
@test env.reward == 0
@test !env.is_terminated


mesh = QM.square_mesh(2, quad_buffer=4, vertex_buffer=9)
pairs = QM.make_edge_pairs(mesh)
test_pairs = [17,12,5,17,3,16,17,17,17,17,13,2,11,17,17,6]
@test allequal(pairs, test_pairs)

@test QM.left_flip!(mesh, 2, 2)
pairs = QM.make_edge_pairs(mesh)
test_pairs = [17,12,8,17,11,16,17,3,17,17,5,2,17,17,17,6]
@test allequal(pairs, test_pairs)

mesh = QM.square_mesh(2, quad_buffer = 4, vertex_buffer=9)
x = reshape(mesh.connectivity, 1, :)
cx = QM.cycle_edges(x)

test_cx1 = [1 4 5 2
            4 5 2 1
            5 2 1 4
            2 1 4 5]
test_cx2 = [2 5 6 3
            5 6 3 2
            6 3 2 5
            3 2 5 6]
test_cx3 = [4 7 8 5
            7 8 5 4
            8 5 4 7
            5 4 7 8]
test_cx4 = [5 8 9 6
            8 9 6 5
            9 6 5 8
            6 5 8 9]
test_cx = cat(test_cx1, test_cx2, test_cx3, test_cx4, dims=2)
@test allequal(cx, test_cx)


mesh = QM.square_mesh(3, vertex_buffer=16, quad_buffer=9)
template = QM.make_template(mesh)


# p = QM.make_edge_pairs(mesh)
# x = reshape(mesh.connectivity, 1, :)

# cx = QM.cycle_edges(x)

# cp = QM.zero_pad(cx)[:,p][3:end,:]

# ccp = QM.cycle_edges(cp)

# ccpp = QM.zero_pad(ccp)[:,p][3:end,:]

# state = vcat(cx,ccp,ccpp)