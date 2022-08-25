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