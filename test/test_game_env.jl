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
d0 = copy(mesh.degree[mesh.active_vertex])
@test QM.left_flip!(mesh, 1, 2)
env = QM.GameEnv(mesh, d0, 10)

@test env.num_actions == 0
@test env.max_actions == 10
@test allequal(d0, env.desired_degree[mesh.active_vertex])

test_vs = [0,1,0,-1,-1,0,1,0,0]
@test allequal(QM.active_vertex_scores(env), test_vs)
@test env.current_score == 4
@test env.opt_score == 0
@test env.initial_score == 4
@test env.reward == 0
@test !env.is_terminated


mesh = QM.square_mesh(2)
pairs = QM.make_edge_pairs(mesh)
nquads = QM.quad_buffer(mesh)
bdry = nquads*4 + 1
test_pairs = [0,12,5,0,3,16,0,0,0,0,13,2,11,0,0,6]
test_pairs = [test_pairs; zeros(Int, 4*nquads - length(test_pairs))]
test_pairs[test_pairs .== 0] .= bdry
@test allequal(pairs, test_pairs)

@test QM.left_flip!(mesh, 2, 2)
pairs = QM.make_edge_pairs(mesh)
test_pairs = [0,12,8,0,11,16,0,3,0,0,5,2,0,0,0,6]
test_pairs = [test_pairs; zeros(Int, 4*nquads - length(test_pairs))]
test_pairs[test_pairs .== 0] .= bdry
@test allequal(pairs, test_pairs)

mesh = QM.square_mesh(2)
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
@test allequal(cx[:,1:16], test_cx)


mesh = QM.square_mesh(3)
template = QM.make_level3_template(mesh)

test_elem_5_1 = [6,10,11,7,5,9,14,15,12,8,3,2,2,1,0,0,13,14,9,13,0,0,16,12,15,16,0,0,4,3,8,4,0,0,1,5]
test_elem_5_2 = [10,11,7,6,14,15,12,8,3,2,5,9,9,13,0,0,16,12,15,16,0,0,4,3,8,4,0,0,1,5,2,1,0,0,13,14]
test_elem_5_3 = [11,7,6,10,12,8,3,2,5,9,14,15,15,16,0,0,4,3,8,4,0,0,1,5,2,1,0,0,13,14,9,13,0,0,16,12]
test_elem_5_4 = [7,6,10,11,3,2,5,9,14,15,12,8,8,4,0,0,1,5,2,1,0,0,13,14,9,13,0,0,16,12,15,16,0,0,4,3]

@test allequal(template[:,17], test_elem_5_1)
@test allequal(template[:,18], test_elem_5_2)
@test allequal(template[:,19], test_elem_5_3)
@test allequal(template[:,20], test_elem_5_4)


mesh = QM.square_mesh(2)
env = QM.GameEnv(mesh, mesh.degree[mesh.active_vertex], 10)
QM.step_split!(env, 1, 3)

@test env.desired_degree[10] == 4


QM.step_left_flip!(env, 1, 2)
QM.step_left_flip!(env, 1, 2)
QM.step_left_flip!(env, 1, 2)

test_conn = [6 10 4 5
             2 10 6 3
             4 7 8 5
             5 8 9 6
             4 10 2 1]
@test allequal(QM.active_quad_connectivity(env.mesh), test_conn')

@test QM.is_valid_collapse(mesh, 1, 2, 7)
QM.step_collapse!(env, 1, 2)


test_desired_degree = [[2,3,2,3,0,3,2,3,2,4]; zeros(Int, QM.vertex_buffer(env.mesh) - 10)]
@test allequal(test_desired_degree, env.desired_degree)



mesh = QM.square_mesh(2)
d0 = deepcopy(mesh.degree[mesh.active_vertex])
QM.left_flip!(mesh, 1, 2)
env = QM.GameEnv(mesh, d0, 4)
QM.step_nothing!(env)
@test !env.is_terminated
@test env.reward == 0
@test env.num_actions == 1

QM.step_nothing!(env)
@test !env.is_terminated
@test env.reward == 0

QM.step_nothing!(env)
@test !env.is_terminated
@test env.reward == 0

QM.step_nothing!(env)
@test env.is_terminated
@test env.reward == 0


############################################################################################################
# Test reindex game env
mesh = QM.square_mesh(2)
env = QM.GameEnv(mesh, mesh.degree[mesh.active_vertex], 10)
QM.step_split!(env, 1, 3)
QM.step_left_flip!(env, 1, 2)
QM.step_left_flip!(env, 1, 2)
QM.step_left_flip!(env, 1, 2)
QM.step_collapse!(env, 1, 2)

QM.reindex_game_env!(env)

connectivity = [2 9 5 3
                4 6 7 9
                9 7 8 5
                4 9 2 1]
@test allequal(QM.active_quad_connectivity(env.mesh), connectivity')
q2q = [4 3 0 0
       0 0 3 4
       2 0 0 1
       2 1 0 0]
@test allequal(QM.active_quad_q2q(env.mesh), q2q')
e2e = [2 4 0 0
       0 0 1 1
       3 0 0 2
       4 1 0 0]
@test allequal(QM.active_quad_e2e(env.mesh), e2e')
d0 = [2,3,2,3,3,2,3,2,4]
@test allequal(QM.active_vertex_desired_degree(env), d0)
############################################################################################################


############################################################################################################
# TEST COLLAPSING BOUNDARY QUAD
mesh = QM.square_mesh(2)
desired_degree = deepcopy(mesh.degree[mesh.active_vertex])
env = QM.GameEnv(mesh, desired_degree, 5)
QM.step_collapse!(env, 1, 3)
degree = [2,2,2,4,3,2,3,2]
@test allequal(QM.active_vertex_degrees(env.mesh), degree)
test_d0 = [0,3,2,3,2,3,2,3,2]
@test allequal(env.desired_degree[1:9], test_d0)
on_boundary = trues(8)
@test allequal(env.mesh.vertex_on_boundary[env.mesh.active_vertex], on_boundary)
# need at least one vertex in interior for collapse
@test !QM.is_valid_collapse(mesh, 4, 1, 7)
############################################################################################################


############################################################################################################
# mesh = QM.square_mesh(2)
# d0 = QM.active_vertex_degrees(mesh)
# env = QM.GameEnv(mesh, d0, 5)

# @test QM.step_global_split!(env, 2, 1)
# d0 = [2,3,2,3,4,3,2,3,2,4,4,3,3]
# @test allequal(QM.active_vertex_desired_degree(env), d0)
# vs = [0,1,0,0,-1,0,0,0,0,0,0,0,0]
# @test allequal(QM.active_vertex_score(env), vs)
# @test env.current_score == 2
# @test env.opt_score == 0
# @test env.reward == -2