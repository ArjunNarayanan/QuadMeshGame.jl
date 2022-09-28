function is_valid_split(mesh, quad, edge, maxdegree)
    # check that current quad is active and edge along split is interior
    if !is_active_quad(mesh, quad) || !has_neighbor(mesh, quad, edge)
        return false
    end

    l1, l2, l3, l4 = next_cyclic_vertices(edge)
    v1, v2, v3, v4 = (vertex(mesh, quad, i) for i in (l1, l2, l3, l4))

    opp_quad, opp_edge = neighbor(mesh, quad, edge), twin(mesh, quad, edge)
    l5, l6, l7, l8 = next_cyclic_vertices(opp_edge)
    v5, v6, v7, v8 = (vertex(mesh, opp_quad, i) for i in (l5, l6, l7, l8))

    if degree(mesh, v1) < 3
        return false
    end

    if degree(mesh, v4) >= maxdegree || degree(mesh, v7) >= maxdegree
        return false
    end

    return true
end

function new_vertex_coordinates(mesh, v1, v2)
    return 0.5*(vertex_coordinates(mesh, v1) + vertex_coordinates(mesh, v2))
end

function split!(mesh, quad, edge, maxdegree = 7)
    if !is_valid_split(mesh, quad, edge, maxdegree)
        return false
    end

    l1, l2, l3, l4 = next_cyclic_vertices(edge)
    v1, v2, v3, v4 = (vertex(mesh, quad, i) for i in (l1, l2, l3, l4))

    opp_quad, opp_edge = neighbor(mesh, quad, edge), twin(mesh, quad, edge)
    l5, l6, l7, l8 = next_cyclic_vertices(opp_edge)
    v5, v6, v7, v8 = (vertex(mesh, opp_quad, i) for i in (l5, l6, l7, l8))

    new_coords = new_vertex_coordinates(mesh, v1, v2)
    v9 = insert_vertex!(mesh, new_coords, 3, false)

    set_vertex!(mesh, quad, l1, v9)
    set_vertex!(mesh, opp_quad, l6, v9)

    q1, q2, q3, q4 = (neighbor(mesh, quad, i) for i in (l1, l2, l3, l4))
    q5, q6, q7, q8 = (neighbor(mesh, opp_quad, i) for i in (l5, l6, l7, l8))

    ol1, ol2, ol3, ol4 = (twin(mesh, quad, i) for i in (l1, l2, l3, l4))
    ol5, ol6, ol7, ol8 = (twin(mesh, opp_quad, i) for i in (l5, l6, l7, l8))

    new_quad_idx = insert_quad!(mesh, (v9, v4, v1, v7), (quad, q4, q6, opp_quad), (l4, ol4, ol6, l6))

    set_neighbor_if_not_boundary!(mesh, quad, l4, new_quad_idx)
    set_neighbor_if_not_boundary!(mesh, opp_quad, l6, new_quad_idx)
    set_neighbor_if_not_boundary!(mesh, q4, ol4, new_quad_idx)
    set_neighbor_if_not_boundary!(mesh, q6, ol6, new_quad_idx)

    set_twin_if_not_boundary!(mesh, quad, l4, 1)
    set_twin_if_not_boundary!(mesh, opp_quad, l6, 4)
    set_twin_if_not_boundary!(mesh, q4, ol4, 2)
    set_twin_if_not_boundary!(mesh, q6, ol6, 3)
    
    # increment degree of vertices that gained an edge
    increment_degree!(mesh, v4)
    increment_degree!(mesh, v7)

    # if the vertex being split is interior, then it loses one degree
    decrement_degree!(mesh, v1)

    return true
end