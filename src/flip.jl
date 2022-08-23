function is_valid_left_flip(mesh::QuadMesh, quad, edge; maxdegree=7)
    if !is_active_quad(mesh, quad) || !has_neighbor(mesh, quad, edge)
        return false
    end

    l1, l2, l3, l4 = next_cyclic_vertices(edge)
    v1, v2, v3, v4 = (vertex(mesh, quad, i) for i in (l1, l2, l3, l4))

    # Check that interior vertices losing an edge have a minimum degree of 4 before allowing flip
    if (!vertex_on_boundary(mesh, v1) && degree(mesh, v1) < 4)
        return false
    end
    if (!vertex_on_boundary(mesh, v2) && degree(mesh, v2) < 4)
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

function is_valid_right_flip(mesh::QuadMesh, quad, edge; maxdegree=7)
    if !is_active_quad(mesh, quad) || !has_neighbor(mesh, quad, edge)
        return false
    end

    l1, l2, l3, l4 = next_cyclic_vertices(edge)
    v1, v2, v3, v4 = (vertex(mesh, quad, i) for i in (l1, l2, l3, l4))

    # Check that interior vertices losing an edge have a minimum degree of 4 before allowing flip
    if (!vertex_on_boundary(mesh, v1) && degree(mesh, v1) < 4)
        return false
    end
    if (!vertex_on_boundary(mesh, v2) && degree(mesh, v2) < 4)
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

function left_flip!(mesh::QuadMesh, quad, edge; maxdegree = 7)
    if !is_valid_left_flip(mesh, quad, edge, maxdegree = maxdegree)
        return false
    end

    l1, l2, l3, l4 = next_cyclic_vertices(edge)
    v1, v2, v3, v4 = (vertex(mesh, quad, i) for i in (l1, l2, l3, l4))
    
    set_vertex!(mesh, quad, l1, v7)
    set_vertex!(mesh, quad, l2, v3)
    set_vertex!(mesh, quad, l3, v4)
    set_vertex!(mesh, quad, l4, v1)

    opp_quad, opp_edge = neighbor(mesh, quad, edge), twin(mesh, quad, edge)
    l5, l6, l7, l8 = next_cyclic_vertices(opp_edge)
    v5, v6, v7, v8 = (vertex(mesh, opp_quad, i) for i in (l5, l6, l7, l8))

    set_vertex!(mesh, opp_quad, l5, v3)
    set_vertex!(mesh, opp_quad, l6, v7)
    set_vertex!(mesh, opp_quad, l7, v8)
    set_vertex!(mesh, opp_quad, l8, v5)
end