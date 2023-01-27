using Test

@testset "square mesh" begin
    include("test_square_mesh.jl")
end

@testset "test flip" begin
    include("test_flip.jl")
end

@testset "test split" begin
    include("test_split.jl")
end

@testset "test collapse" begin
    include("test_collapse.jl")
end

# @testset "test global split" begin
#     include("test_global_split.jl")
# end

@testset "test boundary split" begin
    include("test_boundary_split.jl")
end

@testset "test Game Env" begin
    include("test_game_env.jl")
end