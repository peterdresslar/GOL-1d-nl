# ───────────── initialization ─────────────
get_offsets(r::Int)::NTuple{8, Int} = (-r - 1, -r, -r + 1, -1, 1, r - 1, r, r + 1)   # offsets that map neighborhood τᵣ for any location s as definied by r

init_board(N::Int, ρ::Float64)::BitVector = rand(N) .< ρ             # a function that initializes a board of size N with a given density ρ

# paste_left_right(definition::Vector(Tuple(Int, Int)), origin::Int, r::Int, board::BitVector)::BitVector
# this function will add in a primitive (spaceship or other) to the board at the origin
# using the definitions in the tuple as Offset, r_multiplier.
# the vector has a list of all the points that need to be set to alive to "paste" in the pattern.

# ───────────── intra-step operations ─────────────

@inline live_neighbors(b::BitVector, s::Int, offsets::NTuple{8, Int})::UInt8 =     # an inline function that counts the number of live neighbors of a cell
    count(offset -> begin                   # iterate over the eight offsets with a lambda function
            x = s + offset                  # absolute index of the neighbour, x, a point in neighborhood τᵣ
            1 ≤ x ≤ length(b) && b[x]       # inside the board *and* alive? NOTE off-board cells are all calculated as dead here.
        end,                                # lambda function ends here
        offsets)                            # neighborhood "addresses"

# ───────────── step ─────────────

function step!(b::BitVector, tmp::BitVector, offsets::NTuple{8, Int})::BitVector
    @inbounds for s in eachindex(b)
        n = live_neighbors(b, s, offsets)
        tmp[s] = (n == 3) | (b[s] & (n == 2))
    end
    copyto!(b, tmp)            # overwrite in-place
    return b
end