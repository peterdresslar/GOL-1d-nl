
get_pattern(N::Int, ρ::Float64)::BitVector = rand(N) .< ρ

init_1d_board_pattern(pattern::BitVector)::BitVector = pattern

"""left to right, top to bottom"""
init_2d_board_pattern(pattern::BitVector, n::Int)::BitMatrix = transpose(reshape(pattern, n, n)) # need to be very careful about transpose

N = 25
n = Int(sqrt(N))
r = n
ρ = 0.35    

pattern = get_pattern(N, ρ)

b1 = init_1d_board_pattern(pattern)
b2 = init_2d_board_pattern(pattern, n)

println(pattern)
println(b1)
println(b2)






