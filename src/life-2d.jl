# life-2d.jl

"""
2-D Game of Life. For research / comparison purposes.
"""

# ───────────── initialization ─────────────

"""Initialize a board of size n*n with a given density ρ"""
init_2d_board_random(n::Int, ρ::Float64)::BitMatrix = rand(n, n) .< ρ          

# ───────────── intra-step operations ─────────────
"""
An inline function that counts the number of live neighbors of a cell, by counting all x with true in neighborhood τᵣ
Note that this function does not wrap.
"""
@inline live_neighbors(b::Array{Bool, 2}, s::Tuple{Int, Int}, offsets::NTuple{8, Int})::UInt8 =     
    count(offset -> begin                   # iterate over the eight offsets with a lambda function
            x = s + offset                  # absolute index of the neighbour, x, a point in neighborhood τᵣ
            1 ≤ x ≤ length(b) && b[x]       # inside the board *and* alive? off-board cells are all calculated as dead here.
        end,                                # lambda function ends here
        offsets)                            # neighborhood "addresses"

# ───────────── step ─────────────
"""
A function that performs a single step of the Game of Life. Since it passes the offsets it is 1-D specific; otherwise it would be indifferent to the dimension.
"""
function step!(b::BitVector, tmp::BitVector, offsets::NTuple{8, Int})::BitVector
    @inbounds for s in eachindex(b)
        n = live_neighbors(b, s, offsets)
        tmp[s] = (n == 3) | (b[s] & (n == 2))   # true if n == 3 or n == 2 and the cell is alive
    end
    copyto!(b, tmp)                             # overwrite in-place
    return b
end