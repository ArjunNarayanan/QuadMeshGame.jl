mutable struct GameEnv
    mesh::Any
    d0::Any
    vertex_score::Any
    max_actions::Any
    num_actions::Any
    initial_score::Any
    current_score::Any
    opt_score::Any
    reward::Any
    is_terminated::Any
end

function check_terminated(num_actions, max_actions, current_score, opt_score)
    return num_actions >= max_actions || current_score == opt_score
end

function check_terminated(env)
    return check_terminated(
        env.num_actions,
        env.max_actions,
        env.current_score,
        env.opt_score,
    )
end

function _is_initial_mesh(mesh)
    nv = number_of_vertices(mesh)
    nq = number_of_quads(mesh)
    @assert all(mesh.active_vertex[1:nv])
    @assert all(mesh.active_quad[1:nq])
end

function GameEnv(mesh, d0, max_actions)
    _is_initial_mesh(mesh)
    nvb = vertex_buffer(mesh)
    exp_d0 = [d0; zeros(Int, nvb - length(d0))]
    vertex_score = mesh.degree - exp_d0
    opt_score = sum(vertex_score)
    current_score = sum(abs.(vertex_score))
    initial_score = current_score
    reward = 0
    num_actions = 0
    is_terminated = check_terminated(num_actions, max_actions, current_score, opt_score)
    return GameEnv(
        mesh,
        exp_d0,
        vertex_score,
        max_actions,
        num_actions,
        initial_score,
        current_score,
        opt_score,
        reward,
        is_terminated,
    )
end
