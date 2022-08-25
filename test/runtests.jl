using Test

@testset "square mesh" begin
    include("test_square_mesh.jl")
end

@testset "test flip" begin
    include("test_flip.jl")
end