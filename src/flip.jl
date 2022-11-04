function is_valid_left_flip(mesh::QuadMesh, quad, edge, maxdegree = 7)
    if !is_active_quad(mesh, quad) || !has_neighbor(mesh, quad, edge)
        return false
    end

    l1, l2, l3, l4 = next_cyclic_vertices(edge)
    v1, v2, v3, v4 = (vertex(mesh, quad, i) for i in (l1, l2, l3, l4))

    # Check that interior vertices losing an edge have a minimum degree of 3 before allowing flip
    if (!vertex_on_boundary(mesh, v1) && degree(mesh, v1) < 3)
        return false
    end
    if (!vertex_on_boundary(mesh, v2) && degree(mesh, v2) < 3)
        return false
    end

    opp_quad, opp_edge = neighbor(mesh, quad, edge), twin(mesh, quad, edge)
    l5, l6, l7, l8 = next_cyclic_vertices(opp_edge)
    v5, v6, v7, v8 = (vertex(mesh, opp_quad, i) for i in (l5, l6, l7, l8))

    # Check that vertices receiving an edge do not have maximum allowed degree
    if degree(mesh, v3) >= maxdegree || degree(mesh, v7) >= maxdegree
        return false
    end

    return true
end

function is_valid_right_flip(mesh::QuadMesh, quad, edge, maxdegree = 7)
    if !is_active_quad(mesh, quad) || !has_neighbor(mesh, quad, edge)
        return false
    end

    l1, l2, l3, l4 = next_cyclic_vertices(edge)
    v1, v2, v3, v4 = (vertex(mesh, quad, i) for i in (l1, l2, l3, l4))

    # Check that interior vertices losing an edge have a minimum degree of 3 before allowing flip
    if (!vertex_on_boundary(mesh, v1) && degree(mesh, v1) < 3)
        return false
    end
    if (!vertex_on_boundary(mesh, v2) && degree(mesh, v2) < 3)
        return false
    end

    opp_quad, opp_edge = neighbor(mesh, quad, edge), twin(mesh, quad, edge)
    l5, l6, l7, l8 = next_cyclic_vertices(opp_edge)
    v5, v6, v7, v8 = (vertex(mesh, opp_quad, i) for i in (l5, l6, l7, l8))

    # Check that vertices receiving an edge do not have maximum allowed degree
    if degree(mesh, v4) >= maxdegree || degree(mesh, v8) >= maxdegree
        return false
    end

    return true
end

function left_flip!(mesh::QuadMesh, quad, edge, maxdegree = 7)
    if !is_valid_left_flip(mesh, quad, edge, maxdegree)
        return false
    end

    l1, l2, l3, l4 = next_cyclic_vertices(edge)
    v1, v2, v3, v4 = (vertex(mesh, quad, i) for i in (l1, l2, l3, l4))

    opp_quad, opp_edge = neighbor(mesh, quad, edge), twin(mesh, quad, edge)
    l5, l6, l7, l8 = next_cyclic_vertices(opp_edge)
    v5, v6, v7, v8 = (vertex(mesh, opp_quad, i) for i in (l5, l6, l7, l8))

    # Update connectivity of current quad
    for (l, v) in zip((l1, l2, l3, l4), (v7, v3, v4, v1))
        set_vertex!(mesh, quad, l, v)
    end

    # update connectivity of opposite quad
    for (l, v) in zip((l5, l6, l7, l8), (v3, v7, v8, v5))
        set_vertex!(mesh, opp_quad, l, v)
    end

    q1, q2, q3, q4 = (neighbor(mesh, quad, i) for i in (l1, l2, l3, l4))
    q5, q6, q7, q8 = (neighbor(mesh, opp_quad, i) for i in (l5, l6, l7, l8))

    # update neighbors of current quad
    for (l, q) in zip((l1, l2, l3, l4), (q1, q3, q4, q6))
        set_neighbor!(mesh, quad, l, q)
    end

    # update neighbors of opposite quad
    for (l, q) in zip((l5, l6, l7, l8), (q5, q7, q8, q2))
        set_neighbor!(mesh, opp_quad, l, q)
    end

    ol1, ol2, ol3, ol4 = (twin(mesh, quad, i) for i in (l1, l2, l3, l4))
    ol5, ol6, ol7, ol8 = (twin(mesh, opp_quad, i) for i in (l5, l6, l7, l8))

    # update twin edges of current quad
    for (l, ol) in zip((l1, l2, l3, l4), (ol1, ol3, ol4, ol6))
        set_twin!(mesh, quad, l, ol)
    end

    # update twin edges of opposite quad
    for (l, ol) in zip((l5, l6, l7, l8), (ol5, ol7, ol8, ol2))
        set_twin!(mesh, opp_quad, l, ol)
    end

    # set current quad as neighbor for appropriate neighbors
    for (q, ol) in zip((q1, q3, q4, q6), (ol1, ol3, ol4, ol6))
        set_neighbor_if_not_boundary!(mesh, q, ol, quad)
    end

    # set opposite quad as neighbor for appropriate neighbors
    for (q, ol) in zip((q5, q7, q8, q2), (ol5, ol7, ol8, ol2))
        set_neighbor_if_not_boundary!(mesh, q, ol, opp_quad)
    end

    # set current quad edges as twin edges of appropriate neighbors
    for (q, ol, l) in zip((q1, q3, q4, q6), (ol1, ol3, ol4, ol6), (l1, l2, l3, l4))
        set_twin_if_not_boundary!(mesh, q, ol, l)
    end

    # set opposite quad edges as twin edges of appropriate neighbors
    for (q, ol, l) in zip((q5, q7, q8, q2), (ol5, ol7, ol8, ol2), (l5, l6, l7, l8))
        set_twin_if_not_boundary!(mesh, q, ol, l)
    end

    # increment degree of vertices gaining an edge
    increment_degree!(mesh, v3)
    increment_degree!(mesh, v7)

    # decrement degree of vertices losing an edge
    decrement_degree!(mesh, v1)
    decrement_degree!(mesh, v2)

    return true
end

function right_flip!(mesh::QuadMesh, quad, edge, maxdegree = 7)
    if !is_valid_right_flip(mesh, quad, edge, maxdegree)
        return false
    end

    l1, l2, l3, l4 = next_cyclic_vertices(edge)
    v1, v2, v3, v4 = (vertex(mesh, quad, i) for i in (l1, l2, l3, l4))

    opp_quad, opp_edge = neighbor(mesh, quad, edge), twin(mesh, quad, edge)
    l5, l6, l7, l8 = next_cyclic_vertices(opp_edge)
    v5, v6, v7, v8 = (vertex(mesh, opp_quad, i) for i in (l5, l6, l7, l8))

    # Update connectivity of current quad
    for (l, v) in zip((l1, l2, l3, l4), (v4, v8, v2, v3))
        set_vertex!(mesh, quad, l, v)
    end

    # Update connectivity of opposite quad
    for (l, v) in zip((l5, l6, l7, l8), (v8, v4, v6, v7))
        set_vertex!(mesh, opp_quad, l, v)
    end

    q1, q2, q3, q4 = (neighbor(mesh, quad, i) for i in (l1, l2, l3, l4))
    q5, q6, q7, q8 = (neighbor(mesh, opp_quad, i) for i in (l5, l6, l7, l8))

    # update neighbors of current quad
    for (l, q) in zip((l1, l2, l3, l4), (q1, q8, q2, q3))
        set_neighbor!(mesh, quad, l, q)
    end

    # update neighbors of opposite quad
    for (l, q) in zip((l5, l6, l7, l8), (q5, q4, q6, q7))
        set_neighbor!(mesh, opp_quad, l, q)
    end

    ol1, ol2, ol3, ol4 = (twin(mesh, quad, i) for i in (l1, l2, l3, l4))
    ol5, ol6, ol7, ol8 = (twin(mesh, opp_quad, i) for i in (l5, l6, l7, l8))

    # update twin edges of current quad
    for (l, ol) in zip((l1, l2, l3, l4), (ol1, ol8, ol2, ol3))
        set_twin!(mesh, quad, l, ol)
    end

    # update twin edges of opposite quad
    for (l, ol) in zip((l5, l6, l7, l8), (ol5, ol4, ol6, ol7))
        set_twin!(mesh, opp_quad, l, ol)
    end

    # set current quad as neighbor for appropriate neighbors
    for (q, ol) in zip((q1, q8, q2, q3), (ol1, ol8, ol2, ol3))
        set_neighbor_if_not_boundary!(mesh, q, ol, quad)
    end

    # set opposite quad as neighbor for appropriate neighbors
    for (q, ol) in zip((q5, q4, q6, q7), (ol5, ol4, ol6, ol7))
        set_neighbor_if_not_boundary!(mesh, q, ol, opp_quad)
    end

    # set current quad edges as twin edges of appropriate neighbors
    for (q, ol, l) in zip((q1, q8, q2, q3), (ol1, ol8, ol2, ol3), (l1, l2, l3, l4))
        set_twin_if_not_boundary!(mesh, q, ol, l)
    end

    # set opposite quad edges as twin edges of appropriate neighbors
    for (q, ol, l) in zip((q5, q4, q6, q7), (ol5, ol4, ol6, ol7), (l5, l6, l7, l8))
        set_twin_if_not_boundary!(mesh, q, ol, l)
    end

    # increment degree of vertices gaining edge
    increment_degree!(mesh, v4)
    increment_degree!(mesh, v8)

    # decrement degree of vertices losing edge
    decrement_degree!(mesh, v1)
    decrement_degree!(mesh, v2)

    return true

end
