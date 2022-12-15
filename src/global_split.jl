struct Tracker
    new_vertex_ids
    on_boundary
    function Tracker()
        new_vertex_ids = Int[]
        on_boundary = Bool[]
        new(new_vertex_ids, on_boundary)
    end
end

function update_tracker!(tracker, vertex_id, on_boundary)
    push!(tracker.new_vertex_ids, vertex_id)
    push!(tracker.on_boundary, on_boundary)
end

function is_valid_global_split(mesh, quad_idx, half_edge_idx, maxdegree)
    if !is_active_quad(mesh, quad_idx) || !has_neighbor(mesh, quad_idx, half_edge_idx)
        return false
    end

    v1, v2 = vertex(mesh, quad_idx, half_edge_idx), vertex(mesh, quad_idx, next(half_edge_idx))
    
    # degree of v1 increases by 1 so if it is at maxdegree, return false
    if degree(mesh, v1) >= maxdegree 
        return false
    end

    # degree of v2 must be at least 4
    if !vertex_on_boundary(mesh, v2) && degree(mesh, v2) < 4
        return false
    end

    if vertex_on_boundary(mesh, v2) && degree(mesh, v2) < 3
        return false
    end

    return true
end

function insert_initial_quad_for_global_split!(mesh, quad_idx, half_edge_idx, tracker)
    l1, l2, l3, l4 = next_cyclic_vertices(half_edge_idx)
    v1, v2, v3, v4 = (vertex(mesh, quad_idx, l) for l in (l1, l2, l3, l4))

    opp_quad, opp_half_edge = neighbor(mesh, quad_idx, half_edge_idx), twin(mesh, quad_idx, half_edge_idx)
    ol1, ol2, ol3, ol4 = next_cyclic_vertices(opp_half_edge)
    ov1, ov2, ov3, ov4 = (vertex(mesh, opp_quad, l) for l in (ol1, ol2, ol3, ol4))

    new_vertex_coords1 = new_vertex_coordinates(mesh, v2, v3)
    new_vertex_coords2 = new_vertex_coordinates(mesh, ov1, ov4)

    on_boundary1 = !has_neighbor(mesh, quad_idx, l2)
    on_boundary2 = !has_neighbor(mesh, opp_quad, ol4)

    deg1 = on_boundary1 ? 3 : 4
    deg2 = on_boundary2 ? 3 : 4

    nv1 = insert_vertex!(mesh, new_vertex_coords1, deg1, on_boundary1)
    nv2 = insert_vertex!(mesh, new_vertex_coords2, deg2, on_boundary2)

    update_tracker!(tracker, nv1, on_boundary1)
    update_tracker!(tracker, nv2, on_boundary2)

    nq1, nq2, nq3, nq4 = (quad_idx, opp_quad, neighbor(mesh, opp_quad, ol4), neighbor(mesh, quad_idx, l2))
    nl1, nl2, nl3, nl4 = (l1, ol1, twin(mesh, opp_quad, ol4), twin(mesh, quad_idx, l2))
    new_quad_idx = insert_quad!(mesh, (nv1, v1, nv2, v2), (nq1, nq2, nq3, nq4), (nl1, nl2, nl3, nl4))

    set_vertex!(mesh, quad_idx, l2, nv1)
    set_neighbor!(mesh, quad_idx, l1, new_quad_idx)
    set_twin!(mesh, quad_idx, l1, 1)

    set_vertex!(mesh, opp_quad, ol1, nv2)
    set_neighbor!(mesh, opp_quad, ol1, new_quad_idx)
    set_twin!(mesh, opp_quad, ol1, 2)

    increment_degree!(mesh, v1)
    decrement_degree!(mesh, v2)

    return new_quad_idx
end

function split_neighboring_quad_along_path!(mesh, quad_idx, half_edge_idx, tracker)
    l2 = next(half_edge_idx)
    v2 = vertex(mesh, quad_idx, l2)

    @assert has_neighbor(mesh, quad_idx, l2)
    nbr_quad, nbr_twin = neighbor(mesh, quad_idx, l2), twin(mesh, quad_idx, l2)
    set_neighbor!(mesh, nbr_quad, nbr_twin, quad_idx)
    set_twin!(mesh, nbr_quad, nbr_twin, l2)

    ol1, ol2, ol3, ol4 = next_cyclic_vertices(nbr_twin)
    ov1, ov2, ov3, ov4 = (vertex(mesh, nbr_quad, l) for l in (ol1, ol2, ol3, ol4))

    new_vertex_coords = new_vertex_coordinates(mesh, ov3, ov4)
    on_boundary = !has_neighbor(mesh, nbr_quad, ol3)
    deg = on_boundary ? 3 : 4

    new_vertex_id = insert_vertex!(mesh, new_vertex_coords, deg, on_boundary)
    update_tracker!(tracker, new_vertex_id, on_boundary)

    set_vertex!(mesh, nbr_quad, ol2, v2)
    set_vertex!(mesh, nbr_quad, ol3, new_vertex_id)

    opp_quad, opp_twin = neighbor(mesh, quad_idx, half_edge_idx), twin(mesh, quad_idx, half_edge_idx)
    nq1, nq2, nq3, nq4 = (nbr_quad, opp_quad, neighbor(mesh, nbr_quad, ol2), neighbor(mesh, nbr_quad, ol3))
    nl1, nl2, nl3, nl4 = (ol2, previous(opp_twin), twin(mesh, nbr_quad, ol2), twin(mesh, nbr_quad, ol3))
    new_quad_idx = insert_quad!(mesh, (new_vertex_id, v2, ov2, ov3), (nq1, nq2, nq3, nq4), (nl1, nl2, nl3, nl4))

    for (q, l) in zip((nq1, nq2, nq3, nq4), (nl1, nl2, nl3, nl4))
        set_neighbor_if_not_boundary!(mesh, q, l, new_quad_idx)
    end
    
    for (q, l, idx) in zip((nq1, nq2, nq3, nq4), (nl1, nl2, nl3, nl4), (1, 2, 3, 4))
        set_twin_if_not_boundary!(mesh, q, l, idx)
    end

end

function is_valid_path_split(mesh, quad_idx, half_edge_idx)
    @assert is_active_quad(mesh, quad_idx)
    return has_neighbor(mesh, quad_idx, next(half_edge_idx))
end

function global_split_quads_along_path!(mesh, quad_idx, half_edge_idx, tracker)
    while is_valid_path_split(mesh, quad_idx, half_edge_idx)
        split_neighboring_quad_along_path!(mesh, quad_idx, half_edge_idx, tracker)
        prev_quad = quad_idx
        prev_edge = half_edge_idx

        quad_idx = neighbor(mesh, prev_quad, next(prev_edge))
        half_edge_idx = next(twin(mesh, prev_quad, next(prev_edge)))
    end
end

function global_split!(mesh, quad_idx, half_edge_idx, tracker, maxdegree = 7)
    if !is_valid_global_split(mesh, quad_idx, half_edge_idx, maxdegree)
        return false
    end

    new_quad_idx = insert_initial_quad_for_global_split!(mesh, quad_idx, half_edge_idx, tracker)

    global_split_quads_along_path!(mesh, quad_idx, half_edge_idx, tracker)
    global_split_quads_along_path!(mesh, new_quad_idx, 2, tracker)

    return true
end