mutable struct GameEnv
    mesh::Any
    d0::Any
    vertex_score::Any
    template
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
    @assert count(mesh.active_vertex) == nv
    @assert all(mesh.active_quad[1:nq])
    @assert count(mesh.active_quad) == nq
end

function GameEnv(mesh, d0, max_actions)
    _is_initial_mesh(mesh)
    nvb = vertex_buffer(mesh)
    exp_d0 = [d0; zeros(Int, nvb - length(d0))]
    vertex_score = mesh.degree - exp_d0
    template = make_template(mesh)
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
        template,
        max_actions,
        num_actions,
        initial_score,
        current_score,
        opt_score,
        reward,
        is_terminated,
    )
end

function Base.show(io::IO, env::GameEnv)
    nv = number_of_vertices(env.mesh)
    nq = number_of_quads(env.mesh)
    cs = env.current_score
    os = env.opt_score
    remaining_actions = env.max_actions - env.num_actions
    term = env.is_terminated

    println(io, "GameEnv")
    println(io, "\t$nv vertices")
    println(io, "\t$nq quads")
    println(io, "\t$cs current score")
    if term
        println(io, "\tTERMINATED")
    else
        println(io, "\t$remaining_actions remaining actions")
    end
end

function active_vertex_scores(env)
    return env.vertex_score[env.mesh.active_vertex]
end

function update_env_after_action(env)
    env.vertex_score = env.mesh.degree - env.d0
    env.template = make_template(env.mesh)
    env.current_score = sum(abs.(env.vertex_score))
end

function step_left_flip!(env, quad, edge; maxdegree=7, no_action_reward=-4)
    if is_valid_left_flip(env.mesh, quad, edge, maxdegree)
        old_score = env.current_score
        left_flip!(env.mesh, quad, edge, maxdegree)
        update_env_after_action(env)
        env.reward = old_score - env.current_score
    else
        env.reward = no_action_reward
    end
    env.num_actions += 1
    env.is_terminated = check_terminated(env)
end

function step_right_flip!(env, quad, edge; maxdegree=7, no_action_reward=-4)
    if is_valid_right_flip(env.mesh, quad, edge, maxdegree)
        old_score = env.current_score
        right_flip!(env.mesh, quad, edge, maxdegree)
        update_env_after_action(env)
        env.reward = old_score - env.current_score
    else
        env.reward = no_action_reward
    end
    env.num_actions += 1
    env.is_terminated = check_terminated(env)
end

function step_split!(env, quad, edge; maxdegree=7, no_action_reward=-4)
    if is_valid_split(env.mesh, quad, edge, maxdegree)
        old_score = env.current_score
        split!(env.mesh, quad, edge, maxdegree)
        update_env_after_action(env)
        env.reward = old_score - env.current_score
    else
        env.reward = no_action_reward
    end
    env.num_actions += 1
    env.is_terminated = check_terminated(env)
end

function step_collapse!(env, quad, edge; maxdegree = 7, no_action_reward=-4)
    if is_valid_collapse(env.mesh, quad, edge, maxdegree)
        old_score = env.current_score
        collapse!(env.mesh, quad, edge, maxdegree)
        update_env_after_action(env)
        env.reward = old_score - env.current_score
    else
        env.reward = no_action_reward
    end
    env.num_actions += 1
    env.is_terminated = check_terminated(env)
end

function make_edge_pairs(mesh)
    total_nq = quad_buffer(mesh)
    pairs = zeros(Int, 4total_nq)
    bdry_idx = 4total_nq + 1
    for quad = 1:total_nq
        for vertex = 1:4
            index = (quad - 1) * 4 + vertex
            opp_quad, opp_ver = mesh.q2q[vertex, quad], mesh.e2e[vertex, quad]
            pairs[index] = opp_quad == 0 ? bdry_idx : (opp_quad - 1) * 4 + opp_ver
        end
    end
    return pairs
end



function cycle_edges(x)
    nf, na = size(x)
    x = reshape(x, nf, 4, :)

    x1 = reshape(x, 4nf, 1, :)
    x2 = reshape(x[:, [2, 3, 4, 1], :], 4nf, 1, :)
    x3 = reshape(x[:, [3, 4, 1, 2], :], 4nf, 1, :)
    x4 = reshape(x[:, [4, 1, 2, 3], :], 4nf, 1, :)

    x = cat(x1, x2, x3, x4, dims=2)
    x = reshape(x, 4nf, :)

    return x
end

function zero_pad(m)
    return [m zeros(Int, size(m, 1))]
end

function make_template(mesh)
    pairs = make_edge_pairs(mesh)
    x = reshape(mesh.connectivity, 1, :)

    cx = cycle_edges(x)

    pcx = zero_pad(cx)[:, pairs][3:end, :]
    cpcx = cycle_edges(pcx)

    pcpcx = zero_pad(cpcx)[:, pairs][3:end, :]
    cpcpcx = cycle_edges(pcpcx)

    template = vcat(cx, cpcx, cpcpcx)

    return template
end