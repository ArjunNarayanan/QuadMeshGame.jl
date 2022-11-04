function make_vertices(nvertices_per_side)
    x = range(0.0, stop = 1.0, length = nvertices_per_side)
    xrow = repeat(x, inner = nvertices_per_side)
    yrow = repeat(x, outer = nvertices_per_side)
    vertices = vcat(xrow', yrow')
    return vertices
end

function idx2cartesian(idx, n_per_side)
    col = div(idx - 1, n_per_side) + 1
    row = rem(idx - 1, n_per_side) + 1
    return col, row
end

function quad_connectivity(quadidx, nquads_per_side)
    col, row = idx2cartesian(quadidx, nquads_per_side)
    npoints = nquads_per_side + 1

    q1 = (col - 1) * npoints + row
    q2 = q1 + npoints
    q3 = q2 + 1
    q4 = q1 + 1

    return q1, q2, q3, q4
end

function make_connectivity(nquads_per_side)
    total_nquads = nquads_per_side * nquads_per_side
    connectivity = zeros(Int, 4, total_nquads)
    for quadidx = 1:total_nquads
        connectivity[:, quadidx] .= quad_connectivity(quadidx, nquads_per_side)
    end
    return connectivity
end

function set_boundary_to_val!(matrix, val, n_per_side, total_n)
    bottom_row = ((1:total_n) .% n_per_side) .== 1
    matrix[1, bottom_row] .= val

    right_row = (total_n-n_per_side+1):total_n
    matrix[2, right_row] .= val

    top_row = ((1:total_n) .% n_per_side) .== 0
    matrix[3, top_row] .= val

    left_row = 1:n_per_side
    matrix[4, left_row] .= val
end

function make_q2q(nquads_per_side)
    total_nquads = nquads_per_side * nquads_per_side

    q2q = zeros(Int, 4, total_nquads)
    for idx = 1:total_nquads
        q2q[1, idx] = idx - 1
        q2q[2, idx] = idx + nquads_per_side
        q2q[3, idx] = idx + 1
        q2q[4, idx] = idx - nquads_per_side
    end

    set_boundary_to_val!(q2q, 0, nquads_per_side, total_nquads)
    return q2q
end

function make_e2e(nquads_per_side)
    total_nquads = nquads_per_side * nquads_per_side

    e2e = repeat([3, 4, 1, 2], inner = (1, total_nquads))
    set_boundary_to_val!(e2e, 0, nquads_per_side, total_nquads)

    return e2e
end

function set_boundary_vertex_value!(vector, val, nvertices_per_side, total_n_vertices)
    vector[1:nvertices_per_side:total_n_vertices] .= val
    vector[(total_n_vertices-nvertices_per_side+1):total_n_vertices] .= val
    vector[nvertices_per_side:nvertices_per_side:total_n_vertices] .= val
    vector[1:nvertices_per_side] .= val
end

function make_degree(nquads_per_side)
    nvertices_per_side = nquads_per_side + 1
    total_n_vertices = nvertices_per_side * nvertices_per_side

    degree = fill(4, total_n_vertices)

    set_boundary_vertex_value!(degree, 3, nvertices_per_side, total_n_vertices)

    degree[1] = 2
    degree[nvertices_per_side] = 2
    degree[total_n_vertices-nvertices_per_side+1] = 2
    degree[total_n_vertices] = 2

    return degree
end

function make_vertex_on_boundary(nquads_per_side)
    nvertices_per_side = nquads_per_side + 1
    total_n_vertices = nvertices_per_side * nvertices_per_side

    on_boundary = fill(false, total_n_vertices)

    set_boundary_vertex_value!(on_boundary, true, nvertices_per_side, total_n_vertices)

    return on_boundary
end

function square_mesh(
    nquads_per_side;
)
    nvertices_per_side = nquads_per_side + 1
    vertices = make_vertices(nvertices_per_side)
    connectivity = make_connectivity(nquads_per_side)
    

    return QuadMesh(
        vertices,
        connectivity,
    )
end
