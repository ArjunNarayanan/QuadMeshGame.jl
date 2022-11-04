function make_quad_connectivity(connectivity)
    map = [1 2 3 4;
           2 3 4 1]
    ne,nt = size(map,2), size(connectivity,2)
    
    nr = size(connectivity, 1)
    @assert nr == 4 "Expected connectivity to have 4 rows, got $nr instead"

    t2t = zeros(Int, ne, nt)
    t2n = zeros(Int, ne, nt)
    dd = Dict{Tuple{Int,Int}, Tuple{Int,Int}}()
    sizehint!(dd, nt*ne)

    for it = 1:nt
        for ie = 1:ne
            e1 = connectivity[map[1,ie],it]
            e2 = connectivity[map[2,ie],it]
            e = ( min(e1,e2), max(e1,e2) )
            if haskey(dd,e)
                nb = pop!(dd,e)
                t2t[ie,it] = nb[1]
                t2n[ie,it] = nb[2]
                t2t[nb[2],nb[1]] = it
                t2n[nb[2],nb[1]] = ie
            else
                dd[e] = (it,ie)
            end
        end
    end
    t2t,t2n
end




mutable struct QuadMesh
    vertices::Any
    connectivity::Any
    q2q::Any
    e2e::Any
    degree::Any
    vertex_on_boundary::Any
    active_vertex::Any
    active_quad::Any
    num_vertices::Any
    num_quads::Any
    new_vertex_pointer
    new_quad_pointer
    growth_factor::Any
    function QuadMesh(
        vertices,
        connectivity,
        q2q,
        e2e,
        degree,
        vertex_on_boundary;
        quad_buffer = 100,
        vertex_buffer = 150,
        growth_factor = 2,
    )
        num_vertices = size(vertices, 2)
        num_quads = size(connectivity, 2)

        @assert num_vertices <= vertex_buffer
        @assert num_quads <= quad_buffer
        @assert size(vertices, 1) == 2
        @assert size(connectivity, 1) == 4
        @assert size(q2q, 1) == 4
        @assert size(e2e, 1) == 4
        @assert size(q2q, 2) == num_quads
        @assert size(e2e, 2) == num_quads
        @assert length(degree) == num_vertices
        @assert length(vertex_on_boundary) == num_vertices

        _vertices = zeros(2, vertex_buffer)
        _vertices[:, 1:num_vertices] .= vertices

        _connectivity = zeros(Int, 4, quad_buffer)
        _connectivity[:, 1:num_quads] .= connectivity

        _q2q = zeros(Int, 4, quad_buffer)
        _q2q[:, 1:num_quads] .= q2q

        _e2e = zeros(Int, 4, quad_buffer)
        _e2e[:, 1:num_quads] .= e2e

        _degree = zeros(Int, vertex_buffer)
        _degree[1:num_vertices] .= degree

        _vertex_on_boundary = falses(vertex_buffer)
        _vertex_on_boundary[1:num_vertices] .= vertex_on_boundary

        active_vertex = falses(vertex_buffer)
        active_vertex[1:num_vertices] .= true

        active_quad = falses(quad_buffer)
        active_quad[1:num_quads] .= true

        new_vertex_pointer = num_vertices + 1
        new_quad_pointer = num_quads + 1

        new(
            _vertices,
            _connectivity,
            _q2q,
            _e2e,
            _degree,
            _vertex_on_boundary,
            active_vertex,
            active_quad,
            num_vertices,
            num_quads,
            new_vertex_pointer,
            new_quad_pointer,
            growth_factor,
        )
    end
end


function QuadMesh(
    vertices,
    connectivity,
    q2q,
    e2e;
    quad_buffer = 100,
    vertex_buffer = 150,
    growth_factor = 2,
)
    num_vertices = size(vertices, 2)

    edges, bndix = all_edges(connectivity)
    bnd_edges = edges[:, bndix]

    bnd_nodes = sort!(unique(vec(bnd_edges)))
    vertex_on_boundary = falses(num_vertices)
    vertex_on_boundary[bnd_nodes] .= true

    degrees = vertex_degrees(edges, num_vertices)

    return QuadMesh(
        vertices,
        connectivity,
        q2q,
        e2e,
        degrees,
        vertex_on_boundary,
        quad_buffer = quad_buffer,
        vertex_buffer = vertex_buffer,
        growth_factor = growth_factor,
    )
end

function QuadMesh(vertices, connectivity)
    @assert ndims(vertices) == 2
    @assert ndims(connectivity) == 2
    dim, nverts = size(vertices)
    nv, nquads = size(connectivity)
    @assert dim == 2
    @assert nv == 4

    q2q, e2e = make_quad_connectivity(connectivity)
    return QuadMesh(vertices, connectivity, q2q, e2e, quad_buffer = 2*nquads, vertex_buffer = 2*nverts)
end

function number_of_vertices(mesh::QuadMesh)
    return mesh.num_vertices
end

function number_of_quads(mesh::QuadMesh)
    return mesh.num_quads
end

function quad_buffer(mesh::QuadMesh)
    return size(mesh.connectivity, 2)
end

function vertex_buffer(mesh::QuadMesh)
    return size(mesh.vertices, 2)
end

function growth_factor(mesh::QuadMesh)
    return mesh.growth_factor
end

function Base.show(io::IO, mesh::QuadMesh)
    nv = number_of_vertices(mesh)
    nq = number_of_quads(mesh)

    println(io, "QuadMesh")
    println(io, "\tNum Vert : $nv")
    println(io, "\tNum Quad : $nq")
end

function expand_quad!(mesh::QuadMesh)
    qb = quad_buffer(mesh)

    new_quad_buff_size = growth_factor(mesh) * qb

    _connectivity = zeros(Int, 4, new_quad_buff_size)
    _connectivity[:, 1:qb] .= mesh.connectivity
    mesh.connectivity = _connectivity

    _q2q = zeros(Int, 4, new_quad_buff_size)
    _q2q[:, 1:qb] .= mesh.q2q
    mesh.q2q = _q2q

    _e2e = zeros(Int, 4, new_quad_buff_size)
    _e2e[:, 1:qb] .= mesh.e2e
    mesh.e2e = _e2e

    active_quad = falses(new_quad_buff_size)
    active_quad[1:qb] .= mesh.active_quad
    mesh.active_quad = active_quad
end

function expand_vertices!(mesh::QuadMesh)
    vb = vertex_buffer(mesh)
    new_vert_buff_size = growth_factor(mesh) * vb

    _vertices = zeros(2, new_vert_buff_size)
    _vertices[:, 1:vb] .= mesh.vertices
    mesh.vertices = _vertices

    _degree = zeros(Int, new_vert_buff_size)
    _degree[1:vb] .= mesh.degree
    mesh.degree = _degree

    _vertex_on_boundary = falses(new_vert_buff_size)
    _vertex_on_boundary[1:vb] .= mesh.vertex_on_boundary
    mesh.vertex_on_boundary = _vertex_on_boundary

    active_vertex = falses(new_vert_buff_size)
    active_vertex[1:vb] .= mesh.active_vertex
    mesh.active_vertex = active_vertex
end

function is_active_quad(mesh::QuadMesh, quad)
    return mesh.active_quad[quad]
end

function is_interior_quad(mesh, quad)
    @assert is_active_quad(mesh, quad)
    all((has_neighbor(mesh, quad, l) for l in 1:4))
end

function is_active_quad_or_boundary(mesh::QuadMesh, quad)
    return quad == 0 || is_active_quad(mesh, quad)
end

function is_active_vertex(mesh::QuadMesh, vertex)
    return mesh.active_vertex[vertex]
end

function has_neighbor(mesh::QuadMesh, quad, edge)
    nbr_qidx = mesh.q2q[edge, quad]
    if nbr_qidx == 0
        return false
    elseif !is_active_quad(mesh, nbr_qidx)
        @warn "Quad $quad referencing inactive quad $nbr_qidx across edge $edge"
        return false
    else
        return true
    end
end

function vertex(mesh::QuadMesh, quad, local_ver_idx)
    @assert is_active_quad(mesh, quad)
    return mesh.connectivity[local_ver_idx, quad]
end

function vertex_coordinates(mesh::QuadMesh, vertex)
    @assert is_active_vertex(mesh, vertex)
    return mesh.vertices[:, vertex]
end

function active_vertex_coordinates(mesh::QuadMesh)
    return mesh.vertices[:, mesh.active_vertex]
end

function active_quad_connectivity(mesh::QuadMesh)
    return mesh.connectivity[:, mesh.active_quad]
end

function active_quad_q2q(mesh::QuadMesh)
    return mesh.q2q[:, mesh.active_quad]
end

function active_quad_e2e(mesh::QuadMesh)
    return mesh.e2e[:, mesh.active_quad]
end

function next_cyclic_vertices(v1)
    v2 = next(v1)
    v3 = next(v2)
    v4 = next(v3)
    return v1, v2, v3, v4
end

function prev_cyclic_vertices(v1)
    v2 = previous(v1)
    v3 = previous(v2)
    v4 = previous(v3)
    return v1, v2, v3, v4
end

function degree(mesh::QuadMesh, vertex)
    @assert is_active_vertex(mesh, vertex)
    return mesh.degree[vertex]
end

function active_vertex_degrees(mesh)
    return mesh.degree[mesh.active_vertex]
end

function neighbor(mesh::QuadMesh, quad, edge)
    return mesh.q2q[edge, quad]
end

function twin(mesh::QuadMesh, quad, edge)
    return mesh.e2e[edge, quad]
end

function vertex_on_boundary(mesh::QuadMesh, idx)
    return mesh.vertex_on_boundary[idx]
end

function set_vertex!(mesh::QuadMesh, quad, local_ver_idx, vertex)
    @assert is_active_vertex(mesh, vertex)
    @assert is_active_quad(mesh, quad)
    mesh.connectivity[local_ver_idx, quad] = vertex
end

function set_vertex_if_not_boundary!(mesh::QuadMesh, quad, local_ver_idx, vertex)
    if quad != 0 && local_ver_idx != 0
        set_vertex!(mesh, quad, local_ver_idx, vertex)
    end
end

function set_neighbor!(mesh::QuadMesh, quad, local_ver_idx, nbr_quad)
    @assert is_active_quad(mesh, quad)
    @assert is_active_quad_or_boundary(mesh, nbr_quad)
    mesh.q2q[local_ver_idx, quad] = nbr_quad
end

function set_neighbor_if_not_boundary!(mesh::QuadMesh, quad, local_ver_idx, nbr_quad)
    if quad != 0 && local_ver_idx != 0
        set_neighbor!(mesh, quad, local_ver_idx, nbr_quad)
    end
end

function set_twin!(mesh::QuadMesh, quad, local_ver_idx, nbr_twin)
    @assert is_active_quad(mesh, quad)
    mesh.e2e[local_ver_idx, quad] = nbr_twin
end

function set_twin_if_not_boundary!(mesh::QuadMesh, quad, local_ver_idx, nbr_twin)
    if quad != 0 && local_ver_idx != 0
        set_twin!(mesh, quad, local_ver_idx, nbr_twin)
    end
end

function increment_degree!(mesh::QuadMesh, vertex)
    @assert is_active_vertex(mesh, vertex)
    mesh.degree[vertex] += 1
end

function decrement_degree!(mesh::QuadMesh, vertex)
    @assert is_active_vertex(mesh, vertex)
    mesh.degree[vertex] -= 1
end

function set_degree!(mesh::QuadMesh, vertex, degree)
    @assert is_active_vertex(mesh, vertex)
    mesh.degree[vertex] = degree
end

function set_coordinates!(mesh::QuadMesh, idx, coords)
    @assert is_active_vertex(mesh, idx)
    mesh.vertices[:, idx] .= coords
end

function set_on_boundary!(mesh, vertex, on_boundary)
    @assert is_active_vertex(mesh, vertex)
    mesh.vertex_on_boundary[vertex] = on_boundary
end

function insert_vertex!(mesh::QuadMesh, coords, deg, on_boundary)
    new_idx = mesh.new_vertex_pointer

    if new_idx > vertex_buffer(mesh)
        expand_vertices!(mesh)
    end
    @assert new_idx <= vertex_buffer(mesh)

    mesh.vertices[:, new_idx] .= coords
    mesh.degree[new_idx] = deg
    mesh.active_vertex[new_idx] = true
    mesh.vertex_on_boundary[new_idx] = on_boundary
    mesh.num_vertices += 1
    mesh.new_vertex_pointer += 1

    return new_idx
end

function delete_vertex!(mesh::QuadMesh, idx)
    @assert is_active_vertex(mesh, idx)
    mesh.active_vertex[idx] = false
    mesh.degree[idx] = 0
    mesh.num_vertices -= 1
end

function insert_quad!(mesh::QuadMesh, connectivity, q2q, e2e)
    new_idx = mesh.new_quad_pointer

    if new_idx > quad_buffer(mesh)
        expand_quad!(mesh)
    end
    @assert new_idx <= quad_buffer(mesh)

    @assert all((is_active_vertex(mesh, v) for v in connectivity))
    @assert all((q == 0 || is_active_quad(mesh, q) for q in q2q))
    @assert all((0 <= e <= 4 for e in e2e))

    mesh.connectivity[:, new_idx] .= connectivity
    mesh.q2q[:, new_idx] .= q2q
    mesh.e2e[:, new_idx] .= e2e
    mesh.active_quad[new_idx] = true
    mesh.num_quads += 1
    mesh.new_quad_pointer += 1

    return new_idx
end

function delete_quad!(mesh::QuadMesh, idx)
    @assert is_active_quad(mesh, idx)
    mesh.active_quad[idx] = false
    mesh.connectivity[:, idx] .= 0
    mesh.q2q[:, idx] .= 0
    mesh.e2e[:, idx] .= 0
    mesh.num_quads -= 1
end

function replace_index_in_vertex_connectivity!(mesh, old_vertex_idx, new_vertex_idx)
    mesh.connectivity[mesh.connectivity.==old_vertex_idx] .= new_vertex_idx
end

function all_edges(connectivity)
    etag =
        [connectivity[[1, 2], :] connectivity[[2, 3], :] connectivity[[3, 4], :] connectivity[
            [4, 1],
            :,
        ]]
    etag = sort(etag, dims = 1)
    etag = sortslices(etag, dims = 2)

    dup = vec(all(etag[:, 2:end] - etag[:, 1:end-1] .== 0, dims = 1))
    keep = .![false; dup]
    edges = etag[:, keep]

    dup = [dup; false]
    dup = dup[keep]
    bndix = findall(.!dup)

    return edges, bndix
end

function vertex_degrees(edges, num_vertices)
    degrees = zeros(Int, num_vertices)
    for (i, _) in enumerate(eachcol(edges))
        degrees[edges[:, i]] .+= 1
    end
    return degrees
end

function zero_pad(matrix, total_size)
    numrows, numcols = size(matrix)
    @assert numcols <= total_size
    extra = total_size - numcols
    return hcat(matrix, zeros(eltype(matrix), numrows, extra))
end

function reindex_quads!(mesh::QuadMesh)
    quad_buffer_size = quad_buffer(mesh)
    new_quad_indices = zeros(Int, quad_buffer_size)
    num_quads = number_of_quads(mesh)
    new_quad_indices[mesh.active_quad] .= 1:num_quads
    
    new_q2q = active_quad_q2q(mesh)
    new_q2q = [q > 0 ? new_quad_indices[q] : 0 for q in new_q2q]
    mesh.q2q = zero_pad(new_q2q, quad_buffer_size)

    mesh.connectivity = zero_pad(active_quad_connectivity(mesh), quad_buffer_size)
    mesh.e2e = zero_pad(active_quad_e2e(mesh), quad_buffer_size)

    mesh.active_quad = falses(quad_buffer_size)
    mesh.active_quad[1:num_quads] .= true

end

function reindex_vertices!(mesh::QuadMesh)
    vertex_buffer_size = vertex_buffer(mesh)
    new_vertex_indices = zeros(Int, vertex_buffer_size)
    num_vertices = number_of_vertices(mesh)
    active_vertices = mesh.active_vertex
    new_vertex_indices[active_vertices] .= 1:num_vertices
    
    mesh.vertices = zero_pad(active_vertex_coordinates(mesh), vertex_buffer_size)

    active_conn = active_quad_connectivity(mesh)
    new_conn = [new_vertex_indices[v] for v in active_conn]
    mesh.connectivity[:, mesh.active_quad] .= new_conn

    num_extra_verts = vertex_buffer_size - num_vertices
    mesh.degree = [mesh.degree[active_vertices]; zeros(Int, num_extra_verts)]
    mesh.vertex_on_boundary = [mesh.vertex_on_boundary[active_vertices]; falses(num_extra_verts)]

    mesh.active_vertex = [trues(num_vertices); falses(num_extra_verts)]

    return new_vertex_indices
end

function averagesmoothing(points, connectivity, q2q, active_quads, boundary_nodes)
    num_points = size(points, 2)
    new_points = similar(points)
    fill!(new_points, 0.0)
    count = zeros(Int, num_points)

    for (quad, is_active) in enumerate(active_quads)
        if is_active
            for edge in 1:4
                if quad > q2q[edge, quad]
                    v1 = connectivity[edge, quad]
                    v2 = connectivity[next(edge), quad]
                    new_points[:,v1] += points[:, v2]
                    new_points[:, v2] += points[:, v1]
                    count[v1] += 1
                    count[v2] += 1
                end
            end
        end
    end
    count[count .== 0] .= 1
    new_points = new_points ./ count'
    new_points[:, boundary_nodes] = points[:, boundary_nodes]
    return new_points
end

function averagesmoothing!(mesh::QuadMesh)
    boundary_nodes = findall(mesh.vertex_on_boundary)
    mesh.vertices = averagesmoothing(mesh.vertices, mesh.connectivity, mesh.q2q, mesh.active_quad, boundary_nodes)
end