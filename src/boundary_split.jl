function is_valid_boundary_split(mesh, quad_idx, half_edge_idx, maxdegree = 7)
    if !is_active_quad(mesh, quad_idx) || !has_neighbor(mesh, quad_idx, half_edge_idx)
        return false
    end

    # degree of v1 increases by 1 so if it is at maxdegree, return false
    v1 = vertex(mesh, quad_idx, half_edge_idx)
    if degree(mesh, v1) >= maxdegree 
        return false
    end

    if has_neighbor(mesh, quad_idx, next(half_edge_idx))
        return false
    end

    nbr_quad, nbr_half_edge = neighbor(mesh, quad_idx, half_edge_idx), twin(mesh, quad_idx, half_edge_idx)
    if has_neighbor(mesh, nbr_quad, previous(nbr_half_edge))
        return false
    end

    return true
end

function _boundary_split!(mesh, quad_idx, half_edge_idx)
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

    nq1, nq2, nq3, nq4 = (quad_idx, opp_quad, neighbor(mesh, opp_quad, ol4), neighbor(mesh, quad_idx, l2))
    nl1, nl2, nl3, nl4 = (l1, ol1, twin(mesh, opp_quad, ol4), twin(mesh, quad_idx, l2))
    new_quad_idx = insert_quad!(mesh, (nv1, v1, nv2, v2), (nq1, nq2, nq3, nq4), (nl1, nl2, nl3, nl4))

    set_vertex!(mesh, quad_idx, l2, nv1)

    set_vertex!(mesh, opp_quad, ol1, nv2)

    for (q, l, idx) in zip((nq1, nq2, nq3, nq4), (nl1, nl2, nl3, nl4), (1,2,3,4))
        set_neighbor_if_not_boundary!(mesh, q, l, new_quad_idx)
        set_twin_if_not_boundary!(mesh, q, l, idx)
    end

    increment_degree!(mesh, v1)
    decrement_degree!(mesh, v2)

    return new_quad_idx
end


function boundary_split!(mesh, quad, edge, maxdegree = 7)
    if !is_valid_boundary_split(mesh, quad, edge, maxdegree)
        return false
    end

    _boundary_split!(mesh, quad, edge)

    return true
end